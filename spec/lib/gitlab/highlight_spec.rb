require 'spec_helper'

describe Gitlab::Highlight, lib: true do
  include RepoHelpers

  let(:project) { create(:project) }
  let(:commit) { project.commit(sample_commit.id) }

  describe '.highlight_lines' do
    let(:lines) do
      described_class.highlight_lines(project.repository, commit.id, 'files/ruby/popen.rb')
    end

    it 'should properly highlight all the lines' do
      expect(lines[4]).to eq(%Q{<span id="LC5" class="line">  <span class="kp">extend</span> <span class="nb">self</span></span>\n})
      expect(lines[21]).to eq(%Q{<span id="LC22" class="line">    <span class="k">unless</span> <span class="no">File</span><span class="p">.</span><span class="nf">directory?</span><span class="p">(</span><span class="n">path</span><span class="p">)</span></span>\n})
      expect(lines[26]).to eq(%Q{<span id="LC27" class="line">    <span class="vi">@cmd_status</span> <span class="o">=</span> <span class="mi">0</span></span>\n})
    end
  end

  describe '#link_dependencies' do
    context 'on Gemfile' do
      it 'links a gem name in single quotes to its rubygems.org entry' do
        result = described_class.highlight('Gemfile', <<-EOF.strip_heredoc)
          gem 'rails',      '4.2.6'
          gem 'responders', '~> 2.0'
        EOF

        expect(result).to include("https://rubygems.org/gems/rails")
        expect(result).to include("https://rubygems.org/gems/responders")
      end

      it 'works with double quotes' do
        result = described_class.highlight('Gemfile', <<-EOF.strip_heredoc)
          gem "rails",      "4.2.6"
          gem "responders", "~> 2.0"
        EOF

        expect(result).to include("https://rubygems.org/gems/rails")
        expect(result).to include("https://rubygems.org/gems/responders")
      end

      it 'requires a `gem` call before highlighting the first string' do
        result = described_class.highlight('Gemfile', <<-EOF.strip_heredoc)
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

    context 'on an unsupported file' do
      it 'does not process the file' do
        expect(Nokogiri::HTML::DocumentFragment).not_to receive(:parse)

        described_class.highlight('Gemfile.lock', '')
      end
    end
  end
end
