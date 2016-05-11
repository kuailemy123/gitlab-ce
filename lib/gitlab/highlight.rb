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
      result = if plain
                 @formatter.format(Rouge::Lexers::PlainText.lex(text)).html_safe
               else
                 @formatter.format(@lexer.lex(text, continue: continue)).html_safe
               end

      link_dependencies(result)
    rescue
      @formatter.format(Rouge::Lexers::PlainText.lex(text)).html_safe
    end

    private

    def link_dependencies(highlighted_text)
      Gitlab::DependencyLinker.process(blob_name, highlighted_text)
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
