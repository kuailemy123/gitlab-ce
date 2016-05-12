require 'rails_helper'

describe Gitlab::DependencyLinker::LinkGemfile, lib: true do
  describe '.support?' do
    it 'supports Gemfile' do
      expect(described_class.support?('Gemfile')).to be_truthy
    end

    it 'supports gems.rb' do
      expect(described_class.support?('gems.rb')).to be_truthy
    end

    it 'does not support other files' do
      expect(described_class.support?('Gemfile.lock')).to be_falsey
    end
  end

  describe '.link' do
    def highlight(blob_name, blob_content)
      Gitlab::Highlight.highlight(blob_name, blob_content)
    end

    before do
      # TODO (rspeicher): 'Splain it
      allow_any_instance_of(Gitlab::Highlight).to receive(:link_dependencies) do |_, *args|
        args.last
      end
    end

    it 'links a gem name in single quotes to its rubygems.org entry' do
      result = described_class.link(nil, highlight('Gemfile', <<-EOF))
        gem 'rails',      '4.2.6'
        gem 'responders', '~> 2.0'
      EOF

      expect(result).to include("https://rubygems.org/gems/rails")
      expect(result).to include("https://rubygems.org/gems/responders")
    end

    it 'links a gem name in double quotes to its rubygems.org entry' do
      result = described_class.link(nil, highlight('gems.rb', <<-EOF))
        gem "rails",      "4.2.6"
        gem "responders", "~> 2.0"
      EOF

      expect(result).to include("https://rubygems.org/gems/rails")
      expect(result).to include("https://rubygems.org/gems/responders")
    end

    it 'does not link arbitrary strings' do
      result = described_class.link(nil, highlight('Gemfile', <<-EOF))
        def darwin_only(require_as)
          RUBY_PLATFORM.include?('darwin') && require_as
        end

        def linux_only(require_as)
          RUBY_PLATFORM.include?('linux') && require_as
        end
      EOF

      expect(result).not_to include('rubygems.org')
    end
  end
end
