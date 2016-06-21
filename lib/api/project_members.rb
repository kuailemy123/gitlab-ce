module API
  class ProjectMembers < Grape::API
    before { authenticate! }

    resource :projects do
      # Get a list of project members viewable by the authenticated user.
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   query         - Query string
      # Example Request:
      #   GET /projects/:id/members
      get ":id/members" do
        members = user_project.members
        members = members.non_request unless can?(current_user, :admin_project, user_project)
        members = members.joins(:user).merge(User.search(params[:query])) if params[:query]
        users = Kaminari.paginate_array(members.map(&:user))

        present paginate(users), with: Entities::Member, source: user_project
      end

      # Get a project member
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   user_id (required) - The ID of a user
      # Example Request:
      #   GET /projects/:id/members/:user_id
      get ":id/members/:user_id" do
        members = user_project.members
        members = members.non_request unless can?(current_user, :admin_project, user_project)
        member = members.find_by!(user_id: params[:user_id])

        present member, with: Entities::Member, member: member
      end

      # Add a new project team member
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   user_id (required) - The user ID
      #   access_level (required) - Project access level
      # Example Request:
      #   POST /projects/:id/members
      post ":id/members" do
        authorize! :admin_project, user_project
        required_attributes! [:user_id, :access_level]

        # either the user is already a team member or a new one
        member = user_project.members.find_by(user_id: params[:user_id])
        unless member
          member = user_project.members.new(
            user_id: params[:user_id],
            access_level: params[:access_level]
          )
        end

        if member.save
          present member.user, with: Entities::Member, member: member
        else
          render_validation_error!(member)
        end
      end

      # Update a project member
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   user_id (required) - The user ID of a project member
      #   access_level (required) - Project access level
      # Example Request:
      #   PUT /projects/:id/members/:user_id
      put ":id/members/:user_id" do
        authorize! :admin_project, user_project
        required_attributes! [:user_id, :access_level]

        member = user_project.members.find_by(user_id: params[:user_id])
        not_found! unless member

        if member.update_attributes(access_level: params[:access_level])
          present member.user, with: Entities::Member, member: member
        else
          render_validation_error!(member)
        end
      end

      # Remove a project member
      #
      # Parameters:
      #   id (required) - The ID of a project
      #   user_id (required) - The user ID of a project member
      # Example Request:
      #   DELETE /projects/:id/members/:user_id
      delete ":id/members/:user_id" do
        member = user_project.members.find_by(user_id: params[:user_id])
        authorize! :destroy_project_member, member

        if project_member
          project_member.destroy
        else
          not_found!
        end
      end
    end
  end
end
