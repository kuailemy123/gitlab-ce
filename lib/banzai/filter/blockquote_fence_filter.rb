module Banzai
  module Filter
    class BlockquoteFenceFilter < HTML::Pipeline::TextFilter
      def initialize(text, context = nil, result = nil)
        super text, context, result
        @text = @text.delete "\r"
      end

      def call
        @text.gsub(/^>>>\n(.+?)\n>>>$/m) { $1.gsub(/^/, "> ") }
      end
    end
  end
end
