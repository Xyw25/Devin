# Azure DevOps Work Items API Guide

> Created: 2026-03-25, Last updated: 2026-03-25
> API Version: 7.1
> Source: [Azure DevOps REST API — Work Items](https://learn.microsoft.com/en-us/rest/api/azure-devops/wit/work-items)

---

## Base Endpoint

```
{ADO_ORG_URL}/{ADO_PROJECT}/_apis/wit/workitems
```

---

## Operations

### GET Work Item

```
GET /{org}/{project}/_apis/wit/workitems/{id}?$expand=all&api-version=7.1
```

Returns full work item including fields, tags, relations, and state.

**Script:** `scripts/ado/work-items/get.sh <work-item-id>`

### Create Work Item

```
POST /{org}/{project}/_apis/wit/workitems/${type}?api-version=7.1
Content-Type: application/json-patch+json
```

The type is URL-encoded: `Bug`, `User%20Story`, `Task`, `Test%20Case` -> `$Test%20Case`.

**Body format — JSON Patch array:**
```json
[
  {
    "op": "add",
    "path": "/fields/System.Title",
    "value": "Work item title"
  },
  {
    "op": "add",
    "path": "/fields/System.AreaPath",
    "value": "Project\\Team\\Area"
  },
  {
    "op": "add",
    "path": "/fields/System.Description",
    "value": "<p>HTML description content</p>"
  }
]
```

**Script:** `scripts/ado/work-items/create.sh <type> <json-patch-body>`

### Update Work Item

```
PATCH /{org}/{project}/_apis/wit/workitems/{id}?api-version=7.1
Content-Type: application/json-patch+json
```

Uses same JSON Patch format. Operations: `add`, `replace`, `remove`, `test`.

**Script:** `scripts/ado/work-items/update.sh <id> <json-patch-body>`

### Post Comment

```
POST /{org}/{project}/_apis/wit/workitems/{id}/comments?api-version=7.1-preview.4
Content-Type: application/json
```

**Body:**
```json
{
  "text": "<p>Comment HTML content here</p>"
}
```

Note: This is the only endpoint using a preview API version (`7.1-preview.4`).

**Script:** `scripts/ado/work-items/comment.sh <id> <html-text>`

### Add Relation

```
PATCH /{org}/{project}/_apis/wit/workitems/{id}?api-version=7.1
Content-Type: application/json-patch+json
```

**Body:**
```json
[
  {
    "op": "add",
    "path": "/relations/-",
    "value": {
      "rel": "Microsoft.VSTS.Common.TestedBy-Forward",
      "url": "{org_url}/{project}/_apis/wit/workitems/{target_id}",
      "attributes": {
        "comment": "Linked by Devin automation"
      }
    }
  }
]
```

**Script:** `scripts/ado/work-items/link-relation.sh <source-id> <relation-type> <target-id>`

### WIQL Queries

```
POST /{org}/{project}/_apis/wit/wiql?api-version=7.1
Content-Type: application/json
```

**Body:**
```json
{
  "query": "SELECT [System.Id], [System.Title], [System.State] FROM WorkItems WHERE ..."
}
```

**Common query patterns:**

By tag:
```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.Tags] CONTAINS 'devin-process'
  AND [System.TeamProject] = @project
```

By area path:
```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.AreaPath] UNDER 'Project\Team\Area'
  AND [System.State] <> 'Closed'
```

By keyword (title search):
```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.Title] CONTAINS 'search keyword'
  AND [System.WorkItemType] = 'Bug'
ORDER BY [System.CreatedDate] DESC
```

**Note:** WIQL returns work item IDs only. Use a batch GET request to retrieve full details:
```
GET /{org}/{project}/_apis/wit/workitems?ids={id1},{id2},{id3}&$expand=all&api-version=7.1
```

**Script:** `scripts/ado/work-items/query.sh`

### List Comments

```
GET /{org}/{project}/_apis/wit/workitems/{id}/comments?$top={top}&order={order}&api-version=7.1-preview.4
```

Returns comment objects containing:
- `text` — the comment body (HTML)
- `createdBy` — identity of the comment author
- `createdDate` — ISO 8601 timestamp

Parameters:
- `$top` — number of comments to return (default: 200)
- `order` — `asc` or `desc` (default: `asc`)

**Script:** `scripts/ado/work-items/get-comments.sh`

### Attachments — List

Fetch the work item with `$expand=relations`, then filter the relations array for entries where `rel == "AttachedFile"`.

Each attachment relation contains:
- `url` — blob download URL
- `attributes.name` — original file name
- `attributes.resourceSize` — file size in bytes

**Script:** `scripts/ado/work-items/get-attachments.sh`

### Attachments — Upload (2-Step Process)

**Step 1:** Upload the binary file to the attachment store:
```
POST /{org}/{project}/_apis/wit/attachments?fileName={name}&api-version=7.1
Content-Type: application/octet-stream

<binary file content>
```
Returns a JSON response with the blob `url`.

**Step 2:** Patch the work item to add an AttachedFile relation pointing to the blob URL:
```
PATCH /{org}/{project}/_apis/wit/workitems/{id}?api-version=7.1
Content-Type: application/json-patch+json
```
```json
[
  {
    "op": "add",
    "path": "/relations/-",
    "value": {
      "rel": "AttachedFile",
      "url": "{blob-url-from-step-1}",
      "attributes": {
        "comment": "Uploaded by Devin automation"
      }
    }
  }
]
```

**Critical: This is always a 2-step process. There is no single-call upload.**

**Script:** `scripts/ado/work-items/add-attachment.sh`

### Attachments — Download

GET the blob URL from the attachment relation (found in `relations[]` where `rel == "AttachedFile"`), passing the authorization header:

```
GET {attachment-blob-url}
Authorization: Basic {base64-encoded-pat}
```

The response body is the raw file content. Use `-o` with curl to save to a file.

**Script:** `scripts/ado/work-items/download-attachment.sh`

### Create Bug with Reproduction Steps

Use the `Microsoft.VSTS.TCM.ReproSteps` field for HTML-formatted reproduction steps, along with severity and priority fields:

```
POST /{org}/{project}/_apis/wit/workitems/$Bug?api-version=7.1
Content-Type: application/json-patch+json
```

```json
[
  {
    "op": "add",
    "path": "/fields/System.Title",
    "value": "Bug title here"
  },
  {
    "op": "add",
    "path": "/fields/Microsoft.VSTS.TCM.ReproSteps",
    "value": "<ol><li>Step one</li><li>Step two</li><li>Observe the error</li></ol>"
  },
  {
    "op": "add",
    "path": "/fields/Microsoft.VSTS.Common.Severity",
    "value": "2 - High"
  },
  {
    "op": "add",
    "path": "/fields/Microsoft.VSTS.Common.Priority",
    "value": 1
  }
]
```

Severity values: `1 - Critical`, `2 - High`, `3 - Medium`, `4 - Low`
Priority values: `1`, `2`, `3`, `4` (1 = highest)

**Script:** `scripts/ado/work-items/create-bug.sh`

---

## Critical Rules

### Content-Type
Work item create and update **must** use:
```
Content-Type: application/json-patch+json
```
Using `application/json` returns **HTTP 400**.

### Field Names Are Case-Sensitive
`System.Title` works. `system.title` does **not**. `title` does **not**.

### Description Field Accepts HTML
Plain text must be wrapped in `<p>` tags:
```json
{"op": "add", "path": "/fields/System.Description", "value": "<p>Plain text here</p>"}
```

### Path Separators
Area path and Iteration path use **backslash** `\`:
```
Project\Team\Area       (correct)
Project/Team/Area       (WRONG)
```

### Tags Format
Tags are semicolon-separated in a single string:
```
"devin-process; priority-high; sprint-12"
```

---

## Common Field Reference

| Display Name | Reference Name | Type |
|---|---|---|
| Title | `System.Title` | String |
| Description | `System.Description` | HTML |
| State | `System.State` | String |
| Area Path | `System.AreaPath` | TreePath |
| Iteration Path | `System.IterationPath` | TreePath |
| Work Item Type | `System.WorkItemType` | String |
| Tags | `System.Tags` | String |
| Assigned To | `System.AssignedTo` | Identity |

See [field-reference.md](../references/field-reference.md) for the complete list.

---

## PAT Required

`ADO_PAT_WORKITEMS` — Work Items: Read & Write

---

## Error Handling

For error diagnosis and recovery procedures (400, 401, 403, 404, 409, 413), see [error-handling.md](../operations/error-handling.md).
