module Gitlab
  module DependencyLinker
    class LinkJson < LinkBase
      def link
        return highlighted_text unless json

        mark_dependencies

        highlighted_lines.join.html_safe
      end

      private

      def package_url(name)
        raise NotImplementedError
      end

      def mark_dependencies
        raise NotImplementedError
      end

      def json
        @json ||= JSON.parse(plain_text) rescue nil
      end

      def plain_lines
        @plain_lines ||= plain_text.lines
      end

      def highlighted_lines
        @highlighted_lines ||= highlighted_text.lines
      end

      def mark_dependency_with_regex(regex)
        line_index = plain_lines.index { |line| line =~ regex }

        return unless line_index
        begin_index, end_index = $~.offset(:name)
        name_range = Range.new(begin_index, end_index - 1)

        plain_line = plain_lines[line_index]
        highlighted_line = highlighted_lines[line_index].html_safe

        marked_line = Gitlab::StringRangeMarker.new(plain_line, highlighted_line).mark([name_range]) do |text, left:, right:|
          package_link(text)
        end

        highlighted_lines[line_index] = marked_line
      end
    end
  end
end
