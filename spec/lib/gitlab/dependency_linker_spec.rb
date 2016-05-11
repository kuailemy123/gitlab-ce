require 'rails_helper'

module Gitlab
  describe DependencyLinker, lib: true do
    describe '.process' do
      it 'links using LinkGemfile' do
        blob_name = 'Gemfile'

        expect(described_class::LinkGemfile).to receive(:link)

        described_class.process(blob_name, '')
      end
    end
  end
end
