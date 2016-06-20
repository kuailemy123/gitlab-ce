# Inspired in great part by Discourse's Email::Receiver
module Gitlab
  module Email
    class Receiver
      class ProcessingError < StandardError; end
      class EmailUnparsableError < ProcessingError; end
      class SentNotificationNotFoundError < ProcessingError; end
      class EmptyEmailError < ProcessingError; end
      class AutoGeneratedEmailError < ProcessingError; end
      class UserNotFoundError < ProcessingError; end
      class UserBlockedError < ProcessingError; end
      class UserNotAuthorizedError < ProcessingError; end
      class NoteableNotFoundError < ProcessingError; end
      class InvalidNoteError < ProcessingError; end

      def initialize(raw)
        @raw = raw
      end

      def execute
        raise EmptyEmailError if @raw.blank?

        raise SentNotificationNotFoundError unless sent_notification

        raise AutoGeneratedEmailError if message.header.to_s =~ /auto-(generated|replied)/

        author = sent_notification.recipient

        raise UserNotFoundError unless author

        raise UserBlockedError if author.blocked?

        project = sent_notification.project

        raise UserNotAuthorizedError unless project && author.can?(:create_note, project)

        raise NoteableNotFoundError unless sent_notification.noteable

        reply = ReplyParser.new(message).execute.strip

        raise EmptyEmailError if reply.blank?

        reply = add_attachments(reply)

        note = create_note(reply)

        unless note.persisted?
          msg = "The comment could not be created for the following reasons:"
          note.errors.full_messages.each do |error|
            msg << "\n\n- #{error}"
          end

          raise InvalidNoteError, msg
        end
      end

      private

      def message
        @message ||= Mail::Message.new(@raw)
      rescue Encoding::UndefinedConversionError, Encoding::InvalidByteSequenceError => e
        raise EmailUnparsableError, e
      end

      def reply_key
        key_from_to_header || key_from_additional_headers
      end

      def key_from_to_header
        key = nil
        message.to.each do |address|
          key = Gitlab::IncomingEmail.key_from_address(address)
          break if key
        end

        key
      end

      def key_from_additional_headers
        reply_key = nil

        Array(message.references).each do |message_id|
          reply_key = Gitlab::IncomingEmail.key_from_fallback_reply_message_id(message_id)
          break if reply_key
        end

        reply_key
      end

      def sent_notification
        return nil unless reply_key

        SentNotification.for(reply_key)
      end

      def add_attachments(reply)
        attachments = Email::AttachmentUploader.new(message).execute(sent_notification.project)

        attachments.each do |link|
          reply << "\n\n#{link[:markdown]}"
        end

        reply
      end

      def create_note(reply)
        sent_notification.create_note(reply)
      end
    end
  end
end
