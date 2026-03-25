# Secrets Management Guide

> Version: 1.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25

---

## How Secrets Manager Works

Devin Secrets Manager is the built-in credential store for Devin sessions.

### Organization-Level Secrets
- Defined once by an admin in the Devin organization settings.
- Automatically available to all sessions in that organization.
- Persisted across sessions — no need to re-enter.
- Best for: PATs, org URLs, project names, and other values that do not change per session.

### Session-Level Secrets
- Set at session start, available only for that session's lifetime.
- Discarded when the session ends.
- Best for: temporary tokens, one-time access keys, or override values.

### Auto-Retrieval
- When a playbook or script references an environment variable (e.g., `$ADO_PAT_WORKITEMS`), Devin automatically retrieves the value from Secrets Manager.
- No explicit "fetch" step is needed in the playbook.
- If the secret does not exist, the environment variable is empty and the script will fail (by design — `set -euo pipefail` catches this).

---

## Naming Conventions

### Environment Variable Rules
- Must start with a letter or underscore.
- Followed by letters, numbers, or underscores only.
- Case sensitive. Use UPPER_SNAKE_CASE by convention.
- No spaces, hyphens, or special characters.

### Our Naming Pattern

| Prefix | Purpose | Examples |
|--------|---------|---------|
| `ADO_PAT_*` | Personal Access Tokens for Azure DevOps API calls | `ADO_PAT_WORKITEMS`, `ADO_PAT_WIKI`, `ADO_PAT_CODE`, `ADO_PAT_TESTS` |
| `ADO_*` | Azure DevOps configuration values (non-secret) | `ADO_ORG_URL`, `ADO_PROJECT`, `ADO_WIKI_ID`, `ADO_DEFAULT_AREA` |
| `_INTERNAL_*` | Internal tokens not tied to ADO | `_INTERNAL_TOKEN` |

### Why This Pattern
- `ADO_PAT_` prefix makes it immediately clear which secrets are PATs vs. configuration.
- Suffix indicates the scope: `WORKITEMS`, `WIKI`, `CODE`, `TESTS` — maps directly to the ADO permission scope.
- Easy to audit: search for `ADO_PAT_` to find all PAT references in scripts.

---

## Scope Minimization

Each PAT should have the absolute minimum scope required. Never use a single PAT with all scopes.

| PAT Name | Exact ADO Scope | Permissions | Used By Sessions | Operations Performed |
|----------|----------------|-------------|-----------------|---------------------|
| `ADO_PAT_WORKITEMS` | Work Items | Read & Write | 0, A, B, C, D | Read work item fields, post comments, update fields, create relations |
| `ADO_PAT_WIKI` | Wiki | Read & Write | B, C, D | GET Wiki pages (with ETag), PUT/POST Wiki pages, read Functionality Index |
| `ADO_PAT_CODE` | Code | Read only | A, C | Clone repositories, read file contents, check commit SHAs |
| `ADO_PAT_TESTS` | Test Management | Read & Write | C, D | Create test case work items, create TestedBy relations, query test plans |

### Why Not One PAT?
- **Blast radius**: If `ADO_PAT_CODE` is compromised, attacker gets read-only code access — not the ability to modify work items, Wiki, or tests.
- **Rotation independence**: Rotate one PAT without disrupting other operations.
- **Audit clarity**: Each API call's PAT tells you exactly what operation category was performed.

---

## Rotation Schedule

| PAT | Recommended Rotation | Reason |
|-----|---------------------|--------|
| `ADO_PAT_WORKITEMS` | Every 90 days | High-frequency use across all sessions. Most exposed. |
| `ADO_PAT_WIKI` | Every 90 days | Write access to Wiki pages. Moderate exposure. |
| `ADO_PAT_CODE` | Every 180 days | Read-only. Lower risk. Less frequent rotation acceptable. |
| `ADO_PAT_TESTS` | Every 90 days | Write access to test management. Moderate exposure. |

### Rotation Procedure
1. Log into Azure DevOps portal.
2. Navigate to User Settings > Personal Access Tokens.
3. Create a new PAT with the **exact same scope** as the one being replaced.
4. Copy the new PAT value.
5. Update the value in Devin Secrets Manager (organization-level).
6. If using `.envrc` locally, update the value there as well.
7. Verify the new PAT works (see Testing After Rotation below).
8. Revoke the old PAT in Azure DevOps.
9. Document the rotation date in your secure tracking system (not in this repo).

### Proactive Measures
- Set calendar reminders 7 days before each PAT's expiration date.
- Consider a weekly scheduled Devin session that tests each PAT with a simple GET.
- Azure DevOps sends email notifications before PAT expiration — ensure these go to a monitored inbox.

---

## Leak Vectors

All 9 known leak vectors, with specific prevention measures for each.

| # | Vector | How It Happens | Prevention | Detection |
|---|--------|---------------|------------|-----------|
| 1 | **Git commits** | Hardcoded PAT values in scripts or config files committed to the repository. | All scripts read from environment variables only. Never store values in source files. `.gitignore` includes `.env` and `.env.*`. | Search git history for PAT patterns: `git log -p --all -S 'PAT_VALUE_PREFIX'`. |
| 2 | **Work item comments** | Session output includes raw credentials pasted into ADO work item comments. | Playbooks never include auth details in comment templates. Review comment content in playbooks. | Periodic audit of recent work item comments for credential-like strings. |
| 3 | **Log output** | `curl -v` prints request headers (including Authorization). `echo $PAT` prints the value. | No `curl -v` (verbose mode) in any script. No `echo` of secret variables. Use `set -euo pipefail`. | Review scripts for `-v` flag and `echo $ADO_PAT` patterns. |
| 4 | **Error messages** | Some API error responses echo back the Authorization header or token. | Error catalog documents error patterns without credentials. Scripts capture only HTTP status codes, not full responses. | Check error-catalog.md entries for credential content. |
| 5 | **PR descriptions** | Inline credentials added as context in pull request descriptions. | Review all PR descriptions before posting. Never include auth context. | Automated PR review for credential patterns. |
| 6 | **Wiki pages** | Pasted tokens during Wiki documentation updates. | Playbooks never include credentials in Wiki content templates. JSON schema has no credential fields. | Periodic Wiki content audit. |
| 7 | **Chat prompts** | User pastes PAT directly in the Devin chat interface instead of using Secrets Manager. | Always use Secrets Manager. Never paste credentials in chat. Team training. | Review session transcripts for credential-like strings. |
| 8 | **Analysis JSON** | Code analysis captures credential values found in the codebase. | Analysis JSON schema has no credential fields. Analysis focuses on structure, not values. | Review analysis JSON schema for credential fields. |
| 9 | **DeepWiki** | DeepWiki indexes files that contain secrets (e.g., `.env` files committed accidentally). | `.devin/wiki.json` excludes `devin/secrets/**` from indexing. Scripts directory excluded. | Review `wiki.json` exclusion rules. Verify excluded paths. |

---

## Testing After Rotation

After rotating a PAT, verify it works by running the appropriate test command.

| PAT | Test Command | Expected Result |
|-----|-------------|----------------|
| `ADO_PAT_WORKITEMS` | `bash scripts/ado/get-work-item.sh {any-work-item-id}` | Returns work item JSON with fields. HTTP 200. |
| `ADO_PAT_WIKI` | `bash scripts/ado/get-wiki-page.sh /Functionalities` | Returns Wiki page content + ETag header. HTTP 200. |
| `ADO_PAT_CODE` | `bash scripts/ado/list-repos.sh` | Returns repository list JSON. HTTP 200. |
| `ADO_PAT_TESTS` | `bash scripts/ado/query-test-cases.sh "{area-path}"` | Returns test case work items. HTTP 200. |

### What If a Test Fails?
- **401 Unauthorized**: The new PAT was not saved correctly, or the scope is wrong. Re-check Secrets Manager.
- **403 Forbidden**: The scope is too narrow. Verify the PAT has the exact scope listed in the Scope Minimization table.
- **200 but empty results**: PAT works, but the query returned no data. This is not a PAT issue — check the query parameters.
