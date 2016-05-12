module Gitlab
  module DependencyLinker
    class LinkComposerJson < LinkJson
      def self.support?(blob_name)
        blob_name == 'composer.json'
      end

      private

      def dependency_keys
        %w[require require-dev]
      end

      def package_url(name)
        "https://packagist.org/packages/#{name}"
      end

      def valid_package_name?(name)
        name =~ /\A[^\/]+\/[^\/]+\z/
      end
    end
  end
end
