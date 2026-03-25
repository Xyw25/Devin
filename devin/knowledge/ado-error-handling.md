# ADO Error Handling — Knowledge Item

## Trigger Description
ADO API error diagnosis, HTTP status codes, recovery using error-catalog.md

## Common Errors and Fixes

### 400 Bad Request
| Cause | Fix |
|---|---|
| Wrong Content-Type | Use `application/json-patch+json` for work item create/update |
| Invalid field name | Field names are case-sensitive — see `api-gotchas.md` G3 |
| Malformed JSON Patch | Ensure `op`, `path`, and `value` are all present |
| Missing `refs/heads/` prefix | Branch refs need full prefix — see `api-gotchas.md` G11 |

### 401 Unauthorized
| Cause | Fix |
|---|---|
| PAT expired | Generate new PAT in ADO, update in Devin Secrets Manager |
| Wrong PAT for scope | Check which PAT is needed (see secrets reference) |
| Malformed auth header | Must be `Basic base64(:PAT)` — note the leading colon |

### 403 Forbidden
| Cause | Fix |
|---|---|
| PAT scope insufficient | PAT needs the specific scope for the operation |
| Project-level permissions | Check org admin for project access |

### 404 Not Found
| Cause | Fix |
|---|---|
| Wrong work item ID | Verify ID exists in the correct project |
| Wrong wiki path | Paths are case-sensitive and must start with `/` |
| Wrong API version | Ensure `api-version=7.1` |

### 409 Conflict
| Cause | Fix |
|---|---|
| Missing ETag on Wiki update | Always GET before PUT — capture and send ETag |
| Stale ETag | Re-GET the page and retry with fresh ETag |
| Concurrent modification | Re-GET, merge changes, retry |

### 412 Precondition Failed
| Cause | Fix |
|---|---|
| ETag mismatch | Page was modified between GET and PUT — re-GET and retry |

## Recovery Procedure

1. Read the HTTP status code and response body
2. Check the table above for the specific status code
3. Check `docs/error-catalog.md` for any previously encountered errors
4. Apply the fix
5. If the error is new, add it to `docs/error-catalog.md` after resolution
6. **Never search online for ADO API troubleshooting**

## Rules

- When any ADO API call fails, check `docs/error-catalog.md` BEFORE attempting any other recovery action. Do not search online.
- For case-sensitivity errors, refer to `api-gotchas.md` G3 (field names) and G11 (branch refs) rather than debugging from scratch.
- Always capture the full response body — ADO error messages often contain the exact field or value that caused the failure.
- After resolving a new error, immediately add it to `docs/error-catalog.md` for future reference.

## Scripts

- `docs/error-catalog.md` — companion artifact containing all previously encountered errors and resolutions
