# Secrets Reference — Naming Conventions Only

> **No secret values are stored in this file or anywhere in this repository.**
> All values are stored in Devin's Secrets Manager.

## Secret Naming Convention

| Secret Name | Purpose | Sessions | Minimum Scope |
|---|---|---|---|
| `ADO_PAT_WORKITEMS` | Work item CRUD, comments, relations | 0, A, B, C, D | Work Items: Read & Write |
| `ADO_PAT_WIKI` | Wiki page read/write | B, C, D | Wiki: Read & Write |
| `ADO_PAT_CODE` | Repository clone/read | A, C | Code (Repositories): Read |
| `ADO_PAT_TESTS` | Test plans, suites, cases | C, D | Test Management: Read & Write |
| `ADO_ORG_URL` | Organization base URL | All | n/a |
| `ADO_PROJECT` | Default project name | All | n/a |
| `ADO_WIKI_ID` | Target wiki identifier | B, C, D | n/a |
| `ADO_DEFAULT_AREA` | Default area path | A, C | n/a |

## PAT Rotation

- PATs have expiration dates set in Azure DevOps
- When a PAT expires, all calls using it return 401
- Generate a new PAT with the same scope and update in Devin Secrets Manager
- No code changes needed — scripts read from environment variables

## Scope Principle

Each PAT has the minimum scope required for its operations.
Never use a single PAT with all scopes — compartmentalize access.
