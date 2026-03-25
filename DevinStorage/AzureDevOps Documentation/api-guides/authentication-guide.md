# Azure DevOps Authentication Guide

> Created: 2026-03-25
> API Version: 7.1
> Source: [Azure DevOps REST API — Authentication](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate)

---

## Authentication Method

All ADO REST API calls authenticate via **Personal Access Token (PAT)**
passed as a Basic Auth header.

---

## Header Construction

The PAT must be base64-encoded in the format `:PAT` (empty username, colon, PAT value):

```bash
AUTH_HEADER="Authorization: Basic $(echo -n ":${PAT}" | base64 -w 0)"
```

Every `curl` call includes:
```bash
-H "${AUTH_HEADER}"
```

**Script:** `source scripts/ado/auth.sh "$PAT_VALUE"` sets `ADO_AUTH_HEADER`.

---

## PAT Scopes (This System)

| PAT Secret | Required Scope | Used By |
|---|---|---|
| `ADO_PAT_WORKITEMS` | Work Items: Read & Write | Sessions 0, A, B, C, D |
| `ADO_PAT_WIKI` | Wiki: Read & Write | Sessions B, C, D |
| `ADO_PAT_CODE` | Code (Repositories): Read | Sessions A, C |
| `ADO_PAT_TESTS` | Test Management: Read & Write | Sessions C, D |

---

## Scope Principle

Each PAT has the **minimum scope** for its operations. Never use a single
PAT with all scopes. Benefits:
- If one PAT is compromised, only that operation category is affected
- Easier to rotate individual PATs
- Audit trail shows which PAT was used
- Principle of least privilege at credential level

---

## PAT Lifecycle

### Creation
1. Azure DevOps -> User Settings -> Personal Access Tokens
2. Select organization
3. Set expiration date
4. Choose minimum required scopes
5. Create and copy the token value

### Storage
- Store in Devin Secrets Manager (org-level for persistence)
- Never hardcode in scripts, config files, or documentation
- Never paste in chat prompts

### Rotation
1. Generate new PAT with same scope before old one expires
2. Update in Devin Secrets Manager
3. No code changes needed — scripts read from env vars
4. Verify with a simple GET operation

### Expiration Symptoms
- All calls using that PAT return **401 Unauthorized**
- Other PATs continue working normally
- Sudden failure — nothing else changed

---

## Usage in Scripts

```bash
# Step 1: Source auth.sh with the appropriate PAT
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"

# Step 2: Use the exported header in subsequent scripts
bash scripts/ado/work-items/get.sh "12345"
bash scripts/ado/work-items/comment.sh "12345" "<p>Comment text</p>"

# Step 3: Switch to a different PAT for different operations
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"
```

---

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| 401 Unauthorized | PAT expired or invalid | Generate new PAT, update in Secrets Manager |
| 401 Unauthorized | Malformed auth header | Must be `Basic base64(:PAT)` — note the leading colon |
| 403 Forbidden | PAT scope insufficient | PAT needs the specific scope for the operation |
| 403 Forbidden | Project permissions | Check org admin for project access |

Always check `docs/error-catalog.md` first when auth errors occur.
