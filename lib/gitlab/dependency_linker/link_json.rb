module Gitlab
  module DependencyLinker
    class LinkJson < LinkBase
      def link
        return highlighted_text unless json

        dependency_keys.each do |key|
          mark_dependencies(key)
        end

        highlighted_lines.join.html_safe
      end

      private

      def dependency_keys
        raise NotImplementedError
      end

      def package_url(name)
        raise NotImplementedError
      end

      def valid_package_name?(name)
        true
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

      def mark_dependencies(key)
        dependencies = json[key]
        return unless dependencies

        dependencies.each do |name, version|
          next unless valid_package_name?(name)

          line_index = plain_lines.index do |line|
            line =~ /"(?<name>#{Regexp.escape(name)})":\s*"#{Regexp.escape(version)}"/
          end

          next unless line_index
          begin_index, end_index = $~.offset(:name)
          name_range = Range.new(begin_index, end_index - 1)

          plain_line = plain_lines[line_index]
          highlighted_line = highlighted_lines[line_index].html_safe

          marked_line = Gitlab::StringRangeMarker.new(plain_line, highlighted_line).mark([name_range]) do |text, left:, right:|
            package_link(name)
          end

          highlighted_lines[line_index] = marked_line
        end
      end
    end
  end
end
