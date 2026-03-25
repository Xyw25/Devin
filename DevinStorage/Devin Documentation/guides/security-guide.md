# Security Best Practices Guide

> Version: 1.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> Sources accessed: 2026-03-25
> Sources:
> - [Devin Docs — API Reference / Usage Examples](https://docs.devin.ai/api-reference/v1/usage-examples)
> - [Devin Docs — Repo Setup](https://docs.devin.ai/onboard-devin/repo-setup)
> - [Embrace The Red — How Devin AI Can Leak Your Secrets](https://embracethered.com/blog/posts/2025/devin-can-leak-your-secrets/)

---

## Secret Management Rules

### Naming Convention
Secret keys must follow environment variable naming:
- Start with letter or underscore
- Followed by letters, numbers, or underscores only
- Examples: `ADO_PAT_WORKITEMS`, `ADO_ORG_URL`, `_INTERNAL_TOKEN`

### Storage
- **Devin Secrets Manager** for all credentials — never paste in chat
- **Organization-level secrets:** defined once, auto-retrieved in future sessions
- **Session-level secrets:** single-use, for temporary access needs

### Rules
- Never hardcode secret values anywhere in the repository
- Never paste API keys or PATs in Devin chat prompts
- Never include secret values in work item comments, Wiki pages, or PR descriptions
- Never echo or log secret values in scripts
- All scripts read from environment variables only

---

## PAT Scope Principle

Each PAT has the **minimum scope** required for its operations.
Never use a single PAT with all scopes — compartmentalize access.

| PAT | Scope | Sessions | Blast Radius |
|-----|-------|----------|-------------|
| `ADO_PAT_WORKITEMS` | Work Items: R&W | 0, A, B, C, D | Work item data only |
| `ADO_PAT_WIKI` | Wiki: R&W | B, C, D | Wiki pages only |
| `ADO_PAT_CODE` | Code: Read | A, C | Repository read only |
| `ADO_PAT_TESTS` | Test Mgmt: R&W | C, D | Test plans/cases only |

**Why separate PATs?**
- If one PAT is compromised, only that operation category is affected
- Easier to rotate individual PATs without disrupting all operations
- Audit trail shows which PAT was used for each action
- Principle of least privilege enforced at the credential level

---

## Secret Leak Vectors

Secrets can leak through multiple channels. Be aware of all of them:

| Vector | How It Happens | Prevention |
|--------|---------------|------------|
| Git commits | Hardcoded values in scripts or config | Scripts read from env vars only |
| Work item comments | Pasted credentials in session output | Never include auth details in comments |
| Log output | `curl -v` or `echo $PAT` in scripts | No verbose mode, no echo of secrets |
| Error messages | API responses that echo auth headers | Error catalog documents errors without credentials |
| PR descriptions | Inline credentials in context | Review PR descriptions before posting |
| Wiki pages | Pasted tokens during documentation | Never put credentials in Wiki content |
| Chat prompts | User pastes PAT directly in Devin chat | Use Secrets Manager instead |
| Analysis JSON | Credentials captured during code analysis | JSON schema has no credential fields |
| DeepWiki | Indexed files containing secrets | `.devin/wiki.json` excludes `devin/secrets/**` |

---

## Prevention Measures in This Repo

### Script-Level Protection
- `auth.sh` handles PAT encoding — raw value never appears in script arguments
- All scripts use `${ADO_AUTH_HEADER}` from environment, not inline values
- No `curl -v` (verbose) in any script — prevents header logging
- `set -euo pipefail` in all scripts — stops on error before leaking state

### Repository-Level Protection
- `secrets-reference.md` documents naming conventions only — **no values**
- `.gitignore` excludes `.env` and `.env.*` files
- `analyses/*.json` schema has no credential fields
- Error catalog records errors without exposing credential details

### DeepWiki Protection
- `wiki.json` excludes `devin/secrets/**` from indexing
- Scripts excluded from indexing (implementation details)

---

## direnv + .envrc Pattern

For local development or environments outside Devin Secrets Manager:

```bash
# .envrc (at repository root)
export ADO_ORG_URL="https://dev.azure.com/myorg"
export ADO_PROJECT="MyProject"
export ADO_WIKI_ID="wiki-guid-here"
export ADO_DEFAULT_AREA="Project\\Team\\Area"
export ADO_PAT_WORKITEMS="pat-value-here"
export ADO_PAT_WIKI="pat-value-here"
export ADO_PAT_CODE="pat-value-here"
export ADO_PAT_TESTS="pat-value-here"
```

**Critical:** Add `.envrc` to `.gitignore` — never commit it.

```bash
# Activate
direnv allow

# Alternative: ~/.bashrc
echo 'export ADO_PAT_WORKITEMS="value"' >> ~/.bashrc
source ~/.bashrc
```

---

## PAT Rotation

PATs expire on a schedule set in Azure DevOps.

### Symptoms of Expired PAT
- All calls using that PAT return **401 Unauthorized**
- Other PATs continue to work normally
- Error appears suddenly — nothing else changed

### Rotation Procedure
1. Generate new PAT in Azure DevOps with **same scope** as the old one
2. Update the value in Devin Secrets Manager (or `.envrc` / `~/.bashrc`)
3. No code changes needed — scripts read from environment variables
4. Verify by running a simple GET operation with the relevant script

### Proactive Rotation
- Set calendar reminders before PAT expiration dates
- Consider scheduling a weekly health check that tests each PAT
- Document PAT expiration dates in a secure location (not in this repo)

---

## Security Audit Checklist

- [ ] No hardcoded credentials in any file in this repository
- [ ] `.gitignore` includes `.env` and `.env.*`
- [ ] `wiki.json` excludes `devin/secrets/**`
- [ ] All scripts use `${ADO_AUTH_HEADER}` from `auth.sh`, not inline values
- [ ] No `curl -v` or `echo $PAT` in any script
- [ ] Error catalog entries don't include credential details
- [ ] Analysis JSON schema has no credential fields
- [ ] Work item comments don't contain authentication details
- [ ] PATs use minimum required scope
- [ ] PAT rotation schedule is documented (outside this repo)

---

## Incident Response

If a secret is suspected to be compromised:

1. **Immediately revoke** the PAT in Azure DevOps
2. Generate a new PAT with the same scope
3. Update in Devin Secrets Manager
4. Check git history for any accidental commits containing the value
5. If found in git: consider the value compromised, rotate it
6. Document the incident in `docs/error-catalog.md` (without the credential value)
