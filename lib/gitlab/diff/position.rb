module Gitlab
  module Diff
    class Position
      attr_reader :old_path
      attr_reader :new_path
      attr_reader :old_line
      attr_reader :new_line
      attr_reader :base_id
      attr_reader :start_id
      attr_reader :head_id

      def initialize(attrs = {})
        @old_path = attrs[:old_path]
        @new_path = attrs[:new_path]
        @old_line = attrs[:old_line]
        @new_line = attrs[:new_line]
        @base_id  = attrs[:base_id]
        @start_id = attrs[:start_id]
        @head_id  = attrs[:head_id]
      end

      def init_with(coder)
        initialize(coder['attributes'])

        self
      end

      def encode_with(coder)
        coder['attributes'] = self.to_h
      end

      def key
        return unless old_path && new_path
        @key ||= [base_id, start_id, head_id, Digest::SHA1.hexdigest(old_path), Digest::SHA1.hexdigest(new_path), old_line, new_line]
      end

      def ==(other)
        other.is_a?(self.class) && key == other.key
      end

      def to_h
        {
          old_path: old_path,
          new_path: new_path,
          old_line: old_line,
          new_line: new_line,
          base_id:  base_id,
          start_id: start_id,
          head_id:  head_id
        }
      end

      def to_json
        JSON.generate(self.to_h)
      end

      def type
        if old_line && new_line
          nil
        elsif new_line
          'new'
        else
          'old'
        end
      end

      def added?
        type == 'new'
      end

      def removed?
        type == 'old'
      end

      def paths
        [old_path, new_path].compact
      end

      def file_path
        new_path.presence || old_path
      end

      def diff_refs
        @diff_refs ||= DiffRefs.new(base_id: base_id, start_id: start_id, head_id: head_id)
      end

      def diff_file(repository)
        @diff_file ||= begin
          Gitlab::Git::Compare.new(
            repository.raw_repository,
            start_id,
            head_id
          ).diffs(
            paths: self.paths
          ).decorate! do |diff|
            Gitlab::Diff::File.new(diff, repository: repository, diff_refs: diff_refs)
          end.find { |diff_file| diff_file.file_path == file_path }
        end
      end

      def diff_line(repository)
        @diff_line ||= diff_file(repository).line_for_position(self)
      end

      def line_code(repository)
        @line_code ||= diff_file(repository).line_code_for_position(self)
      end
    end
  end
end
