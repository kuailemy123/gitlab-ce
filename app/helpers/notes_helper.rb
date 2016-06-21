module NotesHelper
  # Helps to distinguish e.g. commit notes in mr notes list
  def note_for_main_target?(note)
    @noteable.class.name == note.noteable_type && !note.diff_note?
  end

  def note_target_fields(note)
    if note.noteable
      hidden_field_tag(:target_type, note.noteable.class.name.underscore) +
        hidden_field_tag(:target_id, note.noteable.id)
    end
  end

  def note_editable?(note)
    note.editable? && can?(current_user, :admin_note, note)
  end

  def noteable_json(noteable)
    {
      id: noteable.id,
      class: noteable.class.name,
      resources: noteable.class.table_name,
      project_id: noteable.project.id,
    }.to_json
  end

  def link_to_new_diff_note(line_code, line_type = nil)
    discussion_id = LegacyDiffNote.build_discussion_id(
      @comments_target[:noteable_type],
      @comments_target[:noteable_id] || @comments_target[:commit_id],
      line_code
    )

    data = {
      noteable_type: @comments_target[:noteable_type],
      noteable_id:   @comments_target[:noteable_id],
      commit_id:     @comments_target[:commit_id],
      line_type:     line_type,
      line_code:     line_code,
      note_type:     LegacyDiffNote.name,
      discussion_id: discussion_id
    }

    button_tag(class: 'btn add-diff-note js-add-diff-note-button',
               data: data,
               title: 'Add a comment to this line') do
      icon('comment-o')
    end
  end

  def link_to_reply_discussion(note, line_type = nil)
    return unless current_user

    data = {
      noteable_type: note.noteable_type,
      noteable_id:   note.noteable_id,
      commit_id:     note.commit_id,
      discussion_id: note.discussion_id,
      line_type:     line_type
    }

    if note.diff_note?
      data[:note_type] = note.type

      data.merge!(note.diff_attributes)
    end

    button_tag 'Reply...', class: 'btn btn-text-field js-discussion-reply-button',
                           data: data, title: 'Add a reply'
  end

  def diff_note_path(note)
    return unless note.diff_note?

    if note.for_merge_request? && note.active?
      diffs_namespace_project_merge_request_path(note.project.namespace, note.project, note.noteable, anchor: note.line_code)
    elsif note.for_commit?
      namespace_project_commit_path(note.project.namespace, note.project, note.noteable, anchor: note.line_code)
    end
  end
end
