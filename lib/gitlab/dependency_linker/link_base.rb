module Gitlab
  module DependencyLinker
    class LinkBase
      def self.link(plain_text, highlighted_text)
        new(plain_text, highlighted_text).link
      end

      attr_accessor :plain_text, :highlighted_text

      def initialize(plain_text, highlighted_text)
        @plain_text = plain_text
        @highlighted_text = highlighted_text
      end

      def link
        highlighted_text
      end

      private

      def package_url(name)
        raise NotImplementedError
      end

      def package_link(name)
        Nokogiri::HTML::Document.new
          .create_element('a', name,
                          href: package_url(name),
                          target: '_blank').to_html
      end
    end
  end
end
