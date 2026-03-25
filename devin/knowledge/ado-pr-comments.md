# ADO Pull Request Comments — Knowledge Item

## Trigger Description
PR comment, pull request thread, code review comment, add comment to PR

## PR Comment Model

PR comments in ADO are organized as **threads**, not flat comments.
Each thread has a status and contains one or more comments.

### Thread Statuses

| Status | Value | Meaning |
|--------|-------|---------|
| active | 1 | Open discussion |
| fixed | 2 | Resolved by author |
| wontFix | 3 | Won't address |
| closed | 4 | Closed by reviewer |
| pending | 5 | Awaiting response |

### Comment Types

| Type | Value | Usage |
|------|-------|-------|
| system | 0 | Auto-generated (merge, status changes) |
| text | 1 | User-created comments |

## General Thread (Non-Inline)

```
POST /_apis/git/repositories/{repoId}/pullrequests/{prId}/threads?api-version=7.1
Content-Type: application/json
```

Body:
```json
{
  "comments": [{"parentCommentId": 0, "content": "Comment text", "commentType": 1}],
  "status": 1
}
```

## Inline Code Comment

Same endpoint, but add `threadContext` to anchor to a file and line:

```json
{
  "comments": [{"parentCommentId": 0, "content": "Comment text", "commentType": 1}],
  "status": 1,
  "threadContext": {
    "filePath": "/src/auth/login.ts",
    "rightFileStart": {"line": 42, "offset": 1},
    "rightFileEnd": {"line": 42, "offset": 50}
  }
}
```

## Rules

- `parentCommentId: 0` means a top-level comment in the thread
- To reply to an existing thread, POST to the specific thread's comments endpoint
- PR comments use `application/json`, NOT `json-patch+json`
- Thread status is on the thread, not individual comments

## Scripts

- `scripts/ado/pull-requests/add-comment.sh` — add a general comment thread
