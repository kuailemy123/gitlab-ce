module Gitlab
  class Highlight
    def self.highlight(blob_name, blob_content, nowrap: true, plain: false)
      new(blob_name, blob_content, nowrap: nowrap).
        highlight(blob_content, continue: false, plain: plain)
    end

    def self.highlight_lines(repository, ref, file_name)
      blob = repository.blob_at(ref, file_name)
      return [] unless blob

      blob.load_all_data!(repository)
      highlight(file_name, blob.data).lines.map!(&:html_safe)
    end

    attr_reader :blob_name

    def initialize(blob_name, blob_content, nowrap: true)
      @blob_name = blob_name
      @formatter = rouge_formatter(nowrap: nowrap)
      @lexer = Rouge::Lexer.guess(filename: blob_name, source: blob_content).new rescue Rouge::Lexers::PlainText
    end

    def highlight(text, continue: true, plain: false)
      text = highlight_text(text, continue: continue, plain: plain)
      text = link_dependencies(text, text)
    end

    private

    def highlight_text(text, continue: true, plain: false)
      if plain
        highlight_plain(text)
      else
        highlight_rich(text, continue: continue)
      end
    end

    def highlight_plain(text)
      @formatter.format(Rouge::Lexers::PlainText.lex(text)).html_safe
    end

    def highlight_rich(text, continue: true)
      @formatter.format(@lexer.lex(text, continue: continue)).html_safe
    rescue
      highlight_plain(text)
    end

    def link_dependencies(text, highlighted_text)
      Gitlab::DependencyLinker.process(blob_name, text, highlighted_text)
    end

    def rouge_formatter(options = {})
      options = options.reverse_merge(
        nowrap: true,
        cssclass: 'code highlight',
        lineanchors: true,
        lineanchorsid: 'LC'
      )

      Rouge::Formatters::HTMLGitlab.new(options)
    end
  end
end
