# ADO Work Items — Knowledge Item

## API Endpoint

```
Base: {ADO_ORG_URL}/{ADO_PROJECT}/_apis/wit/workitems
API version: api-version=7.1
```

## Field Names (Case-Sensitive)

| Field | Reference Name |
|---|---|
| Title | `System.Title` |
| Description | `System.Description` |
| State | `System.State` |
| Area Path | `System.AreaPath` |
| Iteration Path | `System.IterationPath` |
| Work Item Type | `System.WorkItemType` |
| Tags | `System.Tags` |
| Assigned To | `System.AssignedTo` |

**CRITICAL:** Field names are case-sensitive. `System.Title` works. `system.title` does not.

## Content-Type

Work item create and update operations require:
```
Content-Type: application/json-patch+json
```
Using `application/json` returns HTTP 400.

## Patch Format

All field updates use JSON Patch operations:
```json
[
  {
    "op": "add",
    "path": "/fields/System.Title",
    "value": "New title"
  }
]
```

Valid operations: `add`, `replace`, `remove`, `test`

## Description Field

`System.Description` accepts HTML content. Plain text must be wrapped:
```json
{
  "op": "add",
  "path": "/fields/System.Description",
  "value": "<p>Plain text content here</p>"
}
```

## Relations

Adding a relation (e.g., TestedBy):
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

## Path Separators

- Area path uses backslash: `Project\Team\Area`
- Iteration path uses backslash: `Project\Sprint 1`
- Never use forward slash for these paths

## Comments

```
POST /{org}/{project}/_apis/wit/workitems/{id}/comments?api-version=7.1-preview.4
Content-Type: application/json
{
  "text": "<p>Comment HTML content</p>"
}
```

## Scripts

Always use scripts in `scripts/ado/work-items/` instead of writing raw curl calls:
- `get.sh` — GET work item by ID
- `create.sh` — POST new work item
- `update.sh` — PATCH work item fields
- `comment.sh` — POST comment
- `link-relation.sh` — PATCH to add relation
