# Azure DevOps Work Items API Guide

> Created: 2026-03-25
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
