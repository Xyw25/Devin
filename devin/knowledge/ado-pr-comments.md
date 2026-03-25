# ADO Pull Request Comments — Knowledge Item

## Trigger Description
ADO pull request comment threads: thread model, status values, inline code comments with file anchors

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

Use `scripts/ado/pull-requests/add-comment.sh` to create a general comment thread. The script POSTs to the threads endpoint with a JSON body containing:
- `comments` — array with `parentCommentId` (0 for top-level), `content` (the text), and `commentType` (1 for user comments)
- `status` — integer thread status (see table above)

## Inline Code Comment

Same endpoint as general threads, but includes a `threadContext` object to anchor the comment to a specific file and line range:
- `filePath` — the file path in the repo (e.g., `/src/auth/login.ts`)
- `rightFileStart` / `rightFileEnd` — objects with `line` and `offset` specifying the code range

Without `threadContext`, the comment becomes a general (non-inline) comment. See `api-gotchas.md` G27 for details.

## Updating Thread Status

To update an existing thread's status (e.g., mark as resolved), PATCH the thread endpoint:

```
PATCH /_apis/git/repositories/{repoId}/pullrequests/{prId}/threads/{threadId}?api-version=7.1
```

The body is simply `{"status": 2}` (using the integer status value). This is separate from adding a reply to the thread.

## Rules

- `parentCommentId: 0` means a top-level comment in the thread
- To reply to an existing thread, POST to the specific thread's comments endpoint
- PR comments use `application/json`, NOT `json-patch+json` — see `api-gotchas.md` G2
- Thread status is on the thread, not individual comments
- Status values are integers, not strings — see `api-gotchas.md` G26

## Scripts

- `scripts/ado/pull-requests/add-comment.sh` — add a general comment thread
- For inline comments, use `add-comment.sh` with `threadContext` in the body (see the Inline Code Comment section above)
