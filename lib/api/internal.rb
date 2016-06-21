module API
  # Internal access API
  class Internal < Grape::API
    before { authenticate_by_gitlab_shell_token! }

    namespace 'internal' do
      # Check if git command is allowed to project
      #
      # Params:
      #   key_id - ssh key id for Git over SSH
      #   user_id - user id for Git over HTTP
      #   project - project path with namespace
      #   action - git action (git-upload-pack or git-receive-pack)
      #   ref - branch name
      #   forced_push - forced_push
      #

      helpers do
        def wiki?
          @wiki ||= params[:project].end_with?('.wiki') &&
            !Project.find_with_namespace(params[:project])
        end

        def project
          @project ||= begin
            project_path = params[:project]

            # Check for *.wiki repositories.
            # Strip out the .wiki from the pathname before finding the
            # project. This applies the correct project permissions to
            # the wiki repository as well.
            project_path.chomp!('.wiki') if wiki?

            Project.find_with_namespace(project_path)
          end
        end
      end

      post "/allowed" do
        Gitlab::Metrics.action = 'Grape#/internal/allowed'

        status 200

        actor =
          if params[:key_id]
            Key.find_by(id: params[:key_id])
          elsif params[:user_id]
            User.find_by(id: params[:user_id])
          end

        access =
          if wiki?
            Gitlab::GitAccessWiki.new(actor, project)
          else
            Gitlab::GitAccess.new(actor, project)
          end

        access_status = access.check(params[:action], params[:changes])

        response = { status: access_status.status, message: access_status.message }

        if access_status.status
          # Return the repository full path so that gitlab-shell has it when
          # handling ssh commands
          response[:repository_path] = project.repository.path_to_repo
        end

        response
      end

      get "/repository_storage_paths" do
        Gitlab.config.repositories.storages.values
      end

      #
      # Discover user by ssh key
      #
      get "/discover" do
        key = Key.find(params[:key_id])
        present key.user, with: Entities::UserSafe
      end

      get "/check" do
        {
          api_version: API.version,
          gitlab_version: Gitlab::VERSION,
          gitlab_rev: Gitlab::REVISION,
        }
      end

      get "/broadcast_message" do
        if message = BroadcastMessage.current
          present message, with: Entities::BroadcastMessage
        else
          {}
        end
      end
    end
  end
end
