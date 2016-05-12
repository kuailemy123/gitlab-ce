module Gitlab
  module DependencyLinker
    LINKERS = [
      LinkComposerJson,
      LinkGemfile,
      LinkGodeps,
      LinkPodfile,
      LinkPackageJson,
    ]

    def self.process(blob_name, plain_text, highlighted_text)
      linker = linker(blob_name)
      return highlighted_text unless linker

      linker.link(plain_text, highlighted_text)
    end

    private

    def self.linker(blob_name)
      LINKERS.find { |linker| linker.support?(blob_name) }
    end
  end
end
