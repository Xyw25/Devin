# ADO WIQL Queries — Knowledge Item

## Trigger Description
WIQL query, search work items, find work items by criteria, bulk work item lookup

## WIQL Overview

WIQL (Work Item Query Language) is a SQL-like language for querying ADO work items.
Use it to find items in bulk rather than fetching one-by-one.

## Endpoint

```
POST /_apis/wit/wiql?api-version=7.1
Content-Type: application/json
Body: {"query": "SELECT ... FROM WorkItems WHERE ..."}
```

## Common Query Patterns

### Find all items with devin-process tag
```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.Tags] CONTAINS 'devin-process'
  AND [System.State] <> 'Closed'
ORDER BY [System.CreatedDate] DESC
```

### Find all bugs in an area path
```sql
SELECT [System.Id], [System.Title], [Microsoft.VSTS.Common.Severity]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [System.AreaPath] UNDER 'Project\Team\Area'
  AND [System.State] <> 'Closed'
```

### Find items by keyword in title
```sql
SELECT [System.Id], [System.Title]
FROM WorkItems
WHERE [System.Title] CONTAINS 'login'
  AND [System.State] <> 'Removed'
```

### Find items linked to a test case
```sql
SELECT [System.Id]
FROM WorkItemLinks
WHERE [Source].[System.WorkItemType] = 'Bug'
  AND [Target].[System.WorkItemType] = 'Test Case'
  AND [System.Links.LinkType] = 'Microsoft.VSTS.Common.TestedBy-Forward'
MODE (MayContain)
```

## Rules

- WIQL returns work item IDs — fetch full details separately with batch GET
- Field names are case-sensitive: `System.Title` not `system.title`
- Use `CONTAINS` for tag/text search, not `=`
- Use `UNDER` for area path hierarchy matching
- Maximum 20,000 results per query
- String values in WHERE clauses use single quotes, not double

## Scripts

- `scripts/ado/work-items/query.sh` — execute a WIQL query
