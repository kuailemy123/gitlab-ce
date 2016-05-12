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

    it 'links a gem name in single quotes to its rubygems.org entry' do
      result = highlight('Gemfile', <<-EOF)
        gem 'rails',      '4.2.6'
        gem 'responders', '~> 2.0'
      EOF

      expect(result).to include("https://rubygems.org/gems/rails")
      expect(result).to include("https://rubygems.org/gems/responders")
    end

    it 'links a gem name in double quotes to its rubygems.org entry' do
      result = highlight('gems.rb', <<-EOF)
        gem "rails",      "4.2.6"
        gem "responders", "~> 2.0"
      EOF

      expect(result).to include("https://rubygems.org/gems/rails")
      expect(result).to include("https://rubygems.org/gems/responders")
    end

    it 'does not link arbitrary strings' do
      result = highlight('Gemfile', <<-EOF)
        def darwin_only(require_as)
          RUBY_PLATFORM.include?('darwin') && require_as
        end
      EOF

      expect(result).not_to include('rubygems.org')
    end

    it 'handles a `gem` call without arguments' do
      expect { highlight('Gemfile', 'gem') }.not_to raise_error
    end

    it 'handles a `gem` call with non-string arguments' do
      contents = <<-EOF
        name = 'rails'
        gem name, github: 'rails/rails'
      EOF

      expect { highlight('gems.rb', contents) }.not_to raise_error
    end
  end
end
