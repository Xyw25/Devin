# ADO Work Items — Knowledge Item

## Trigger Description
ADO work item fields, JSON Patch format, relations, Content-Type requirements

## API Endpoint

```
Base: {ADO_ORG_URL}/{ADO_PROJECT}/_apis/wit/workitems
API version: api-version=7.1
```

## Common Field Reference

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

## Content-Type

Work item create and update operations require:
```
Content-Type: application/json-patch+json
```
Using `application/json` returns HTTP 400.

## Patch Format

All field updates use JSON Patch operations. Each operation looks like:
```json
{ "op": "add", "path": "/fields/System.Title", "value": "New title" }
```
Valid operations: `add`, `replace`, `remove`, `test`

See `scripts/ado/work-items/create.sh` for the full create payload format.

## Description Field

`System.Description` accepts HTML content. Plain text must be wrapped in `<p>` tags.

## Relations

Use the `TestedBy-Forward` relation to link items. See `scripts/ado/work-items/link-relation.sh` for the relation payload format.

## Gotchas

See `DevinStorage/AzureDevOps Documentation/references/api-gotchas.md` for gotchas G3 (case sensitivity), G5 (path separators), G11 (refs/heads prefix).

## Comments

Comments are posted via a separate endpoint. See `scripts/ado/work-items/comment.sh` for usage.

## Rules

- Always use `application/json-patch+json` as Content-Type for create/update
- Field reference names are case-sensitive (see api-gotchas.md G1)
- Area/Iteration paths use backslash separators (see api-gotchas.md G5)
- `System.Description` must contain HTML — wrap plain text in `<p>` tags
- Use scripts instead of raw curl calls

## Scripts

Always use scripts in `scripts/ado/work-items/` instead of writing raw curl calls:
- `get.sh` — GET work item by ID
- `create.sh` — POST new work item
- `update.sh` — PATCH work item fields
- `comment.sh` — POST comment
- `link-relation.sh` — PATCH to add relation
