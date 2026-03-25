# Azure DevOps Pull Requests API Guide

> Created: 2026-03-25, Last updated: 2026-03-25
> API Version: 7.1
> Source: [Azure DevOps REST API — Pull Requests](https://learn.microsoft.com/en-us/rest/api/azure-devops/git/pull-requests)

---

## Base Endpoint

```
{ADO_ORG_URL}/{ADO_PROJECT}/_apis/git/repositories/{repoId}/pullrequests
```

---

## Operations

### Create PR

```
POST /{org}/{project}/_apis/git/repositories/{repoId}/pullrequests?api-version=7.1
Content-Type: application/json
```

**Body:**
```json
{
  "sourceRefName": "refs/heads/feature-branch",
  "targetRefName": "refs/heads/main",
  "title": "PR title",
  "description": "PR description in markdown",
  "reviewers": [
    {"id": "{AAD-Object-ID-GUID}"}
  ],
  "workItemRefs": [
    {"id": "12345"}
  ]
}
```

**Script:** `scripts/ado/pull-requests/create.sh <repo-id> <source> <target> <title> <description> [reviewer-ids] [work-item-ids]`

### Update PR

```
PATCH /{org}/{project}/_apis/git/repositories/{repoId}/pullrequests/{prId}?api-version=7.1
Content-Type: application/json
```

**Body (complete PR):**
```json
{
  "status": "completed",
  "completionOptions": {
    "deleteSourceBranch": true,
    "mergeStrategy": "squash"
  }
}
```

**Script:** `scripts/ado/pull-requests/update.sh <repo-id> <pr-id> <json-body>`

### Add Reviewer

```
PUT /{org}/{project}/_apis/git/repositories/{repoId}/pullrequests/{prId}/reviewers/{reviewerId}?api-version=7.1
Content-Type: application/json
```

**Body:**
```json
{"vote": 0}
```

Vote values: `10` (approved), `5` (approved with suggestions), `0` (no vote), `-5` (waiting), `-10` (rejected)

**Script:** `scripts/ado/pull-requests/add-reviewer.sh <repo-id> <pr-id> <reviewer-aad-id>`

### Get PR / List PRs

List active PRs for a repository:
```
GET /{org}/{project}/_apis/git/repositories/{repoId}/pullrequests?searchCriteria.status=active&api-version=7.1
```

Get a single PR by ID:
```
GET /{org}/{project}/_apis/git/repositories/{repoId}/pullrequests/{prId}?api-version=7.1
```

Additional search criteria parameters:
- `searchCriteria.status` — `active`, `completed`, `abandoned`, `all`
- `searchCriteria.creatorId` — filter by creator AAD ID
- `searchCriteria.reviewerId` — filter by reviewer AAD ID
- `searchCriteria.sourceRefName` — filter by source branch (e.g., `refs/heads/feature`)
- `searchCriteria.targetRefName` — filter by target branch

**Script:** `scripts/ado/pull-requests/get.sh`

### PR Comment Threads

```
POST /{org}/{project}/_apis/git/repositories/{repoId}/pullrequests/{prId}/threads?api-version=7.1
Content-Type: application/json
```

**Body (general comment):**
```json
{
  "comments": [
    {
      "parentCommentId": 0,
      "content": "Review comment text here",
      "commentType": 1
    }
  ],
  "status": 1
}
```

**Thread statuses:**
| Value | Status |
|-------|--------|
| `1` | Active |
| `2` | Fixed |
| `3` | Won't Fix |
| `4` | Closed |
| `5` | Pending |

**Inline code comments** — add `threadContext` to attach the comment to a specific file and line range:
```json
{
  "comments": [
    {
      "parentCommentId": 0,
      "content": "This variable should be renamed for clarity.",
      "commentType": 1
    }
  ],
  "status": 1,
  "threadContext": {
    "filePath": "/src/main.ts",
    "rightFileStart": {
      "line": 42,
      "offset": 1
    },
    "rightFileEnd": {
      "line": 42,
      "offset": 30
    }
  }
}
```

**Script:** `scripts/ado/pull-requests/add-comment.sh`

### Link Work Item to PR (Post-Creation)

To link a work item to an existing PR after creation, add an `ArtifactLink` relation on the work item using the PR artifact URI:

```
PATCH /{org}/{project}/_apis/wit/workitems/{workItemId}?api-version=7.1
Content-Type: application/json-patch+json
```

```json
[
  {
    "op": "add",
    "path": "/relations/-",
    "value": {
      "rel": "ArtifactLink",
      "url": "vstfs:///Git/PullRequestId/{projectId}%2F{repoId}%2F{prId}",
      "attributes": {
        "name": "Pull Request"
      }
    }
  }
]
```

Note: The artifact URI uses `%2F` (URL-encoded `/`) as the separator between projectId, repoId, and prId. All three values are GUIDs except prId which is an integer.

**Script:** `scripts/ado/pull-requests/link-work-item.sh`

---

## Critical Rules

### Branch Refs Must Include Full Prefix

```
refs/heads/main         (CORRECT)
main                    (WRONG — will fail)
refs/heads/feature/xyz  (CORRECT)
feature/xyz             (WRONG — will fail)
```

The `create.sh` script auto-adds the prefix if missing, but always be explicit.

### Reviewer ID Must Be AAD Object ID

The reviewer `id` field requires the **Azure Active Directory Object ID** (a GUID),
not the display name or email address.

```
"id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"    (CORRECT — AAD GUID)
"id": "John Smith"                                  (WRONG)
"id": "john@company.com"                            (WRONG)
```

### Work Item Links at Creation Time

Work items are linked via `workItemRefs` array during PR creation.
These appear as linked work items in the PR view.

---

## Merge Strategies

| Strategy | Description |
|----------|-------------|
| `noFastForward` | Create a merge commit (default) |
| `squash` | Squash all commits into one |
| `rebase` | Rebase source onto target |
| `rebaseMerge` | Rebase and create merge commit |

---

## PAT Required

`ADO_PAT_CODE` — Code (Repositories): Read (for creation, may need Write depending on org settings)
