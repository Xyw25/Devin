# Environment Configuration — Knowledge Item

## Environment Variables

All values are sourced from Devin's Secrets Manager. Never hardcode.

| Variable | Description | Example Format |
|---|---|---|
| `ADO_ORG_URL` | Organization base URL | `https://dev.azure.com/{org}` |
| `ADO_PROJECT` | Default project name | `MyProject` |
| `ADO_WIKI_ID` | Target wiki identifier | GUID or wiki name |
| `ADO_DEFAULT_AREA` | Default area path for new items | `Project\Team\Area` |

## PAT Environment Variables

| Variable | Purpose |
|---|---|
| `ADO_PAT_WORKITEMS` | Work item read/write, comments, relations |
| `ADO_PAT_WIKI` | Wiki page read/write |
| `ADO_PAT_CODE` | Repository clone/read |
| `ADO_PAT_TESTS` | Test plan/suite/case read/write |

## API Version

All scripts pin to **`api-version=7.1`**. No preview versions in production.

## Repository Layout

- **DevinStorage** (this repo): Configuration, scripts, analyses, docs
- **Target repositories**: Cloned as needed during Session A and C for code analysis

## Wiki Structure

```
/FunctionalityIndex
/Functionalities/{slug}
```

## Area Path Format

Uses backslash separator: `Project\Team\Area`
Never use forward slash for area or iteration paths.
