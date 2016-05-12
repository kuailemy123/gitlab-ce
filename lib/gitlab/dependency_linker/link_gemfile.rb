module Gitlab
  module DependencyLinker
    class LinkGemfile
      def self.support?(blob_name)
        blob_name == 'Gemfile'
      end

      def self.link(plain_text, highlighted_text)
        doc = Nokogiri::HTML::DocumentFragment.parse(highlighted_text)

        doc.xpath('.//span[@class="n"][.="gem"]').each do |gem|
          quoted_gem_node = gem.next_element

          text = quoted_gem_node.text.match(/(['"])([^'"]+)(\1)/)
          link = doc.document
            .create_element('a', text[2],
                            href: "https://rubygems.org/gems/#{text[2]}",
                            target: '_blank')
          quoted_gem_node.replace("#{text[1]}#{link}#{text[1]}")
        end

        doc.to_html.html_safe
      end
    end
  end
end
