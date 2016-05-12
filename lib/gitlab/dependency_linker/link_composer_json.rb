module Gitlab
  module DependencyLinker
    class LinkComposerJson < LinkPackageJson
      def self.support?(blob_name)
        blob_name == 'composer.json'
      end

      private

      def package_url(name)
        "https://packagist.org/packages/#{name}"
      end

      def mark_dependencies
        name = json["name"]
        if name
          mark_dependency_with_regex(/"name":\s*"(?<name>#{Regexp.escape(name)})"/)
        end

        mark_dependencies_at_key("require")
        mark_dependencies_at_key("require-dev")
      end

      def valid_package_name?(name)
        name =~ /\A[^\/]+\/[^\/]+\z/
      end
    end
  end
end
