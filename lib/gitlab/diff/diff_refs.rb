module Gitlab
  module Diff
    class DiffRefs
      attr_reader :base_id
      attr_reader :start_id
      attr_reader :head_id

      def initialize(base_id:, start_id: base_id, head_id:)
        @base_id = base_id
        @start_id = start_id
        @head_id = head_id
      end

      def ==(other)
        other.is_a?(self.class) && base_id == other.base_id && start_id == other.start_id && head_id == other.head_id
      end

      def complete?
        base_id && start_id && head_id
      end
    end
  end
end
