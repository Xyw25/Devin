# Azure DevOps Repositories API Guide

> Created: 2026-03-25
> API Version: 7.1
> Source: [Azure DevOps REST API — Git Repositories](https://learn.microsoft.com/en-us/rest/api/azure-devops/git/repositories)

## Base Endpoint

```
{ADO_ORG_URL}/{ADO_PROJECT}/_apis/git/repositories?api-version=7.1
```

Authentication uses a Personal Access Token (PAT) stored in `ADO_PAT_CODE`.

## List All Repositories

**GET** `{ADO_ORG_URL}/{ADO_PROJECT}/_apis/git/repositories?api-version=7.1`

Returns all repositories in the project. Each entry includes:
- `id` — GUID uniquely identifying the repo
- `name` — human-readable repository name
- `defaultBranch` — e.g. `refs/heads/main` (includes the `refs/heads/` prefix)
- `webUrl` — browser-accessible URL

```bash
curl -s -u ":${ADO_PAT_CODE}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories?api-version=7.1" \
  | jq '.value[] | {id, name, defaultBranch, webUrl}'
```

## Get a Single Repository

**GET** `{ADO_ORG_URL}/{ADO_PROJECT}/_apis/git/repositories/{repoNameOrId}?api-version=7.1`

Works with either the repository name or its GUID.

```bash
curl -s -u ":${ADO_PAT_CODE}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/git/repositories/${REPO_NAME}?api-version=7.1"
```

## Clone URL Construction

The authenticated clone URL follows this pattern:

```
https://{PAT}@dev.azure.com/{org}/{project}/_git/{repo}
```

Example:

```bash
git clone "https://${ADO_PAT_CODE}@dev.azure.com/${ADO_ORG}/${ADO_PROJECT}/_git/${REPO_NAME}"
```

## Critical Rules

1. **Repo ID (GUID) is required for PR creation.** The Pull Request API expects the repository ID, not the name. Always fetch the repo first and extract `.id`.
2. **`defaultBranch` includes the `refs/heads/` prefix.** When comparing or creating branches, account for this prefix. Strip it with `${defaultBranch#refs/heads/}` when you need the short name.
3. **PAT scope:** The token referenced by `ADO_PAT_CODE` must have the `Code (Read & Write)` scope at minimum.

## Related Scripts

| Script | Purpose |
|--------|---------|
| `scripts/ado/repos/list.sh` | List all repositories in the configured project |
| `scripts/ado/repos/get.sh` | Get details for a specific repository |
| `scripts/ado/repos/clone.sh` | Clone a repository with PAT authentication |
