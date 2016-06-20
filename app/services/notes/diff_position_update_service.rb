module Notes
  class DiffPositionUpdateService < BaseService
    def execute(note)
      new_position = tracer.execute(note.position)

      # Don't update the position if the type doesn't match, since that means
      # the diff line commented on was changed, and the comment is now outdated
      if new_position && note.position != new_position && new_position.type == note.position.type
        note.position = new_position
      end

      note
    end

    private

    def tracer
      @tracer ||= Gitlab::Diff::PositionTracer.new(
        repository: project.repository,
        old_diff_refs: params[:old_diff_refs],
        new_diff_refs: params[:new_diff_refs],
        paths: params[:paths]
      )
    end
  end
end
