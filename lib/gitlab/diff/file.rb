module Gitlab
  module Diff
    class File
      attr_reader :diff, :diff_refs, :repository

      delegate :new_file, :deleted_file, :renamed_file,
        :old_path, :new_path, to: :diff, prefix: false

      def initialize(diff, diff_refs: nil, repository: nil)
        @diff = diff
        @diff_refs = diff_refs
        @repository = repository
      end

      def old_ref
        diff_refs.try(:base_id)
      end

      def new_ref
        diff_refs.try(:head_id)
      end

      # Array of Gitlab::Diff::Line objects
      def diff_lines
        @lines ||= Gitlab::Diff::Parser.new.parse(raw_diff.each_line).to_a
      end

      def highlighted_diff_lines
        @highlighted_diff_lines ||= Gitlab::Diff::Highlight.new(self, repository: self.repository).highlight
      end

      def parallel_diff_lines
        @parallel_diff_lines ||= Gitlab::Diff::ParallelDiff.new(self).parallelize
      end

      def mode_changed?
        !!(diff.a_mode && diff.b_mode && diff.a_mode != diff.b_mode)
      end

      def parser
        Gitlab::Diff::Parser.new
      end

      def raw_diff
        diff.diff.to_s
      end

      def next_line(index)
        diff_lines[index + 1]
      end

      def prev_line(index)
        if index > 0
          diff_lines[index - 1]
        end
      end

      def file_path
        if diff.new_path.present?
          diff.new_path
        elsif diff.old_path.present?
          diff.old_path
        end
      end

      def added_lines
        diff_lines.count(&:added?)
      end

      def removed_lines
        diff_lines.count(&:removed?)
      end
    end
  end
end
