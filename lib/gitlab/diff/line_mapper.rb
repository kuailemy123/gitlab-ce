module Gitlab
  module Diff
    class LineMapper
      attr_accessor :parsed_lines

      def initialize(parsed_lines)
        @parsed_lines = parsed_lines
      end

      def old_to_new
        @old_to_new ||= Hash.new do |hash, old_line|
          diff_line = @parsed_lines.find { |diff_line| diff_line.old_line && diff_line.old_line >= old_line }
          diff_line ||= @parsed_lines.last

          if diff_line
            case diff_line.type
            when nil
              distance = diff_line.old_line - old_line
              new_line = diff_line.new_line - distance

              hash[old_line] = new_line
            when 'old'
              hash[old_line] = nil
            end
          else
            hash[old_line] = old_line
          end
        end
      end

      def new_to_old
        @new_to_old ||= Hash.new do |hash, new_line|
          diff_line = @parsed_lines.find { |diff_line| diff_line.new_line && diff_line.new_line >= new_line }
          diff_line ||= @parsed_lines.last

          if diff_line
            case diff_line.type
            when nil
              distance = diff_line.new_line - new_line
              old_line = diff_line.old_line - distance

              hash[new_line] = old_line
            when 'new'
              hash[new_line] = nil
            end
          else
            hash[new_line] = new_line
          end
        end
      end
    end
  end
end
