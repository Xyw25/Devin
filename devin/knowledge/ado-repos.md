# ADO Repositories — Knowledge Item

## Trigger Description
ADO repository listing, ID lookup, clone URL construction with PAT authentication

## Repository Operations

### List Repositories
```
GET /_apis/git/repositories?api-version=7.1
```
Returns all repos in the project with: `id`, `name`, `defaultBranch`, `webUrl`.

### Get Repository Details
```
GET /_apis/git/repositories/{repoNameOrId}?api-version=7.1
```
Works with either repo name (string) or repo ID (GUID).

### Clone URL Construction
```
https://{PAT}@dev.azure.com/{org}/{project}/_git/{repo}
```
Use `ADO_PAT_CODE` for the PAT value. Never hardcode the PAT in the URL — construct dynamically.

## Key Fields

| Field | Description |
|-------|-------------|
| `id` | Repository GUID — use in PR creation and other API calls |
| `name` | Human-readable name |
| `defaultBranch` | Usually `refs/heads/main` or `refs/heads/master` |
| `webUrl` | Browser URL for the repo |
| `remoteUrl` | HTTPS clone URL (without auth) |

## Rules

- Always look up repo ID dynamically — never hardcode it
- Branch refs always use `refs/heads/` prefix (e.g., `refs/heads/main`, not `main`). Without it, API calls fail silently or return 400.
- `ADO_PAT_CODE` scope: Code (Repositories): Read
- For PR creation, you need the repo **ID** (GUID like `a1b2c3d4-e5f6-...`), not the repo **name** (string like `MyRepo`). Use `get.sh` to look up the ID from the name.
- Clone URLs embed the PAT in the URL — never log or commit clone URLs as they contain credentials

## Scripts

- `scripts/ado/repos/list.sh` — list all repos in the project
- `scripts/ado/repos/get.sh` — get repo details by name or ID
- `scripts/ado/repos/clone.sh` — clone with PAT authentication
