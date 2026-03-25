# Azure DevOps WIQL Queries Guide

> Created: 2026-03-25
> API Version: 7.1

## Overview

WIQL (Work Item Query Language) is a SQL-like language for querying Azure DevOps work items. Queries are executed server-side and return matching work item IDs.

## Endpoint

**POST** `{ADO_ORG_URL}/{ADO_PROJECT}/_apis/wit/wiql?api-version=7.1`

```bash
curl -s -X POST \
  -u ":${ADO_PAT_CODE}" \
  -H "Content-Type: application/json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/wiql?api-version=7.1" \
  -d "{\"query\": \"${WIQL_QUERY}\"}"
```

## Field Reference Names

Always use the full reference name in WIQL queries, not the display name.

| Display Name | Reference Name |
|-------------|----------------|
| Title | `System.Title` |
| State | `System.State` |
| Work Item Type | `System.WorkItemType` |
| Assigned To | `System.AssignedTo` |
| Area Path | `System.AreaPath` |
| Iteration Path | `System.IterationPath` |
| Tags | `System.Tags` |
| Created Date | `System.CreatedDate` |
| Changed Date | `System.ChangedDate` |

## Common Query Patterns

### 1. Filter by Tags

```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.Tags] CONTAINS 'frontend'
  AND [System.State] <> 'Closed'
```

### 2. Filter by Area Path (Hierarchical)

```sql
SELECT [System.Id], [System.Title]
FROM WorkItems
WHERE [System.AreaPath] UNDER 'MyProject\Team Alpha'
```

### 3. Filter by Work Item Type

```sql
SELECT [System.Id], [System.Title], [System.State]
FROM WorkItems
WHERE [System.WorkItemType] = 'Bug'
  AND [System.State] = 'Active'
```

### 4. Keyword Search in Title

```sql
SELECT [System.Id], [System.Title]
FROM WorkItems
WHERE [System.Title] CONTAINS 'login'
```

### 5. Link Queries (Parent-Child)

```sql
SELECT [System.Id], [System.Title]
FROM WorkItemLinks
WHERE ([Source].[System.WorkItemType] = 'Feature')
  AND ([System.Links.LinkType] = 'System.LinkTypes.Hierarchy-Forward')
  AND ([Target].[System.WorkItemType] = 'User Story')
MODE (Recursive)
```

### 6. Date Range Filtering

```sql
SELECT [System.Id], [System.Title], [System.CreatedDate]
FROM WorkItems
WHERE [System.CreatedDate] >= '2026-01-01'
  AND [System.CreatedDate] < '2026-04-01'
  AND [System.WorkItemType] IN ('Bug', 'Task')
```

## Operators

| Operator | Usage | Example |
|----------|-------|---------|
| `=` | Exact match | `[System.State] = 'Active'` |
| `<>` | Not equal | `[System.State] <> 'Closed'` |
| `CONTAINS` | Substring match | `[System.Title] CONTAINS 'auth'` |
| `UNDER` | Hierarchical path match | `[System.AreaPath] UNDER 'Project\Team'` |
| `IN` | Match any in list | `[System.State] IN ('Active', 'New')` |
| `NOT IN` | Exclude list | `[System.State] NOT IN ('Closed', 'Removed')` |

## Working with Results

WIQL returns only work item IDs. Fetch full details with a batch GET:

```bash
# Extract IDs from WIQL response
IDS=$(echo "${WIQL_RESPONSE}" | jq -r '.workItems[].id' | paste -sd ',' -)

# Batch fetch work item details
curl -s -u ":${ADO_PAT_CODE}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems?ids=${IDS}&api-version=7.1"
```

## Limits

- Maximum **20,000** results per query
- For larger result sets, use continuation tokens or narrow the query with additional filters

## Gotchas

1. **Single quotes for string values.** WIQL uses single quotes (`'Active'`), not double quotes.
2. **Field names are case-sensitive.** `System.Title` works; `system.title` does not.
3. **`UNDER` vs `=` for paths.** Use `UNDER` to include child paths; `=` matches only the exact path.
4. **Date format.** Use ISO format `'YYYY-MM-DD'` or the `@Today` macro.
5. **Tags field.** `System.Tags` supports `CONTAINS` but not `=` for individual tag matching.

## Related Script

| Script | Purpose |
|--------|---------|
| `scripts/ado/work-items/query.sh` | Execute a WIQL query and return results |
