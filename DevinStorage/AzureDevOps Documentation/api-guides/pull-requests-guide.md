# Azure DevOps Pull Requests API Guide

> Created: 2026-03-25
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
