require 'cgi'

module Rouge
  module Formatters
    class HTMLGitlab < Rouge::Formatters::HTML
      tag 'html_gitlab'

      # Creates a new <tt>Rouge::Formatter::HTMLGitlab</tt> instance.
      #
      # [+linenostart+]     The line number for the first line (default: 1).
      def initialize(linenostart: 1)
        @linenostart = linenostart
      end

      def stream(tokens, &b)
        line_number = @linenostart

        token_lines(tokens) do |line|
          yield "<span id=\"LC#{line_number}\" class=\"line\">"
          line.each { |tok, val| yield span(tok, val) }
          yield "</span>\n"

          line_number += 1
        end
      end
    end
  end
end
