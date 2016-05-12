module Gitlab
  module DependencyLinker
    class LinkGemfile
      def self.support?(blob_name)
        blob_name == 'Gemfile' || blob_name == 'gems.rb'
      end

      def self.link(_plain_text, highlighted_text)
        doc = Nokogiri::HTML::DocumentFragment.parse(highlighted_text)

        doc.xpath('.//span[@class="n"][.="gem"]').each do |gem|
          quoted_gem_name_node = gem.next_element

          # TODO (rspeicher): Extract guards to method
          next unless quoted_gem_name_node

          # Only replace strings that follow "gem"
          next unless quoted_gem_name_node.attr('class').start_with?('s')

          # We want to replace the text node, not the highlighted span itself
          quoted_gem_name_node = quoted_gem_name_node.child

          matches = quoted_gem_name_node.text.match(/(['"])([^'"]+)(\1)/)
          next unless matches

          quote = ERB::Util.html_escape(matches[1])
          name = matches[2]

          link = doc.document
            .create_element('a', name,
                            href: "https://rubygems.org/gems/#{name}",
                            target: '_blank')

          quoted_gem_name_node.replace("#{quote}#{link}#{quote}")
        end

        doc.to_html.html_safe
      end
    end
  end
end
