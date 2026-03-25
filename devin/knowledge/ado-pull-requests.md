# ADO Pull Requests — Knowledge Item

## API Endpoint

```
Base: {ADO_ORG_URL}/{ADO_PROJECT}/_apis/git/repositories/{repoId}/pullrequests
API version: api-version=7.1
```

## Creating a PR

```
POST /{org}/{project}/_apis/git/repositories/{repoId}/pullrequests?api-version=7.1
Content-Type: application/json
{
  "sourceRefName": "refs/heads/{source-branch}",
  "targetRefName": "refs/heads/{target-branch}",
  "title": "PR title",
  "description": "PR description in markdown",
  "reviewers": [
    {
      "id": "{AAD-Object-ID-GUID}"
    }
  ],
  "workItemRefs": [
    {
      "id": "{work-item-id}"
    }
  ]
}
```

## Critical Rules

- **Branch refs must include full prefix:** `refs/heads/main` not just `main`
- **Reviewer ID must be AAD Object ID (GUID):** not display name, not email address
- **Work item links** are added via `workItemRefs` array at creation time

## Updating a PR

```
PATCH /{org}/{project}/_apis/git/repositories/{repoId}/pullrequests/{prId}?api-version=7.1
Content-Type: application/json
{
  "status": "completed",
  "completionOptions": {
    "deleteSourceBranch": true,
    "mergeStrategy": "squash"
  }
}
```

## Adding a Reviewer

```
PUT /{org}/{project}/_apis/git/repositories/{repoId}/pullrequests/{prId}/reviewers/{reviewerId}?api-version=7.1
Content-Type: application/json
{
  "vote": 0
}
```

## Scripts

- `scripts/ado/pull-requests/create.sh` — POST new PR
- `scripts/ado/pull-requests/update.sh` — PATCH PR status
- `scripts/ado/pull-requests/add-reviewer.sh` — PUT reviewer
