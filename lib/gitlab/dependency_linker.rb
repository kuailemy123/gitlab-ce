module Gitlab
  module DependencyLinker
    LINKERS = [
      LinkGemfile,
      LinkPodfile,
      LinkPackageJson,
      LinkComposerJson,
      LinkGodeps
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
