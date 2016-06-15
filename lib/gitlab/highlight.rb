module Gitlab
  class Highlight
    def self.highlight(blob_name, blob_content, plain: false)
      new(blob_name, blob_content).
        highlight(blob_content, continue: false, plain: plain)
    end

    def self.highlight_lines(repository, ref, file_name)
      blob = repository.blob_at(ref, file_name)
      return [] unless blob

      blob.load_all_data!(repository)
      highlight(file_name, blob.data).lines.map!(&:html_safe)
    end

    def initialize(blob_name, blob_content)
      @formatter = rouge_formatter
      @lexer = Rouge::Lexer.guess(filename: blob_name, source: blob_content).new rescue Rouge::Lexers::PlainText
    end

    def highlight(text, continue: true, plain: false)
      lexer = @lexer

      if plain
        lexer = Rouge::Lexers::PlainText
        continue = false
      end

      @formatter.format(@lexer.lex(text, continue: continue)).html_safe
    rescue
      @formatter.format(Rouge::Lexers::PlainText.lex(text)).html_safe
    end

    private

    def rouge_formatter(options = {})
      Rouge::Formatters::HTMLGitlab.new
    end
  end
end
