module Gitlab
  module DependencyLinker
    LINKERS = [
      LinkGemfile
    ]

    def self.process(blob_name, highlighted_text)
      linker = linker(blob_name)
      return highlighted_text unless linker

      linker.link(highlighted_text)
    end

    private

    def self.linker(blob_name)
      LINKERS.find do |linker|
        linker.support?(blob_name)
      end
    end
  end
end
