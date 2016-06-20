# TODO (douwe): Make this less terrible
module NoteOnDiff
  def diff_note?
    true
  end

  def diff_file
    raise NotImplementedError
  end

  def diff_line
    raise NotImplementedError
  end

  def for_line?(line)
    raise NotImplementedError
  end

  def diff_attributes
    raise NotImplementedError
  end

  def blob
    diff_file.try(:blob)
  end

  def highlighted_diff_lines
    diff_file.highlighted_diff_lines
  end

  def truncated_diff_lines
    max_number_of_lines = 16
    prev_match_line = nil
    prev_lines = []

    highlighted_diff_lines.each do |line|
      if line.type == "match"
        prev_lines.clear
        prev_match_line = line
      else
        prev_lines << line

        break if for_line?(line)

        prev_lines.shift if prev_lines.length >= max_number_of_lines
      end
    end

    prev_lines
  end
end
