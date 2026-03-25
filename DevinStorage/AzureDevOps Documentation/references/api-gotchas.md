# ADO API Gotchas — Complete Collection

> Created: 2026-03-25
> API Version: 7.1
> Source: INTENT.md (this repository) and operational experience

Every known Azure DevOps REST API gotcha collected in one place.
Check this before writing any new script or API call.

---

## Content-Type Gotchas

### G1: Work Item Operations Require json-patch+json

```
Content-Type: application/json-patch+json    (CORRECT)
Content-Type: application/json               (WRONG — returns 400)
```

Applies to: create work item, update work item, add relation.
Does NOT apply to: comments, wiki operations, PR operations (those use `application/json`).

### G2: Comments Use Standard JSON

```
Content-Type: application/json    (CORRECT for comments)
```

The comment body is `{"text": "<p>HTML content</p>"}`, not a JSON Patch array.

---

## Field Name Gotchas

### G3: Field Names Are Case-Sensitive

```
System.Title        (CORRECT)
system.title        (WRONG)
title               (WRONG)
SYSTEM.TITLE        (WRONG)
```

### G4: Description Accepts HTML Only

Plain text in `System.Description` renders as a single unformatted line.
Always wrap in HTML tags:

```json
{"op": "add", "path": "/fields/System.Description", "value": "<p>Text here</p>"}
```

---

## Path Separator Gotchas

### G5: Area Path Uses Backslash

```
Project\Team\Area       (CORRECT)
Project/Team/Area       (WRONG)
```

### G6: Iteration Path Uses Backslash

```
Project\Sprint 1        (CORRECT)
Project/Sprint 1        (WRONG)
```

### G7: Wiki Paths Use Forward Slash

```
/Functionalities/user-login    (CORRECT)
\Functionalities\user-login    (WRONG)
```

---

## Wiki Gotchas

### G8: ETag Required for All Wiki Updates

```
Missing If-Match header on PUT = 409 Conflict. Always.
```

Workflow: GET -> capture ETag -> PUT with `If-Match: {ETag}`.
No exceptions. No shortcuts.

### G9: ETag Is Page-Specific

Each page has its own ETag. Using an ETag from page A to update page B
will fail with 409 or 412.

### G10: Fresh ETag Required

Never cache ETags across operations. Always GET immediately before PUT.
Even a few seconds of delay can cause conflicts if someone else edits.

---

## Pull Request Gotchas

### G11: Branch Refs Need Full Prefix

```
refs/heads/main              (CORRECT)
main                         (WRONG)
refs/heads/feature/my-fix    (CORRECT)
feature/my-fix               (WRONG)
```

### G12: Reviewer ID Must Be AAD GUID

```
"id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"    (CORRECT — AAD Object ID)
"id": "John Smith"                                  (WRONG — display name)
"id": "john@company.com"                            (WRONG — email)
```

---

## Test Case Gotchas

### G13: Test Cases Are Work Items

Test cases are created via the **work items API** (`$Test%20Case`),
NOT via the test plans API. They are linked to suites separately.

```
POST /_apis/wit/workitems/$Test%20Case    (CORRECT)
POST /_apis/test/cases                     (WRONG — no such endpoint)
```

### G14: Test Steps Use XML

The `Microsoft.VSTS.TCM.Steps` field uses XML, not JSON or markdown.
See [test-case-creation.md](../operations/test-case-creation.md) for format.

---

## API Version Gotchas

### G15: Pin to 7.1

All scripts use `api-version=7.1`. Preview versions (`7.1-preview.*`)
are not used in production except for the comments endpoint (`7.1-preview.4`).

### G16: Comments API Is Preview-Only

```
POST /_apis/wit/workitems/{id}/comments?api-version=7.1-preview.4
```

This is the only preview endpoint used. It has no GA equivalent.

---

## Authentication Gotchas

### G17: PAT Format Includes Leading Colon

```bash
echo -n ":${PAT}" | base64    (CORRECT — empty username, colon, PAT)
echo -n "${PAT}" | base64     (WRONG — missing the colon)
echo -n "user:${PAT}" | base64  (WRONG — should be empty username)
```

### G18: base64 Must Be Single Line

Some systems add line breaks in base64 output. Use `-w 0` flag:

```bash
echo -n ":${PAT}" | base64 -w 0
```

---

## Relation Gotchas

### G19: Relation URL Must Be Full API URL

```json
"url": "https://dev.azure.com/org/project/_apis/wit/workitems/12345"    (CORRECT)
"url": "12345"                                                            (WRONG)
"url": "https://dev.azure.com/org/project/_workitems/edit/12345"         (WRONG — web URL, not API URL)
```

### G20: TestedBy Direction Matters

```
Microsoft.VSTS.Common.TestedBy-Forward    (Work Item -> Test Case)
Microsoft.VSTS.Common.TestedBy-Reverse    (Test Case -> Work Item)
```

Use `-Forward` when adding from the work item side (most common).

---

## Attachment Gotchas

### G21: Attachment Upload Is Always 2-Step

```
Step 1: POST blob to wit/attachments  ->  returns blob URL
Step 2: PATCH work item to add ArtifactLink relation with blob URL
```

No single-call upload exists. You must perform both steps.

### G22: Attachment Blob URLs Require Auth Headers

```
Blob URLs are NOT public URLs. Every GET to download an attachment
must include the Authorization: Basic header, same as any other call.
```

---

## WIQL Gotchas

### G23: WIQL Uses Single Quotes for String Values

```sql
WHERE [System.State] = 'Active'          (CORRECT — single quotes)
WHERE [System.State] = "Active"          (WRONG — double quotes cause parse error)
```

### G24: WIQL Field Names Are Case-Sensitive

```sql
SELECT [System.Title] FROM WorkItems     (CORRECT)
SELECT [system.title] FROM WorkItems     (WRONG — field not found)
```

Same rule as JSON Patch fields (see G3).

### G25: WIQL UNDER Operator Matches Hierarchy

```sql
WHERE [System.AreaPath] UNDER 'Project\Team'    (matches Team and all children)
WHERE [System.AreaPath] = 'Project\Team'         (matches exact path only)
```

Use `=` for exact path match. Use `UNDER` for hierarchical match.

---

## PR Comment and Linking Gotchas

### G26: PR Comment Threads Use Integer Status Codes

```
1 = Active
2 = Fixed
3 = WontFix
4 = Closed
5 = ByDesign
```

Do NOT use string names like `"Active"` or `"Closed"` — use the integer.

### G27: PR Inline Comments Need threadContext with filePath

```json
{
  "comments": [{"content": "Fix this", "commentType": 1}],
  "threadContext": {
    "filePath": "/src/main.cs",
    "rightFileStart": {"line": 10, "offset": 1},
    "rightFileEnd": {"line": 10, "offset": 1}
  }
}
```

Without `threadContext`, the comment becomes a general (non-inline) comment.

### G28: ArtifactLink URL for PR Linking Uses %2F Encoding

```
vstfs:///Git/PullRequestId/{project}%2F{repo}%2F{prId}    (CORRECT)
vstfs:///Git/PullRequestId/{project}/{repo}/{prId}          (WRONG — slashes not encoded)
```

The forward slashes between project, repo, and prId must be percent-encoded as `%2F`.

---

## Repository Gotchas

### G29: Repository Name or ID — PR Creation Requires GUID

```
GET  git/repositories/my-repo-name    (CORRECT — name works for read)
POST git/repositories/{GUID}/pullrequests    (CORRECT — GUID required for PR creation)
POST git/repositories/my-repo-name/pullrequests    (WRONG — name may not resolve for writes)
```

Repository name (string) works for GET operations, but PR creation requires the repository GUID.

### G30: Bug ReproSteps Field Expects HTML

```json
{"op": "add", "path": "/fields/Microsoft.VSTS.TCM.ReproSteps", "value": "<ol><li>Step 1</li><li>Step 2</li></ol>"}
```

Plain text in `Microsoft.VSTS.TCM.ReproSteps` won't render correctly in the ADO UI.
Always wrap in HTML tags (same principle as G4 for Description).

---

## Quick Checklist Before Any API Call

- [ ] Content-Type correct? (json-patch+json for work items, json for others, octet-stream for attachments)
- [ ] Field names case-sensitive and correct?
- [ ] Path separators correct? (backslash for ADO paths, forward slash for wiki)
- [ ] Branch refs include `refs/heads/` prefix?
- [ ] Reviewer IDs are AAD GUIDs?
- [ ] ETag captured fresh before Wiki PUT?
- [ ] api-version=7.1 (or 7.1-preview.4 for comments)?
- [ ] PAT includes leading colon in base64 encoding?
- [ ] Relation URLs are full API URLs?
- [ ] WIQL uses single quotes for string values?
- [ ] PR comment threadContext included for inline comments?
- [ ] ArtifactLink URL uses %2F encoding?
- [ ] Repository GUID used for PR creation (not name)?
- [ ] Attachment upload done in 2 steps (blob then patch)?
- [ ] ReproSteps field contains HTML, not plain text?
