module Gitlab
  module Diff
    class PositionTracer
      attr_accessor :repository
      attr_accessor :old_diff_refs
      attr_accessor :new_diff_refs
      attr_accessor :paths

      def initialize(repository:, old_diff_refs:, new_diff_refs:, paths: nil)
        @repository = repository
        @old_diff_refs = old_diff_refs
        @new_diff_refs = new_diff_refs
        @paths = paths
      end

      def execute(position)
        return unless old_diff_refs.complete? && new_diff_refs.complete?

        file_diff = new_diffs.find { |diff_file| diff_file.old_path == position.old_path }

        return unless file_diff

        file_base_to_base = diff_base_to_base.find { |diff_file| diff_file.old_path == position.old_path }
        file_head_to_head = diff_head_to_head.find { |diff_file| diff_file.old_path == position.file_path }

        case position.type
        when 'new', nil
          if file_head_to_head
            new_line = LineMapper.new(file_head_to_head.diff_lines).old_to_new[position.new_line]
          else
            new_line = position.new_line
          end

          return unless new_line

          old_line = LineMapper.new(file_diff.diff_lines).new_to_old[new_line]
        when 'old'
          if file_base_to_base
            old_line = LineMapper.new(file_base_to_base.diff_lines).old_to_new[position.old_line]
          else
            old_line = position.old_line
          end

          return unless old_line

          new_line = LineMapper.new(file_diff.diff_lines).old_to_new[old_line]
        end

        Position.new(
          old_path: file_diff.old_path,
          new_path: file_diff.new_path,
          head_id: new_diff_refs.head_id,
          start_id: new_diff_refs.start_id,
          base_id: new_diff_refs.base_id,
          old_line: old_line,
          new_line: new_line
        )
      end

      private

      def diff_base_to_base
        @diff_base_to_base ||= diff_files(old_diff_refs.base_id || old_diff_refs.start_id, new_diff_refs.base_id || new_diff_refs.start_id)
      end

      def diff_head_to_head
        @diff_head_to_head ||= diff_files(old_diff_refs.head_id, new_diff_refs.head_id)
      end

      def new_diffs
        @new_diffs ||= diff_files(new_diff_refs.start_id, new_diff_refs.head_id)
      end

      def diff_files(start_id, head_id)
        base_commit = self.repository.merge_base(start_id, head_id)

        diff_refs = DiffRefs.new(
          base_id: base_commit.try(:sha),
          start_id: start_id,
          head_id: head_id
        )

        Gitlab::Git::Compare.new(
          self.repository.raw_repository,
          start_id,
          head_id
        ).diffs(
          paths: @paths
        ).decorate! do |diff|
          Gitlab::Diff::File.new(diff, diff_refs: diff_refs, repository: self.repository)
        end
      end
    end
  end
end
