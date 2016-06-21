require 'spec_helper'

describe API::GroupMembers, api: true  do
  include ApiHelpers

  let(:owner) { create(:user) }
  let(:reporter) { create(:user) }
  let(:developer) { create(:user) }
  let(:master) { create(:user) }
  let(:guest) { create(:user) }
  let(:requester) { create(:user) }
  let(:stranger) { create(:user) }

  let!(:group_with_members) do
    group = create(:group, :private)
    group.add_reporter(reporter)
    group.add_developer(developer)
    group.add_master(master)
    group.add_guest(guest)
    group.request_access(requester)
    group
  end

  let!(:group_no_members) { create(:group, :public) }

  before do
    group_with_members.add_owner owner
    group_no_members.add_owner owner
  end

  describe "GET /groups/:id/members" do
    context "when authenticated as a group member" do
      [:master, :developer, :reporter, :guest].each do |type|
        context "as a #{type}" do
          it 'does not include access requesters' do
            user = public_send(type)
            get api("/groups/#{group_with_members.id}/members", user)

            expect(response.status).to eq(200)
            expect(json_response).to be_an Array
            expect(json_response.size).to eq(5)
          end
        end
      end

      context 'as a owner' do
        it 'includes access requesters' do
          get api("/groups/#{group_with_members.id}/members", owner)

          expect(response.status).to eq(200)
          expect(json_response).to be_an Array
          expect(json_response.size).to eq(6)
        end

        describe 'filters' do
          context 'with the `type=request` filter' do
            it 'returns access requesters only' do
              get api("/groups/#{group_with_members.id}/members?type=request", owner)

              expect(response.status).to eq(200)
              expect(json_response).to be_an Array
              expect(json_response.size).to eq(1)
            end
          end
        end
      end

      it 'returns 404 if current user is not a group member' do
        get api("/groups/#{group_with_members.id}/members", stranger)

        expect(response.status).to eq(404)
      end
    end
  end

  describe "GET /groups/:id/members/:user_id" do
    it 'exposes known attributes' do
      get api("/groups/#{group_with_members.id}/members/#{requester.id}", owner)

      expect(response.status).to eq(200)
      # User attributes
      expect(json_response['id']).to eq(requester.id)
      expect(json_response['name']).to eq(requester.name)
      expect(json_response['username']).to eq(requester.username)
      expect(json_response['state']).to eq(requester.state)
      expect(json_response['avatar_url']).to eq(requester.avatar_url)
      expect(json_response['web_url']).to eq(Gitlab::Routing.url_helpers.user_url(requester))

      # Member attributes
      expect(json_response['access_level']).to eq(GroupMember::DEVELOPER)
      expect(json_response['requested_at']).to be_present
    end

    it "returns a 404 error if user cannot see requester" do
      get api("/groups/#{group_with_members.id}/members/#{requester.id}", master)

      expect(response.status).to eq(404)
    end

    it "returns a 404 error if user id not found" do
      get api("/groups/#{group_with_members.id}/members/1234", owner)

      expect(response.status).to eq(404)
    end
  end

  describe "POST /groups/:id/members" do
    context "when not a member of the group" do
      it "should not add guest as member of group_no_members when adding being done by person outside the group" do
        post api("/groups/#{group_no_members.id}/members", reporter), user_id: guest.id, access_level: GroupMember::MASTER
        expect(response.status).to eq(403)
      end
    end

    context "when a member of the group" do
      it "should return ok and add new member" do
        new_user = create(:user)

        expect do
          post api("/groups/#{group_no_members.id}/members", owner), user_id: new_user.id, access_level: GroupMember::MASTER
        end.to change { group_no_members.members.count }.by(1)

        expect(response.status).to eq(201)
        expect(json_response['name']).to eq(new_user.name)
        expect(json_response['access_level']).to eq(GroupMember::MASTER)
      end

      it "should not allow guest to modify group members" do
        new_user = create(:user)

        expect do
          post api("/groups/#{group_with_members.id}/members", guest), user_id: new_user.id, access_level: GroupMember::MASTER
        end.not_to change { group_with_members.members.count }

        expect(response.status).to eq(403)
      end

      it "should return error if member already exists" do
        post api("/groups/#{group_with_members.id}/members", owner), user_id: master.id, access_level: GroupMember::MASTER
        expect(response.status).to eq(409)
      end

      it "should return a 400 error when user id is not given" do
        post api("/groups/#{group_no_members.id}/members", owner), access_level: GroupMember::MASTER
        expect(response.status).to eq(400)
      end

      it "should return a 400 error when access level is not given" do
        post api("/groups/#{group_no_members.id}/members", owner), user_id: master.id
        expect(response.status).to eq(400)
      end

      it "should return a 422 error when access level is not known" do
        post api("/groups/#{group_no_members.id}/members", owner), user_id: master.id, access_level: 1234
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'PUT /groups/:id/members/:user_id' do
    context 'when not a member of the group' do
      it 'returns a 409 error if the user is not a group member' do
        put(
          api("/groups/#{group_no_members.id}/members/#{developer.id}",
              owner), access_level: GroupMember::MASTER
        )
        expect(response.status).to eq(404)
      end
    end

    context 'when a member of the group' do
      it 'returns a 200 and update member access level' do
        put(
          api("/groups/#{group_with_members.id}/members/#{reporter.id}", owner),
          access_level: GroupMember::MASTER
        )

        expect(response.status).to eq(200)
        expect(json_response['access_level']).to eq(GroupMember::MASTER)
      end

      it 'does not allow guest to modify group members' do
        put(
          api("/groups/#{group_with_members.id}/members/#{developer.id}", guest),
          access_level: GroupMember::MASTER
        )

        expect(response.status).to eq(403)

        get api("/groups/#{group_with_members.id}/members/#{developer.id}", owner)

        expect(json_response['access_level']).to eq(GroupMember::DEVELOPER)
      end

      it 'returns a 400 error when access level is not given' do
        put(
          api("/groups/#{group_with_members.id}/members/#{master.id}", owner)
        )

        expect(response.status).to eq(400)
      end

      it 'returns a 422 error when access level is not known' do
        put(
          api("/groups/#{group_with_members.id}/members/#{master.id}", owner),
          access_level: 1234
        )

        expect(response.status).to eq(422)
      end
    end
  end

  describe 'DELETE /groups/:id/members/:user_id' do
    context 'when not a member of the group' do
      it "should not delete guest's membership of group_with_members" do
        random_user = create(:user)
        delete api("/groups/#{group_with_members.id}/members/#{owner.id}", random_user)

        expect(response.status).to eq(404)
      end
    end

    context "when a member of the group" do
      it "deletes guest's membership of group" do
        expect do
          delete api("/groups/#{group_with_members.id}/members/#{guest.id}", owner)
        end.to change { group_with_members.members.count }.by(-1)

        expect(response.status).to eq(200)
      end

      it "returns a 404 error when user id is not known" do
        delete api("/groups/#{group_with_members.id}/members/1328", owner)

        expect(response.status).to eq(404)
      end

      it "does not allow guest to modify group members" do
        delete api("/groups/#{group_with_members.id}/members/#{master.id}", guest)

        expect(response.status).to eq(403)
      end
    end
  end

  describe 'POST /groups/:id/members/request_access' do
    context 'when not a member of the group' do
      it 'request access to the group and returns the requester' do
        expect do
          post api("/groups/#{group_no_members.id}/members/request_access", requester)
        end.to change { group_no_members.members.request.count }.by(1)

        expect(response.status).to eq(201)
        expect(json_response['name']).to eq(requester.name)
        expect(json_response['access_level']).to eq(GroupMember::DEVELOPER)
        expect(json_response['requested_at']).to be_present
      end
    end

    context 'when already a member of the group' do
      it 'returns a 409 error' do
        expect do
          post api("/groups/#{group_no_members.id}/members/request_access", owner)
        end.not_to change { group_no_members.members.count }

        expect(response.status).to eq(409)
      end
    end
  end

  describe 'PUT /groups/:id/members/:user_id/approve_access_request' do
    context 'when user is a requester' do
      before do
        group_no_members.request_access(requester)
      end

      context 'and current user can update group members' do
        it 'approve the request and returns the member' do
          expect do
            put api("/groups/#{group_no_members.id}/members/#{requester.id}/approve_access_request", owner), access_level: GroupMember::REPORTER
          end.to change { group_no_members.members.non_request.count }.by(1)

          expect(response.status).to eq(201)
          expect(json_response['name']).to eq(requester.name)
          expect(json_response['access_level']).to eq(GroupMember::REPORTER)
          expect(json_response['requested_at']).to be_nil
        end
      end

      context 'and current user cannot update group members' do
        it 'returns 404' do
          expect do
            put api("/groups/#{group_no_members.id}/members/#{requester.id}/approve_access_request", master)
          end.not_to change { group_no_members.members.count }

          expect(response.status).to eq(404)
        end
      end
    end

    context 'when already a member of the group' do
      it 'returns a 404 error' do
        expect do
          put api("/groups/#{group_no_members.id}/members/#{owner.id}/approve_access_request", owner)
        end.not_to change { group_no_members.members.count }

        expect(response.status).to eq(404)
      end
    end
  end
end
