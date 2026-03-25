# ADO Error Handling — Operations Guide

> Created: 2026-03-25
> Source: Internal experience and Azure DevOps REST API documentation

---

## First Rule

When any ADO API call fails:
1. **Check `docs/error-catalog.md` FIRST** — it contains every error previously encountered
2. Check this guide for common patterns
3. Apply the fix
4. If the error is new, add it to `docs/error-catalog.md` after resolution
5. **Never search online for ADO API troubleshooting**

---

## Error Diagnosis by HTTP Status Code

### 400 Bad Request

| Cause | How to Identify | Fix |
|-------|----------------|-----|
| Wrong Content-Type | Response mentions "unsupported media type" | Use `application/json-patch+json` for work item ops |
| Invalid field name | Response mentions "field does not exist" | Field names are case-sensitive: `System.Title` |
| Malformed JSON Patch | Response mentions "invalid patch document" | Ensure `op`, `path`, and `value` are all present |
| Missing `refs/heads/` | Response mentions "invalid ref" | Branch refs need `refs/heads/` prefix |
| Invalid area path | Response mentions "area path" | Use backslash separator: `Project\Team\Area` |
| WIQL parse error | Response mentions "syntax error" or "invalid query" | Use single quotes for string values, not double quotes. Ensure FROM clause is present. Check field names are case-correct (e.g. `System.Title` not `system.title`) |
| PR thread creation — missing fields | Response mentions "commentType" or "parentCommentId" | Always include both `commentType` and `parentCommentId` fields when creating a PR comment thread |
| ArtifactLink format error | Response mentions "invalid artifact link" or "invalid URL" | Use exact format `vstfs:///Git/PullRequestId/{project}%2F{repo}%2F{prId}` — forward slashes between project/repo/prId must be percent-encoded as `%2F` |

### 401 Unauthorized

| Cause | How to Identify | Fix |
|-------|----------------|-----|
| PAT expired | Sudden failure, nothing else changed | Generate new PAT, update Secrets Manager |
| Wrong PAT | Specific operations fail, others work | Check which PAT is needed per operation |
| Malformed header | All calls fail immediately | Must be `Basic base64(:PAT)` with colon |

### 403 Forbidden

| Cause | How to Identify | Fix |
|-------|----------------|-----|
| PAT scope insufficient | Specific operation type fails | PAT needs the specific scope |
| Project permissions | All calls to one project fail | Check org admin settings |

### 404 Not Found

| Cause | How to Identify | Fix |
|-------|----------------|-----|
| Wrong work item ID | "Work item does not exist" | Verify ID in the correct project |
| Wrong wiki path | "Page not found" | Paths are case-sensitive, start with `/` |
| Wrong API version | Unexpected 404 on valid resources | Ensure `api-version=7.1` |
| Wrong wiki ID | All wiki calls return 404 | Verify `ADO_WIKI_ID` is correct |
| Attachment blob URL expired or invalid | 404 when downloading attachment | Blob URLs can expire or become invalid. Re-fetch the work item relations (`$expand=relations`) to get the current blob URL, then retry the download |

### 409 Conflict

| Cause | How to Identify | Fix |
|-------|----------------|-----|
| Missing ETag | "version conflict" or "ETag required" | Always GET before PUT, include `If-Match` |
| Stale ETag | "version conflict" after providing ETag | Re-GET the page, retry with fresh ETag |
| Concurrent modification | Intermittent conflicts | Re-GET, merge changes if needed, retry |

### 412 Precondition Failed

| Cause | How to Identify | Fix |
|-------|----------------|-----|
| ETag mismatch | Page modified between GET and PUT | Re-GET immediately before PUT |

### 413 Request Entity Too Large

| Cause | How to Identify | Fix |
|-------|----------------|-----|
| Attachment file exceeds org limit | Response mentions "request entity too large" or file size limit (default org limit is 130 MB) | Compress or split the file before uploading. Check org attachment size settings if a lower limit is configured |

---

## Recovery Procedure

```
Error occurs
     |
     v
Read HTTP status code and response body
     |
     v
Check docs/error-catalog.md for this specific error
     |
     +-- Found? --> Apply documented fix
     |
     +-- Not found? --> Check tables above
           |
           v
     Apply fix
           |
           v
     If error was new, add to docs/error-catalog.md:
       - HTTP Status
       - Endpoint
       - Error Message (exact or paraphrased)
       - Root Cause
       - Resolution
       - Date
```

---

## Error Catalog Entry Template

```markdown
### [Short description]
- **HTTP Status:** [code]
- **Endpoint:** [which API call]
- **Error Message:** [exact or paraphrased response]
- **Root Cause:** [what was wrong]
- **Resolution:** [how it was fixed]
- **Date:** [when encountered]
```

---

## Retry Strategy

| Error Type | Retry? | Strategy |
|-----------|--------|----------|
| 400 | No | Fix the request, don't retry the same thing |
| 401 | No | Fix credentials first |
| 403 | No | Fix permissions first |
| 404 | No | Fix the resource path or ID |
| 409 | Yes | Re-GET for fresh ETag, then retry once |
| 412 | Yes | Re-GET for fresh ETag, then retry once |
| 413 | No | Reduce file size, then retry with smaller payload |
| 429 | Yes | Wait and retry with backoff |
| 500/503 | Yes | Wait briefly, retry up to 3 times |
