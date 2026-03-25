# Security Best Practices Guide

> Version: 2.0.0
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

## Secret Scope Matrix

Detailed mapping of which secret enables which specific operations across the pipeline.

| Secret | Operations Enabled | Scripts That Use It | Sessions | What Breaks If Revoked |
|--------|-------------------|---------------------|----------|----------------------|
| `ADO_PAT_WORKITEMS` | Read work item fields, Update work item fields, Add work item comments, Create work item relations, Query work items by WIQL | `work-items/get.sh`, `work-items/update.sh`, `work-items/comment.sh`, `work-items/query.sh` | 0, A, B, C, D | All sessions fail at step 1 (work item read). Pipeline halts completely. |
| `ADO_PAT_WIKI` | Read Wiki pages, Create Wiki pages, Update Wiki pages (with ETag), Read Functionality Index | `wiki/get-page.sh`, `wiki/create-page.sh`, `wiki/update-page.sh` | B, C, D | Session B cannot publish documentation. Session C cannot update Wiki test sections. Session D cannot read Functionality Index. |
| `ADO_PAT_CODE` | Clone repositories, Read file contents, Read commit history, Compare branches | `git clone`, `git log`, `git diff` (used directly, not via wrapper script) | A, C | Session A cannot analyze code. Session C cannot search codebase for existing tests. |
| `ADO_PAT_TESTS` | Create test cases, Read test plans, Link test cases to work items, Update test case fields | `test-cases/create.sh`, `test-cases/get.sh`, `test-cases/link.sh` | C, D | Session C cannot create or link test cases. Session D cannot verify existing test links. |
| `ADO_ORG_URL` | Base URL for all ADO REST API calls | All scripts (via `auth.sh`) | 0, A, B, C, D | All API calls fail with connection error. Not a secret per se, but must be set correctly. |
| `ADO_PROJECT` | Project context for all API calls | All scripts (via URL construction) | 0, A, B, C, D | API calls target wrong project or return 404. |
| `ADO_WIKI_ID` | Identifies which Wiki to read/write | `wiki/get-page.sh`, `wiki/create-page.sh`, `wiki/update-page.sh` | B, C, D | Wiki operations target wrong Wiki or return 404. |
| `ADO_DEFAULT_AREA` | Area path for new work items and test cases | `test-cases/create.sh` | C | New test cases created in wrong area or creation fails. |

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

### Proactive Rotation
- Set calendar reminders before PAT expiration dates
- Consider scheduling a weekly health check that tests each PAT
- Document PAT expiration dates in a secure location (not in this repo)

---

## PAT Rotation Procedure

Detailed step-by-step procedure for rotating any PAT. Follow every step in order.

### Step 1: Check Current Expiry Dates

Before rotating, know what you are working with.

1. Log in to Azure DevOps: `https://dev.azure.com/{org}/_usersSettings/tokens`
2. For each PAT (`ADO_PAT_WORKITEMS`, `ADO_PAT_WIKI`, `ADO_PAT_CODE`, `ADO_PAT_TESTS`):
   - Note the **name**, **scope**, **expiration date**, and **status** (Active / Expired / Near expiry)
3. Record this information in your secure tracking document (never in the repository)

### Step 2: Generate New PAT

1. In Azure DevOps Personal Access Tokens page, click **+ New Token**
2. Set the name to match the old PAT name exactly (e.g., `devin-workitems-2026-04`)
3. Set the **Organization** to the correct org
4. Set the **Expiration** to your organization's policy (recommended: 90 days max)
5. Set the **Scope** to match the old PAT exactly:
   - `ADO_PAT_WORKITEMS` -> Work Items: Read & Write
   - `ADO_PAT_WIKI` -> Wiki: Read & Write
   - `ADO_PAT_CODE` -> Code: Read
   - `ADO_PAT_TESTS` -> Test Management: Read & Write
6. Click **Create** and **immediately copy** the token value (it is shown only once)

### Step 3: Update Secrets Manager

1. Open Devin Secrets Manager in the Devin web app
2. Locate the secret key being rotated (e.g., `ADO_PAT_WORKITEMS`)
3. Update the value with the new PAT
4. Save the change
5. If using `.envrc` locally, update the value there as well

### Step 4: Verify Each Dependent Script

Run a lightweight test for each script that depends on the rotated PAT:

| PAT | Verification Command | Expected Result |
|-----|---------------------|-----------------|
| `ADO_PAT_WORKITEMS` | `bash scripts/ado/work-items/get.sh {known-work-item-id}` | 200 OK, work item JSON returned |
| `ADO_PAT_WIKI` | `bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"` | 200 OK, page content returned |
| `ADO_PAT_CODE` | `git ls-remote {repo-url}` (with PAT in credential) | Ref list returned without 401 |
| `ADO_PAT_TESTS` | `bash scripts/ado/test-cases/get.sh {known-test-case-id}` | 200 OK, test case JSON returned |

If any verification fails, double-check:
- The scope matches the old PAT exactly
- The value was copied completely (no trailing whitespace)
- The organization is correct

### Step 5: Revoke Old PAT

1. Return to Azure DevOps Personal Access Tokens page
2. Find the old PAT (it should still be listed)
3. Click **Revoke**
4. Confirm revocation

**Do not skip this step.** An un-revoked old PAT is a lingering credential that could be misused.

### Step 6: Document the Rotation

Record in your secure tracking document (not in this repository):
- Which PAT was rotated
- Old expiration date
- New expiration date
- Date of rotation
- Who performed the rotation
- Verification results (pass/fail for each script)

---

## Leak Detection Checklist

Run this 10-point checklist immediately after a suspected secret leak. Check every item — do not skip any.

- [ ] **1. Git log search.** Search the full git history for the leaked value or partial matches:
  ```bash
  git log -p --all -S "partial-value-here" -- .
  ```
  If found, note the commit SHA and file path. The value is permanently in history even if later removed.

- [ ] **2. Git diff of recent commits.** Review the last 20 commits for any credential-like strings:
  ```bash
  git log --oneline -20
  ```
  Then inspect each commit's diff for base64-encoded strings, tokens, or PAT-like patterns.

- [ ] **3. Work item comment audit.** Search recent work item comments for credential fragments. Use the ADO REST API:
  ```bash
  bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
  ```
  Check the `comments` and `history` fields for any auth details.

- [ ] **4. Wiki page audit.** Review recently modified Wiki pages for leaked values:
  ```bash
  bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"
  ```
  Check content of all recently updated pages.

- [ ] **5. PR description and comment audit.** Review open and recently merged PRs for credential exposure. Check titles, descriptions, and inline comments.

- [ ] **6. Analysis JSON audit.** Scan all `analyses/**/*.json` files for unexpected string fields that could contain credentials:
  ```bash
  grep -r "pat\|token\|password\|secret\|key" analyses/ --include="*.json"
  ```

- [ ] **7. Devin session log review.** Check the Devin session that triggered the alert. Review chat history and session output for any credential exposure.

- [ ] **8. DeepWiki content review.** Check the generated DeepWiki for the repository. If `wiki.json` exclude patterns were misconfigured, secrets may have been indexed.

- [ ] **9. CI/CD pipeline log review.** If the repository has CI/CD pipelines, review recent build logs for exposed credentials in output.

- [ ] **10. Environment variable audit.** Verify that `.envrc` is in `.gitignore`, that no `.env` files were committed, and that `secrets-reference.md` contains only naming conventions (no values).

After completing all 10 checks, proceed to Incident Response.

---

## Incident Response

If a secret is suspected to be compromised, follow all 8 steps in order. Do not skip steps.

### Step 1: Detect

Identify the scope of the potential compromise:
- Which secret(s) may be exposed? (Use the Secret Scope Matrix to understand impact)
- How was the leak detected? (Alert, manual review, external report)
- When did the exposure likely occur? (Commit timestamp, session timestamp)
- What is the blast radius? (See PAT Scope Principle table — only the affected operation category is at risk)

### Step 2: Contain

Stop the bleeding immediately:
1. **Revoke the compromised PAT** in Azure DevOps (`https://dev.azure.com/{org}/_usersSettings/tokens`)
2. If the leak is in a git commit, do **not** force-push to remove it yet — forensics first
3. If the leak is in a Devin session, end the session immediately
4. If the leak is in a Wiki page, note the page path but do not edit yet (preserve evidence)

### Step 3: Eradicate

Remove the leaked credential from all locations:
1. If in git history: the value is permanently compromised regardless of removal. Mark it as such.
2. If in a work item comment: edit the comment to remove the value, note the comment ID
3. If in a Wiki page: update the page to remove the value (fetch ETag first)
4. If in analysis JSON: remove the field, commit the fix
5. If in `.envrc` that was committed: remove from file, add `.envrc` to `.gitignore` if missing

### Step 4: Recover

Restore normal operations with new credentials:
1. Generate a new PAT with the **exact same scope** as the revoked one (see PAT Rotation Procedure)
2. Update Devin Secrets Manager with the new value
3. Update `.envrc` / `~/.bashrc` if applicable
4. Verify each dependent script works with the new PAT (see verification table in PAT Rotation Procedure)
5. Run a test session to confirm the pipeline operates normally

### Step 5: Document

Create a record of the incident (in a secure location, not in this repository):
- Date and time of detection
- Which credential was compromised
- How the leak occurred (root cause)
- Where the credential was exposed (file, comment, page, etc.)
- Timeline of containment and recovery actions
- Who was involved in the response

Also add a **new entry** to `docs/error-catalog.md` documenting the error pattern (without the credential value) so future sessions can recognize similar situations.

### Step 6: Improve

Address the root cause to prevent recurrence:
- If a script echoed a value: add `set -euo pipefail` and remove verbose flags
- If a commit contained a secret: add a pre-commit hook or update `.gitignore`
- If a Wiki page contained a credential: review the playbook that writes to the Wiki
- If `wiki.json` exclude patterns were insufficient: update them
- Update this security guide if a new leak vector is discovered

### Step 7: Notify

Inform relevant stakeholders:
- Team lead / project owner: summary of what happened and what was done
- Security team (if applicable): full incident report
- If the credential had external access (e.g., third-party API): notify the third party
- If user data may have been accessed: follow organizational data breach procedures

### Step 8: Review

Conduct a post-incident review within 48 hours:
- Walk through the timeline: detection -> containment -> recovery
- Identify what worked and what was slow
- Update the Security Audit Checklist if new checks are needed
- Schedule any follow-up actions (e.g., additional PAT rotation, audit of other repos)
- Update playbooks if the incident revealed a gap in session procedures

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
