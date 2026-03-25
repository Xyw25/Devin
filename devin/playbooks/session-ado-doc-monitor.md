# Session ADO-Doc-Monitor — Weekly Azure DevOps Documentation Monitor

> Version: 1.0.0
> Last updated: 2026-03-26

## Purpose

Automated weekly session that monitors Microsoft's Azure DevOps REST API documentation
for changes that affect our local ADO documentation files, gotchas, and scripts.

Unlike the Devin doc-monitor (which tracks product features), ADO API changes can
**break scripts**. A deprecated endpoint or renamed field means our automation fails.
This playbook catches those changes before they cause production failures.

**Schedule:** `0 10 * * 1` (weekly Monday 10am UTC)
**State file:** `DevinStorage/schedules/ado-doc-monitor-state.json`

---

## Procedure

### Step 1: Read and validate state file

```bash
jq . DevinStorage/schedules/ado-doc-monitor-state.json > /dev/null 2>&1
```

If validation fails, log the error and reset state to initial template. Continue with reset state.

Parse and load:
- `lastCheckDate` — when the last check ran
- `lastCheckVersion` — current version counter
- `sources` array — all URLs to check with their `lastKnownState`
- `documentVersions` — current version of each local file
- `apiVersionStatus` — tracked API version lifecycle
- `pendingScriptUpdates` — scripts flagged from prior runs
- `pendingNewTopics` — new API features flagged for manual review

**`lastKnownState` structure per source:**
```json
{
  "title": "string — page <title> tag content",
  "headings": ["string — H1 and H2 text extracted from the page"],
  "apiVersion": "string — API version mentioned on the page (e.g., '7.1')",
  "deprecationNotices": ["string — any deprecation warnings found"],
  "endpointCount": "number — count of endpoints listed (for API reference pages)"
}
```

On first run, `lastKnownState` is empty string `""`. The monitor populates it after
the first successful fetch.

### Step 2: Pull latest repository state

```bash
git pull origin master
```

### Step 3: Check all ADO documentation sources

Fetch each source URL in order. For each page, extract key indicators and compare
against `lastKnownState` stored in the state file.

**Source check order:**

| # | Source URL | Name | Check Indicators |
|---|-----------|------|-----------------|
| 1 | `https://learn.microsoft.com/en-us/rest/api/azure-devops/wit/work-items` | Work Items API | Endpoint list, parameter changes, new operations, field name changes |
| 2 | `https://learn.microsoft.com/en-us/rest/api/azure-devops/wiki` | Wiki API | Page operations, ETag requirements, new parameters |
| 3 | `https://learn.microsoft.com/en-us/rest/api/azure-devops/git/pull-requests` | Pull Requests API | Thread model changes, new comment fields, merge strategy options |
| 4 | `https://learn.microsoft.com/en-us/rest/api/azure-devops/test` | Test Management API | Test plan/suite/case operations, new test types |
| 5 | `https://learn.microsoft.com/en-us/rest/api/azure-devops/git/repositories` | Repositories API | Clone URL format, new repo operations, branch ref changes |
| 6 | `https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate` | PAT Authentication | Scope changes, new auth methods, token format changes |
| 7 | `https://learn.microsoft.com/en-us/rest/api/azure-devops/` | API Overview | API version lifecycle, deprecation notices, new API areas |
| 8 | `https://learn.microsoft.com/en-us/azure/devops/release-notes/` | Release Notes | Breaking changes, new features, deprecation announcements |

**For each source:**
1. Fetch the page content
2. Extract: page title, H1/H2 headings, API version strings, deprecation warnings, endpoint count
3. Compare against `lastKnownState` in state file
4. If indicators differ: mark as `changed` with a summary of what's different
5. If source is unreachable: mark as `error`, log, continue to next source
6. **Critical check:** If any page mentions deprecation of API version 7.1, mark as `CRITICAL` change
7. Update the source's `lastChecked` date regardless of result

Wait 2 seconds between each source fetch to avoid throttling.

### Step 4: Evaluate results — branch on changes found

**If NO changes detected across all sources:**
1. Update state file: set `lastCheckDate`, append to `runHistory`
2. Commit: `ado-doc-monitor v{N}: no changes detected {date}`
3. Push: `git pull --rebase origin master && git push`
4. Exit.

**If changes ARE detected, continue to Step 5.**

### Step 5: Map changes to local files

| Source | Local Files in `DevinStorage/AzureDevOps Documentation/` |
|--------|-------------------------------------------------------|
| Work Items API | `api-guides/work-items-guide.md`, `references/endpoint-catalog.md`, `references/field-reference.md` |
| Wiki API | `api-guides/wiki-guide.md`, `operations/wiki-etag-workflow.md` |
| Pull Requests API | `api-guides/pull-requests-guide.md`, `operations/pr-comment-workflow.md` |
| Test Management API | `api-guides/test-management-guide.md`, `operations/test-case-creation.md` |
| Repositories API | `api-guides/repositories-guide.md` |
| PAT Authentication | `api-guides/authentication-guide.md` |
| API Overview | ALL files (if API version lifecycle changes) |
| Release Notes | `references/api-gotchas.md`, `operations/error-handling.md` |

### Step 6: Update affected local files

For each file that needs updating:

1. Read the current local file
2. Read the changed source content
3. Identify what specifically changed:
   - **New endpoint** → add to the appropriate api-guide AND `references/endpoint-catalog.md`
   - **Changed endpoint** (URL, method, parameters) → update the api-guide, note in endpoint-catalog
   - **Deprecated endpoint** → mark as deprecated in api-guide with date. **Never delete.**
   - **New field** → add to `references/field-reference.md`
   - **Changed field behavior** → update api-guide, add new gotcha
   - **API version change** → flag for manual review in `pendingNewTopics` (affects all 28 scripts)
4. Update the file's version header:
   ```
   > Last updated: {today}
   ```
5. Version bump: patch for minor updates, minor for new content, major for breaking changes

### Step 7: Verify script compatibility

For each change detected in Step 6, check if it affects any of the 28 ADO scripts:

| Change Type | Scripts to Check | Action |
|------------|-----------------|--------|
| Endpoint URL changed | Scripts calling that endpoint | Add to `pendingScriptUpdates` |
| Content-Type changed | Scripts using that Content-Type | Add to `pendingScriptUpdates` |
| Field name renamed | Scripts setting that field | Add to `pendingScriptUpdates` |
| New required parameter | Scripts calling that endpoint | Add to `pendingScriptUpdates` |
| API version deprecated | ALL 28 scripts | Add ALL to `pendingScriptUpdates` with `CRITICAL` flag |
| Auth method changed | `auth.sh` | Add to `pendingScriptUpdates` with `CRITICAL` flag |

**`pendingScriptUpdates` entry format:**
```json
{
  "script": "scripts/ado/work-items/create.sh",
  "reason": "Endpoint URL changed: /wit/workitems → /wit/workitems/v2",
  "severity": "HIGH",
  "detectedDate": "2026-03-26",
  "sourceChange": "Work Items API — endpoint restructure"
}
```

**Do NOT auto-modify scripts.** Only flag them for manual review.

### Step 8: Update gotchas if needed

If a new gotcha is discovered (changed behavior, new requirement, deprecated feature):

1. Read `references/api-gotchas.md`
2. Find the last gotcha number (currently G30)
3. Assign the next sequential number (G31, G32, etc.)
4. Add the new gotcha with: number, title, description, affected operations, date discovered
5. Update the quick-reference checklist at the bottom of the file

### Step 9: Update state file

```json
{
  "lastCheckDate": "{current ISO timestamp}",
  "lastCheckVersion": "{incremented}",
  "apiVersionStatus": {
    "current": "7.1",
    "previewInUse": "7.1-preview.4",
    "deprecated": [],
    "lastChecked": "{today}"
  },
  "sources": [/* updated lastChecked and lastKnownState */],
  "documentVersions": {/* updated versions for changed files */},
  "changesFound": [/* current run changes */],
  "pendingScriptUpdates": [/* accumulated — not cleared until manual review */],
  "pendingNewTopics": [/* accumulated — not cleared until manual review */],
  "runHistory": [/* append new entry, keep last 30 */]
}
```

### Step 10: Commit and push

```bash
git add "DevinStorage/AzureDevOps Documentation/"
git add DevinStorage/schedules/ado-doc-monitor-state.json
git pull --rebase origin master
git commit -m "ado-doc-monitor v{version}: {summary}"
git push origin master
```

If push fails after rebase, pull --rebase and retry once.

Commit message format:
- No changes: `ado-doc-monitor v{N}: no changes detected {date}`
- With changes: `ado-doc-monitor v{N}: updated {count} files — {topics}`
- Critical: `ado-doc-monitor v{N}: CRITICAL — API deprecation detected`

---

## Specifications

### Schedule
- Cron: `0 10 * * 1` (weekly Monday 10am UTC)
- Rationale: ADO API changes far less frequently than Devin product docs. Weekly is sufficient. Monday morning catches any weekend announcements.

### Inputs
- 8 source URLs (all public, no auth required)
- Current state file from DevinStorage

### Outputs (per run)
Every run produces at minimum:
- Updated `ado-doc-monitor-state.json` (always)
- Git commit (always)

If changes detected, additionally:
- Updated ADO Documentation files with new version headers
- New gotchas added to `api-gotchas.md` (if applicable)
- Script compatibility flags in `pendingScriptUpdates` (if applicable)

### Exit Conditions

| Condition | Action |
|-----------|--------|
| No changes across all sources | Update state, commit, exit |
| Changes found and applied | Update files + state, commit, exit |
| Single source unreachable | Log error, skip, continue to next |
| All sources unreachable | Log error in state, commit, exit |
| API version deprecation detected | Flag as CRITICAL, update state, commit, exit |
| New API area discovered | Add to `pendingNewTopics`, don't create files |

### Scope Controls
- Only check the 8 listed source URLs — never browse beyond them
- Only update files in `DevinStorage/AzureDevOps Documentation/` and state file
- Never auto-modify scripts in `scripts/ado/` — only flag for review
- Keep `runHistory` to last 30 entries — trim older ones each run

---

## Advice

### Change Detection
- Microsoft REST API docs use structured page layouts — look for `h2` headings that list operations, parameter tables, and "Request" / "Response" sections
- Release notes are chronological — only check entries newer than `lastCheckDate`
- If a page shows a banner like "This version will be retired" or "Deprecated", this is CRITICAL
- API version 7.1-preview.4 (comments endpoint) is the only preview version in use — watch for it stabilizing to GA or changing behavior
- Page restructuring (sections renamed) is NOT a content change — only flag if actual API behavior changes

### Script Verification
- When flagging scripts, be specific: note which line of the script uses the changed endpoint/field
- Severity levels: CRITICAL (breaks all scripts), HIGH (breaks specific scripts), MEDIUM (behavior change, scripts still work but may produce wrong results)
- `pendingScriptUpdates` accumulates until manually cleared — review it weekly

### Version Bumping for ADO Docs
- **patch** (+0.0.1): source re-verified, minor wording, date refreshed
- **minor** (+0.1.0): new endpoint, new field, new gotcha added
- **major** (+1.0.0): API version change, breaking change, endpoint removed/renamed

### State File Hygiene
- Keep `runHistory` to last 30 entries
- `changesFound` reflects current run only
- `pendingScriptUpdates` and `pendingNewTopics` accumulate until manually cleared

---

## Forbidden Actions

- **Never auto-modify scripts** in `scripts/ado/` — only flag in `pendingScriptUpdates` for manual review
- **Never delete content** from ADO documentation files — only add, update, or mark as deprecated
- **Never remove gotchas** from `api-gotchas.md` — add new ones or mark old ones as resolved with date
- **Never change the pinned API version** (7.1) without explicit manual approval
- **Never search beyond** the 8 source URLs listed in this playbook
- **Never fabricate or hallucinate changes** — only document what is actually found on source pages
- **Never skip the state file update** — even no-change runs must update and commit
- **Never skip `git pull --rebase`** before pushing
- **Never modify files outside** `DevinStorage/AzureDevOps Documentation/` and `DevinStorage/schedules/`
- **Never create new ADO documentation files** automatically — flag new topics for manual review

---

## Required from User

### Environment
- Internet access for fetching the 8 source URLs (all public, no auth required)
- Git push access to the repository

### Configuration
- This playbook attached to a Devin scheduled session
- Schedule set to `0 10 * * 1` (weekly Monday 10am UTC)
- Repository pinned to this repo
- Notifications set to "On failure only" (or "Always" if you want weekly summaries)

### No Secrets Required
All 8 source URLs are publicly accessible Microsoft documentation. No PATs or API keys needed.

### Manual Review Responsibilities
The user should:
- Review `pendingScriptUpdates` weekly — update affected scripts manually
- Review `pendingNewTopics` for new API features that need documentation
- Clear reviewed entries from both arrays after addressing them
- Check `apiVersionStatus` for deprecation warnings
- Review `runHistory` for patterns (frequent errors, missed sources)
