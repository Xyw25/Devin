# PR Comment Workflow

> Created: 2026-03-25

## Prerequisites

You need the repository ID and pull request ID. The base endpoint for all PR comment operations is:

```
{ADO_ORG_URL}/{ADO_PROJECT}/_apis/git/repositories/{repositoryId}/pullRequests/{pullRequestId}/threads
```

## 1. Create a General Comment Thread

Post a top-level comment visible in the PR overview.

```bash
curl -s -X POST \
  -u ":${ADO_PAT_CODE}" \
  -H "Content-Type: application/json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullRequests/${PR_ID}/threads?api-version=7.1" \
  -d "{
    \"comments\": [
      {
        \"parentCommentId\": 0,
        \"content\": \"${COMMENT_TEXT}\",
        \"commentType\": 1
      }
    ],
    \"status\": 1
  }"
```

**Comment type values:**
- `1` — Text (standard comment)
- `2` — Code change
- `3` — System

**Thread status values:**
- `1` — Active
- `2` — Fixed
- `3` — Won't Fix
- `4` — Closed
- `5` — By Design
- `6` — Pending

## 2. Create an Inline Code Comment

Add a comment anchored to a specific file and line range using `threadContext`.

```bash
curl -s -X POST \
  -u ":${ADO_PAT_CODE}" \
  -H "Content-Type: application/json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullRequests/${PR_ID}/threads?api-version=7.1" \
  -d "{
    \"comments\": [
      {
        \"parentCommentId\": 0,
        \"content\": \"${COMMENT_TEXT}\",
        \"commentType\": 1
      }
    ],
    \"threadContext\": {
      \"filePath\": \"/${FILE_PATH}\",
      \"rightFileStart\": {
        \"line\": ${START_LINE},
        \"offset\": 1
      },
      \"rightFileEnd\": {
        \"line\": ${END_LINE},
        \"offset\": 1
      }
    },
    \"status\": 1
  }"
```

Key fields in `threadContext`:
- `filePath` — path relative to the repo root, must start with `/`
- `rightFileStart` / `rightFileEnd` — line range on the right (new) side of the diff
- Use `leftFileStart` / `leftFileEnd` to comment on deleted lines

## 3. Reply to an Existing Thread

Add a reply to a thread by posting a comment with `parentCommentId` set to the ID of the comment you are replying to.

```bash
curl -s -X POST \
  -u ":${ADO_PAT_CODE}" \
  -H "Content-Type: application/json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullRequests/${PR_ID}/threads/${THREAD_ID}/comments?api-version=7.1" \
  -d "{
    \"parentCommentId\": ${PARENT_COMMENT_ID},
    \"content\": \"${REPLY_TEXT}\",
    \"commentType\": 1
  }"
```

Note the endpoint changes: you append `/{threadId}/comments` to post a reply within an existing thread.

## 4. Update Thread Status

Resolve, close, or reactivate a thread by updating its status.

```bash
curl -s -X PATCH \
  -u ":${ADO_PAT_CODE}" \
  -H "Content-Type: application/json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_ID}/pullRequests/${PR_ID}/threads/${THREAD_ID}?api-version=7.1" \
  -d "{
    \"status\": 2
  }"
```

Set `status` to `2` (Fixed) to mark a thread as resolved, or `1` (Active) to reopen it.

## Common Mistakes

1. **Wrong `commentType` value.** Using `commentType: 0` or omitting it can cause unexpected behavior. Always set it to `1` for text comments.
2. **Missing `parentCommentId` when replying.** Omitting `parentCommentId` creates a new root comment in the thread instead of a reply. Set it to the ID of the comment you want to reply to.
3. **Posting replies to the threads endpoint instead of the comments endpoint.** Replies go to `threads/{threadId}/comments`, not to `threads`.
4. **Inline comments without `threadContext`.** If you omit `threadContext`, the comment appears as a general comment, not anchored to code.
5. **File path missing leading slash.** The `filePath` in `threadContext` must begin with `/`.
