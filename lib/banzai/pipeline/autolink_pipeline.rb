module Banzai
  module Pipeline
    class AutolinkPipeline < BasePipeline
      def self.filters
        @filters ||= FilterArray[
          Filter::AutolinkFilter,
        ]
      end
    end
  end
end
