module Gitlab
  module DependencyLinker
    class LinkPackageJson
      def self.support?(blob_name)
        blob_name == 'package.json'
      end

      def self.link(plain_text, highlighted_text)
        new(plain_text, highlighted_text).link
      end

      attr_accessor :plain_text, :highlighted_text

      def initialize(plain_text, highlighted_text)
        @plain_text = plain_text
        @highlighted_text = highlighted_text
      end

      def link
        return highlighted_text unless json

        mark_dependencies("dependencies")
        mark_dependencies("devDependencies")

        highlighted_lines.join.html_safe
      end

      private

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
          line_index = plain_lines.index do |line|
            line =~ /"(?<name>#{Regexp.escape(name)})":\s*"#{Regexp.escape(version)}"/
          end

          next unless line_index
          begin_index, end_index = $~.offset(:name)
          name_range = Range.new(begin_index, end_index - 1)

          plain_line = plain_lines[line_index]
          highlighted_line = highlighted_lines[line_index].html_safe

          marked_line = Gitlab::StringRangeMarker.new(plain_line, highlighted_line).mark([name_range]) do |text, left:, right:|
            Nokogiri::HTML::Document.new
              .create_element('a', text,
                              href: "https://npmjs.com/package/#{name}",
                              target: '_blank').to_html
          end

          highlighted_lines[line_index] = marked_line
        end
      end
    end
  end
end
