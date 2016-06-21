# Groups

## List groups

Get a list of groups. (As user: my groups, as admin: all groups)

```
GET /groups
```

```json
[
  {
    "id": 1,
    "name": "Foobar Group",
    "path": "foo-bar",
    "description": "An interesting group"
  }
]
```

You can search for groups by name or path, see below.


## List a group's projects

Get a list of projects in this group.

```
GET /groups/:id/projects
```

Parameters:

- `archived` (optional) - if passed, limit by archived status
- `visibility` (optional) - if passed, limit by visibility `public`, `internal`, `private`
- `order_by` (optional) - Return requests ordered by `id`, `name`, `path`, `created_at`, `updated_at` or `last_activity_at` fields. Default is `created_at`
- `sort` (optional) - Return requests sorted in `asc` or `desc` order. Default is `desc`
- `search` (optional) - Return list of authorized projects according to a search criteria
- `ci_enabled_first` - Return projects ordered by ci_enabled flag. Projects with enabled GitLab CI go first

```json
[
  {
    "id": 4,
    "description": null,
    "default_branch": "master",
    "public": false,
    "visibility_level": 0,
    "ssh_url_to_repo": "git@example.com:diaspora/diaspora-client.git",
    "http_url_to_repo": "http://example.com/diaspora/diaspora-client.git",
    "web_url": "http://example.com/diaspora/diaspora-client",
    "tag_list": [
      "example",
      "disapora client"
    ],
    "owner": {
      "id": 3,
      "name": "Diaspora",
      "created_at": "2013-09-30T13: 46: 02Z"
    },
    "name": "Diaspora Client",
    "name_with_namespace": "Diaspora / Diaspora Client",
    "path": "diaspora-client",
    "path_with_namespace": "diaspora/diaspora-client",
    "issues_enabled": true,
    "merge_requests_enabled": true,
    "builds_enabled": true,
    "wiki_enabled": true,
    "snippets_enabled": false,
    "created_at": "2013-09-30T13: 46: 02Z",
    "last_activity_at": "2013-09-30T13: 46: 02Z",
    "creator_id": 3,
    "namespace": {
      "created_at": "2013-09-30T13: 46: 02Z",
      "description": "",
      "id": 3,
      "name": "Diaspora",
      "owner_id": 1,
      "path": "diaspora",
      "updated_at": "2013-09-30T13: 46: 02Z"
    },
    "archived": false,
    "avatar_url": "http://example.com/uploads/project/avatar/4/uploads/avatar.png"
  }
]
```

## Details of a group

Get all details of a group.

```
GET /groups/:id
```

Parameters:

- `id` (required) - The ID or path of a group

## New group

Creates a new project group. Available only for users who can create groups.

```
POST /groups
```

Parameters:

- `name` (required) - The name of the group
- `path` (required) - The path of the group
- `description` (optional) - The group's description
- `visibility_level` (optional) - The group's visibility. 0 for private, 10 for internal, 20 for public.

## Transfer project to group

Transfer a project to the Group namespace. Available only for admin

```
POST  /groups/:id/projects/:project_id
```

Parameters:

- `id` (required) - The ID or path of a group
- `project_id` (required) - The ID of a project

## Update group

Updates the project group. Only available to group owners and administrators.

```
PUT /groups/:id
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id` | integer | yes | The ID of the group |
| `name` | string | no | The name of the group |
| `path` | string | no | The path of the group |
| `description` | string | no | The description of the group |
| `visibility_level` | integer | no | The visibility level of the group. 0 for private, 10 for internal, 20 for public. |

```bash
curl -X PUT -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" "https://gitlab.example.com/api/v3/groups/5?name=Experimental"

```

Example response:

```json
{
  "id": 5,
  "name": "Experimental",
  "path": "h5bp",
  "description": "foo",
  "visibility_level": 10,
  "avatar_url": null,
  "web_url": "http://gitlab.example.com/groups/h5bp",
  "projects": [
    {
      "id": 9,
      "description": "foo",
      "default_branch": "master",
      "tag_list": [],
      "public": false,
      "archived": false,
      "visibility_level": 10,
      "ssh_url_to_repo": "git@gitlab.example.com/html5-boilerplate.git",
      "http_url_to_repo": "http://gitlab.example.com/h5bp/html5-boilerplate.git",
      "web_url": "http://gitlab.example.com/h5bp/html5-boilerplate",
      "name": "Html5 Boilerplate",
      "name_with_namespace": "Experimental / Html5 Boilerplate",
      "path": "html5-boilerplate",
      "path_with_namespace": "h5bp/html5-boilerplate",
      "issues_enabled": true,
      "merge_requests_enabled": true,
      "wiki_enabled": true,
      "builds_enabled": true,
      "snippets_enabled": true,
      "created_at": "2016-04-05T21:40:50.169Z",
      "last_activity_at": "2016-04-06T16:52:08.432Z",
      "shared_runners_enabled": true,
      "creator_id": 1,
      "namespace": {
        "id": 5,
        "name": "Experimental",
        "path": "h5bp",
        "owner_id": null,
        "created_at": "2016-04-05T21:40:49.152Z",
        "updated_at": "2016-04-07T08:07:48.466Z",
        "description": "foo",
        "avatar": {
          "url": null
        },
        "share_with_group_lock": false,
        "visibility_level": 10
      },
      "avatar_url": null,
      "star_count": 1,
      "forks_count": 0,
      "open_issues_count": 3,
      "public_builds": true
    }
  ]
}
```

## Remove group

Removes group with all projects inside.

```
DELETE /groups/:id
```

Parameters:

- `id` (required) - The ID or path of a user group

## Search for group

Get all groups that match your string in their name or path.

```
GET /groups?search=foobar
```

```json
[
  {
    "id": 1,
    "name": "Foobar Group",
    "path": "foo-bar",
    "description": "An interesting group"
  }
]
```

## Group members

**Group access levels**

The group access levels are defined in the `Gitlab::Access` module. Currently, these levels are recognized:

```
GUEST     = 10
REPORTER  = 20
DEVELOPER = 30
MASTER    = 40
OWNER     = 50
```

### List group members

Gets a list of group members viewable by the authenticated user.

- Returns `200` if the request succeeds.

```
GET /groups/:id/members
GET /groups/:id/members?type=request
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `type`    | string | no     | Return all members or just those that are access requesters, using `request` |

```bash
curl -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v3/groups/:id/members
```

Example response:

```json
[
  {
    "id": 1,
    "username": "raymond_smith",
    "name": "Raymond Smith",
    "state": "active",
    "created_at": "2012-10-22T14:13:35Z",
    "access_level": 30,
    "requested_at": null
  },
  {
    "id": 2,
    "username": "john_doe",
    "name": "John Doe",
    "state": "active",
    "created_at": "2012-10-22T14:13:35Z",
    "access_level": 30,
    "requested_at": "2012-10-22T14:13:35Z"
  }
]
```

### Get group member

Gets a group member.

- Returns `200` if the request succeeds.
- Returns `404` if the member cannot be found.

```
GET /groups/:id/members/:user_id
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`      | integer | yes   | The ID or path of a group |
| `user_id` | integer | yes   | The ID of a user |

```bash
curl -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v3/groups/:id/members/:user_id
```

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "created_at": "2012-10-22T14:13:35Z",
  "access_level": 30,
  "requested_at": null
}
```

### Add group member

Adds a user to the list of group members.

- Returns `201` if the request succeeds.
- Returns `403` if the authenticated user cannot create the member.
- Returns `409` if given user is already a group member.
- Returns `422` if given access level is not acceptable.

```
POST /groups/:id/members
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`      | integer | yes   | The ID or path of a group |
| `user_id` | integer | yes   | The ID of a user |
| `access_level` | integer | yes | An access level |

```bash
curl -X POST -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v3/groups/:id/members/:user_id?access_level=30
```

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "created_at": "2012-10-22T14:13:35Z",
  "access_level": 30,
  "requested_at": null
}
```

### Edit group member

Updates a group member.

- Returns `200` if the request succeeds.
- Returns `400` if the updated member is not valid.
- Returns `403` if the authenticated user cannot update the member.
- Returns `404` if the member cannot be found.
- Returns `422` if given access level is not acceptable.

```
PUT /groups/:id/members/:user_id
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`      | integer | yes   | The ID or path of a group |
| `user_id` | integer | yes   | The ID of a user |
| `access_level` | integer | yes | An access level |

```bash
curl -X PUT -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v3/groups/:id/members/:user_id?access_level=40
```

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "created_at": "2012-10-22T14:13:35Z",
  "access_level": 40,
  "requested_at": null
}
```

### Remove group member

Removes user from group members.

- Returns `200` if the request succeeds.
- Returns `403` if the authenticated user cannot remove the member.
- Returns `404` if the member cannot be found.

```
DELETE /groups/:id/members/:user_id
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`      | integer | yes   | The ID or path of a group |
| `user_id` | integer | yes   | The ID of a user |

```bash
curl -X DELETE -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v3/groups/:id/members/:user_id
```

### Request access to a group

Requests access for the authenticated user to a group.

- Returns `201` if the request succeeds.
- Returns `400` if the request does not succeed.
- Returns `409` if given user is already a group member.

```
POST /groups/:id/members/request_access
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`      | integer | yes   | The ID or path of a group |

```bash
curl -X POST -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v3/groups/:id/members/request_access
```

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "created_at": "2012-10-22T14:13:35Z",
  "access_level": 30,
  "requested_at": "2012-10-22T14:13:35Z"
}
```

### Approve access request to a group

Approve an access request for the given user to a group.

- Returns `201` if the request succeeds.
- Returns `400` if the request does not succeed.
- Returns `404` if the requester cannot be found or the current user is not
  allowed to approve access requests.
- Returns `422` if given access level is not acceptable.

```
PUT /groups/:id/members/:user_id/approve_access_request
```

| Attribute | Type | Required | Description |
| --------- | ---- | -------- | ----------- |
| `id`      | integer | yes   | The ID or path of a group |
| `user_id` | integer | yes   | The ID of a user |
| `access_level` | integer | no | An access level |

```bash
curl -X PUT -H "PRIVATE-TOKEN: 9koXpg98eAheJpvBs5tK" https://gitlab.example.com/api/v3/groups/:id/members/:user_id/approve_access_request?access_level=20
```

```json
{
  "id": 1,
  "username": "raymond_smith",
  "name": "Raymond Smith",
  "state": "active",
  "created_at": "2012-10-22T14:13:35Z",
  "access_level": 20,
  "requested_at": null
}
```

## Namespaces in groups

By default, groups only get 20 namespaces at a time because the API results are paginated.

To get more (up to 100), pass the following as an argument to the API call:
```
/groups?per_page=100
```

And to switch pages add:
```
/groups?per_page=100&page=2
```
