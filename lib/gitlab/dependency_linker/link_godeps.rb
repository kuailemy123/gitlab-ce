module Gitlab
  module DependencyLinker
    class LinkGodeps < LinkJson
      def self.support?(blob_name)
        blob_name == 'Godeps.json'
      end

      private

      def package_url(name)
        "http://#{name}"
      end

      def mark_dependencies
        name = json["ImportPath"]
        mark_dependency(name) if name

        mark_dependencies_at_key("Deps")
      end

      def mark_dependencies_at_key(key)
        dependencies = json[key]
        return unless dependencies

        dependencies.each do |dependency|
          mark_dependency(dependency["ImportPath"])
        end
      end

      def mark_dependency(name)
        mark_dependency_with_regex(/"ImportPath":\s*"(?<name>#{Regexp.escape(name)})"/)
      end
    end
  end
end
