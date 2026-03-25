# ADO Authentication — Knowledge Item

## PAT Format

All ADO REST API calls authenticate via Personal Access Token (PAT) passed as
a Basic Auth header. The token must be base64-encoded in the format `:PAT`
(empty username, colon, then the PAT value).

## Header Construction

```bash
AUTH_HEADER="Authorization: Basic $(echo -n ":${PAT}" | base64)"
```

Every `curl` call must include:
```bash
-H "${AUTH_HEADER}"
```

## Scopes

| PAT Secret | Required Scope |
|---|---|
| `ADO_PAT_WORKITEMS` | Work Items: Read & Write |
| `ADO_PAT_WIKI` | Wiki: Read & Write |
| `ADO_PAT_CODE` | Code (Repositories): Read |
| `ADO_PAT_TESTS` | Test Management: Read & Write |

## Rules

- Never hardcode a PAT value anywhere — always read from environment variable
- Use `scripts/ado/auth.sh` to generate the base64-encoded header
- Each PAT has minimum scope — use the right PAT for the right operation
- If a 401 or 403 is returned, check `docs/error-catalog.md` first
- PATs expire — if auth suddenly fails across all calls, the PAT likely expired
