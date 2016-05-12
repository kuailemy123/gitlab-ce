require 'rails_helper'

describe Gitlab::DependencyLinker::LinkPodfile, lib: true do
  describe '.support?' do
    it 'supports Podfile' do
      expect(described_class.support?('Podfile')).to be_truthy
    end

    it 'does not support other files' do
      expect(described_class.support?('Gemfile')).to be_falsey
    end
  end

  describe '.link' do
    def highlight(blob_name, blob_content)
      Gitlab::Highlight.highlight(blob_name, blob_content)
    end

    it 'links a pod name in single quotes to its cocoapods.org entry' do
      result = highlight('Podfile', <<-EOF)
        target 'MyApp'
        pod 'AFNetworking', '~> 1.0'
      EOF

      expect(result).to include("https://cocoapods.org/pods/AFNetworking")
    end

    it 'links a pod name in double quotes to its cocoapods.org entry' do
      result = highlight('Podfile', <<-EOF)
        target 'MyApp'
        pod "AFNetworking", "~> 1.0"
      EOF

      expect(result).to include("https://cocoapods.org/pods/AFNetworking")
    end

    it 'does not link arbitrary strings' do
      result = highlight('Podfile', <<-EOF)
        target 'MyApp'
      EOF

      expect(result).not_to include('cocoapods.org')
    end

    it 'handles a `pod` call without arguments' do
      expect { highlight('Podfile', 'pod') }.not_to raise_error
    end

    it 'handles a `pod` call with non-string arguments' do
      contents = <<-EOF
        name = 'AFNetworking'
        pod name
      EOF

      expect { highlight('Podfile', contents) }.not_to raise_error
    end
  end
end
