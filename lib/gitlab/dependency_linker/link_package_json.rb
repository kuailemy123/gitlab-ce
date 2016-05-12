module Gitlab
  module DependencyLinker
    class LinkPackageJson < LinkJson
      def self.support?(blob_name)
        blob_name == 'package.json'
      end

      private

      def package_url(name)
        "https://npmjs.com/package/#{name}"
      end

      def mark_dependencies
        name = json["name"]
        if name
          mark_dependency_with_regex(/"name":\s*"(?<name>#{Regexp.escape(name)})"/)
        end

        mark_dependencies_at_key("dependencies")
        mark_dependencies_at_key("devDependencies")
      end

      def mark_dependencies_at_key(key)
        dependencies = json[key]
        return unless dependencies

        dependencies.each do |name, version|
          mark_dependency(name, version)
        end
      end

      def mark_dependency(name, version)
        return unless valid_package_name?(name)

        mark_dependency_with_regex(/"(?<name>#{Regexp.escape(name)})":\s*"#{Regexp.escape(version)}"/)
      end

      def valid_package_name?(name)
        true
      end
    end
  end
end
