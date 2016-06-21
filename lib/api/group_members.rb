module API
  class GroupMembers < Grape::API
    before { authenticate! }

    helpers do
      def ensure_member_does_not_exists!(group, user_id)
        if group.members.exists?(user_id: user_id)
          render_api_error!("Already exists", 409)
        end
      end

      def validate_access_level!(level)
        unless Gitlab::Access.options_with_owner.values.include?(level.to_i)
          render_api_error!("Wrong access level", 422)
        end
      end
    end

    resource :groups do
      # Get a list of group members viewable by the authenticated user.
      #
      # Parameters:
      #   id (required) - The ID of a group
      #   query         - Query string
      #   type          - Filter members by type:
      #                   - 'request' for requesters (only for group admins)
      #
      # Example Request:
      #  GET /groups/:id/members
      get ":id/members" do
        group = find_group(params[:id])

        members = group.members
        members =
          if can?(current_user, :admin_group, group)
            params[:type] == 'request' ? members.request : members
          else
            members.non_request
          end
        members = members.joins(:user).merge(User.search(params[:query])) if params[:query]
        users = Kaminari.paginate_array(members.map(&:user))

        present paginate(users), with: Entities::Member, source: group
      end

      # Get a group member
      #
      # Parameters:
      #   id (required) - The ID of a group
      #   user_id (required) - The ID of a user
      #
      # Example Request:
      #   GET /groups/:id/members/:user_id
      get ":id/members/:user_id" do
        group = find_group(params[:id])

        members = group.members
        members = members.non_request unless can?(current_user, :admin_group, group)
        member = members.find_by!(user_id: params[:user_id])

        present member.user, with: Entities::Member, member: member
      end

      # Add a user to the list of group members
      #
      # Parameters:
      #   id (required) - The ID of a group
      #   user_id (required) - The user ID
      #   access_level (required) - Access level
      #
      # Example Request:
      #  POST /groups/:id/members
      post ":id/members" do
        required_attributes! [:user_id, :access_level]
        group = find_group(params[:id])
        authorize! :admin_group, group
        ensure_member_does_not_exists!(group, params[:user_id])
        validate_access_level!(params[:access_level])

        group.add_user(params[:user_id], params[:access_level], current_user)
        member = group.members.find_by!(user_id: params[:user_id])

        present member.user, with: Entities::Member, member: member
      end

      # Update group member
      #
      # Parameters:
      #   id (required) - The ID of a group
      #   user_id (required) - The user ID of a group member
      #   access_level (required) - Access level
      #
      # Example Request:
      #   PUT /groups/:id/members/:user_id
      put ':id/members/:user_id' do
        required_attributes! [:user_id, :access_level]
        validate_access_level!(params[:access_level]) if params[:access_level]
        group = find_group(params[:id])
        authorize! :admin_group, group

        member = group.members.find_by!(user_id: params[:user_id])

        if member.update_attributes(access_level: params[:access_level])
          present member.user, with: Entities::Member, member: member
        else
          render_validation_error!(member)
        end
      end

      # Remove member.
      #
      # Parameters:
      #   id (required) - The ID of a group
      #   user_id (required) - The user ID of a group member
      #
      # Example Request:
      #   DELETE /groups/:id/members/:user_id
      delete ":id/members/:user_id" do
        required_attributes! [:user_id]
        group = find_group(params[:id])

        member = group.members.find_by!(user_id: params[:user_id])
        authorize! :destroy_group_member, member

        member.destroy
      end

      # Request access to the group with the developer access level
      #
      # Parameters:
      #   id (required) - The ID of a group
      #
      # Example Request:
      #  POST /groups/:id/members/request_access
      post ":id/members/request_access" do
        group = find_group(params[:id])
        ensure_member_does_not_exists!(group, current_user.id)

        requester = group.request_access(current_user)

        if requester.persisted?
          present requester.user, with: Entities::Member, member: requester
        else
          render_validation_error!(requester)
        end
      end

      # Approve a request access
      #
      # Parameters:
      #   id (required) - The ID of a group
      #   user_id (required) - The user ID of a group member
      #   access_level (optional) - Access level
      #
      # Example Request:
      #   PUT /groups/:id/members/:user_id/approve_access_request
      put ':id/members/:user_id/approve_access_request' do
        required_attributes! [:user_id]
        validate_access_level!(params[:access_level]) if params[:access_level]
        group = find_group(params[:id])

        requester = group.members.request.find_by!(user_id: params[:user_id])
        # We don't want to leak that this user requested access
        not_found! unless can?(current_user, :update_group_member, requester)

        requester.accept_request

        if params[:access_level]
          requester.update_attributes(access_level: params[:access_level])
        end

        status :created
        present requester.user, with: Entities::Member, member: requester
      end
    end
  end
end
