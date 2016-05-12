module Gitlab
  module DependencyLinker
    class LinkPodfile < LinkGemfile
      def self.support?(blob_name)
        blob_name == 'Podfile'
      end

      private

      def dependency_method_name
        "pod"
      end

      def package_url(name)
        "https://cocoapods.org/pods/#{name}"
      end
    end
  end
end
