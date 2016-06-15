require 'rouge/plugins/redcarpet'

module Banzai
  module Filter
    # HTML Filter to highlight fenced code blocks
    #
    class SyntaxHighlightFilter < HTML::Pipeline::Filter
      include Rouge::Plugins::Redcarpet

      def call
        doc.search('pre > code').each do |node|
          highlight_node(node)
        end

        doc
      end

      def highlight_node(node)
        language = node.attr('class')
        code     = node.text

        begin
          highlighted = %<<pre class="#{css_classes}"><code>#{block_code(code, language)}</code></pre>>
        rescue
          # Gracefully handle syntax highlighter bugs/errors to ensure
          # users can still access an issue/comment/etc.
          highlighted = "<pre>#{code}</pre>"
        end

        # Replace the parent `pre` element with the entire highlighted block
        node.parent.replace(highlighted)
      end

      def css_classes
        "code highlight js-syntax-highlight #{lexer.tag}"
      end

      private

      # Override Rouge::Plugins::Redcarpet#rouge_formatter
      def rouge_formatter(lexer)
        Rouge::Formatters::HTML.new
      end
    end
  end
end
