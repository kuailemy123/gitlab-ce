class GitHooksService
  PreReceiveError = Class.new(StandardError)

  def execute(user, repo_path, oldrev, newrev, ref)
    @repo_path  = repo_path
    @user       = Gitlab::GlId.gl_id(user)
    @oldrev     = oldrev
    @newrev     = newrev
    @ref        = ref

    %w(pre-receive update).each do |hook_name|
      successful_exit, errors = run_hook(hook_name)
      unless successful_exit
        if errors.present?
          raise PreReceiveError.new("Git operation was rejected by #{hook_name} hook with errors: #{errors.to_sentence}")
        else
          raise PreReceiveError.new("Git operation was rejected by #{hook_name} hook.")
        end
      end
    end

    yield

    run_hook('post-receive')
  end

  private

  def run_hook(name)
    hook = Gitlab::Git::Hook.new(name, @repo_path)
    hook.trigger(@user, @oldrev, @newrev, @ref)
  end
end
