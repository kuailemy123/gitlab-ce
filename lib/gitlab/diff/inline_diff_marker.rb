module Gitlab
  module Diff
    class InlineDiffMarker < Gitlab::StringRangeMarker
      def mark(line_inline_diffs)
        super do |text, left:, right:|
          class_names = ["idiff"]
          class_names << "left"   if left
          class_names << "right"  if right

          "<span class='#{class_names.join(" ")}'>#{text}</span>"
        end
      end
    end
  end
end
