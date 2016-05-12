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

  describe '#highlight' do
    it 'links dependencies via DependencyLinker' do
      expect(Gitlab::DependencyLinker).to receive(:process).
        with('file.name', 'Contents', anything)

      described_class.highlight('file.name', 'Contents')
    end
  end
end
