module Gitlab
  module DependencyLinker
    class LinkPackageJson < LinkJson
      def self.support?(blob_name)
        blob_name == 'package.json'
      end

      private

      def dependency_keys
        %w[dependencies devDependencies]
      end

      def package_url(name)
        "https://npmjs.com/package/#{name}"
      end
    end
  end
end
