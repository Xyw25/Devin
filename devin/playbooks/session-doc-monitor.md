# Session Doc-Monitor — Daily Devin Documentation Monitor

## Purpose

Automated daily session that monitors all known Devin documentation sources
for changes, updates the local `DevinStorage/Devin Documentation/` files when
changes are detected, and maintains a versioned state file for tracking.

Runs once per day. Most runs detect no changes and exit cheaply (<= 1 ACU).
When changes are found, updates the relevant files and bumps their versions.

**Schedule:** `0 9 * * *` (daily at 9am UTC)
**State file:** `DevinStorage/schedules/doc-monitor-state.json`

---

## Procedure

### Step 1: Read state file

```bash
cat DevinStorage/schedules/doc-monitor-state.json
```

Parse and load:
- `lastCheckDate` — when the last check ran
- `lastCheckVersion` — current version counter
- `sources` array — all URLs to check with their `lastKnownState`
- `documentVersions` — current version of each local file
- `pendingNewTopics` — topics flagged from prior runs for manual review

### Step 2: Pull latest repository state

```bash
git pull origin master
```

Ensure we have the latest state file and documentation before checking.

### Step 3: Check all Devin documentation sources

Fetch each source URL in order and compare against `lastKnownState`.
For each source, extract key indicators to detect changes:
- Page title and main headings (H1, H2)
- Date stamps or "last updated" indicators
- New section titles not present in lastKnownState
- For the blog: titles of the latest 5 posts

**Source check order:**

| # | Source URL | Name | Check Indicators |
|---|-----------|------|-----------------|
| 1 | `https://docs.devin.ai/release-notes` | Release Notes | Latest release date, new version numbers, new feature names |
| 2 | `https://docs.devin.ai/api-reference/release-notes` | API Release Notes | Latest API version, new endpoints, deprecation notices |
| 3 | `https://docs.devin.ai/product-guides/knowledge` | Knowledge Guide | Section headings, new examples, updated best practices |
| 4 | `https://docs.devin.ai/product-guides/creating-playbooks` | Playbooks Guide | Section headings, new playbook types, updated structure |
| 5 | `https://docs.devin.ai/product-guides/scheduled-sessions` | Scheduling Guide | Cron options, new schedule types, UI changes |
| 6 | `https://docs.devin.ai/product-guides/session-insights` | Session Insights | New metrics, changed ACU guidance, new analysis tabs |
| 7 | `https://docs.devin.ai/essential-guidelines/good-vs-bad-instructions` | Instructions Guide | New examples, updated patterns, changed recommendations |
| 8 | `https://docs.devin.ai/essential-guidelines/when-to-use-devin` | Usage Guide | New use cases, changed limitations, updated recommendations |
| 9 | `https://docs.devin.ai/work-with-devin/deepwiki` | DeepWiki Guide | Configuration changes, new features, limit changes |
| 10 | `https://docs.devin.ai/onboard-devin/repo-setup` | Repo Setup | Secret management changes, new env var patterns |
| 11 | `https://cognition.ai/blog/1` | Cognition Blog | New post titles (filter: Devin-related only, skip hiring/research) |

**For each source:**
1. Fetch the page content
2. Extract the key indicators listed above
3. Compare against `lastKnownState` stored in state file
4. If indicators differ: mark as `changed` with a summary of what's different
5. If source is unreachable: mark as `error`, log the error, continue to next source
6. Update the source's `lastChecked` date regardless of result

### Step 4: Evaluate results — branch on changes found

**If NO changes detected across all sources:**

1. Update state file:
   - Set `lastCheckDate` to current ISO 8601 timestamp
   - Set `changesFound` to empty array `[]`
   - Append to `runHistory`: `{"date": "{today}", "version": {current}, "result": "no-changes", "changesDetected": 0, "filesUpdated": 0, "acuUsed": 1}`
2. Commit state file:
   ```bash
   git add DevinStorage/schedules/doc-monitor-state.json
   git commit -m "doc-monitor v{version}: no changes detected {date}"
   git push origin master
   ```
3. **Exit cleanly. Target ACU: <= 1.**

**If changes ARE detected, continue to Step 5.**

### Step 5: Map changes to local files

Use the `mapsTo` field in each source entry to identify which local files need updating:

| Source | Local Files in DevinStorage/Devin Documentation/ |
|--------|------------------------------------------------|
| Release Notes | `best-practices/master-guide.md`, `references/sources.md` |
| API Release Notes | `references/sources.md` |
| Knowledge Guide | `guides/knowledge-writing-guide.md` |
| Playbooks Guide | `guides/playbook-writing-guide.md` |
| Scheduling Guide | `guides/scheduling-guide.md` |
| Session Insights | `guides/session-sizing-guide.md`, `references/acu-reference.md` |
| Good vs Bad Instructions | `best-practices/master-guide.md`, `best-practices/patterns-and-anti-patterns.md`, `best-practices/prompt-engineering.md` |
| When to Use Devin | `best-practices/master-guide.md`, `guides/session-sizing-guide.md` |
| DeepWiki Guide | `guides/deepwiki-guide.md` |
| Repo Setup | `guides/security-guide.md` |
| Cognition Blog | `best-practices/master-guide.md`, `references/sources.md` |

### Step 6: Update affected local files

For each file that needs updating:

1. Read the current local file
2. Read the changed source content
3. Identify what specifically changed:
   - **New content** (new section, new feature, new API) -> add to the appropriate section
   - **Changed guidance** (updated recommendation, new limit) -> update the existing text
   - **Deprecated content** (removed feature, old API) -> mark as deprecated, do not delete
4. Update the file's version header:
   ```markdown
   > Version: {new_version}
   > Last updated: {today}
   > Sources re-verified: {today}
   ```
5. Determine version bump:
   - **patch** (x.x.+1): source re-verified, minor wording, date refreshed
   - **minor** (x.+1.0): new content added (section, pattern, recipe)
   - **major** (+1.0.0): fundamental change in guidance or significant restructure

### Step 7: Handle new topics

If a change introduces a completely new Devin feature or capability that doesn't
map to any existing file:

1. Add to `pendingNewTopics` array in state file:
   ```json
   {
     "topic": "Feature name",
     "source": "URL where discovered",
     "date": "ISO date",
     "summary": "Brief description of what it is"
   }
   ```
2. Do NOT create new files automatically — flag for manual review only

### Step 8: Update sources.md

Update `DevinStorage/Devin Documentation/references/sources.md`:
- Update `Sources accessed` date for all checked sources
- Add any new source URLs discovered during the check
- Never remove URLs — mark deprecated ones with `(deprecated {date})` suffix

### Step 9: Update state file

```json
{
  "lastCheckDate": "{current ISO timestamp}",
  "lastCheckVersion": "{incremented}",
  "sources": [/* updated lastChecked and lastKnownState for each */],
  "documentVersions": {/* updated versions for changed files */},
  "changesFound": [
    {
      "source": "URL",
      "sourceName": "Name",
      "summary": "What changed",
      "filesUpdated": ["file1.md", "file2.md"],
      "versionBumps": {"file1.md": "1.0.0 -> 1.1.0"},
      "date": "ISO date"
    }
  ],
  "runHistory": [/* append new entry */]
}
```

### Step 10: Commit and push

```bash
git add DevinStorage/Devin\ Documentation/
git add DevinStorage/schedules/doc-monitor-state.json
git commit -m "doc-monitor v{version}: updated {N} files — {brief summary}"
git push origin master
```

Commit message format:
- No changes: `doc-monitor v{N}: no changes detected {date}`
- With changes: `doc-monitor v{N}: updated {count} files — {topics}`

---

## Specifications

### ACU Budget
- **No changes detected:** <= 1 ACU (fetch sources, compare, update state, exit)
- **Changes detected and applied:** <= 5 ACU (fetch, compare, read/update files, commit)
- **Hard ceiling:** Never exceed 5 ACU. If more than 5 files need updating and budget is running low, update what you can and flag the rest in `pendingNewTopics` for the next run.

### State File
- Location: `DevinStorage/schedules/doc-monitor-state.json`
- Format: JSON (machine-readable, parseable by Devin)
- Must be committed after every run (even no-change runs)

### Version Scheme
Each file in `DevinStorage/Devin Documentation/` carries a version header:
```
> Version: major.minor.patch
> Last updated: YYYY-MM-DD
> Sources re-verified: YYYY-MM-DD
```

- **patch** (+0.0.1): re-verified, minor wording, date refreshed
- **minor** (+0.1.0): new content added (new section, new pattern, new recipe)
- **major** (+1.0.0): significant restructure or fundamental change

### Schedule
- Cron: `0 9 * * *` (daily at 9am UTC)
- Agent: Devin
- Playbook: this file (session-doc-monitor.md)
- Repository: DevinStorage
- Notifications: On failure only

### Exit Conditions

| Condition | Action | ACU |
|-----------|--------|-----|
| No changes across all sources | Update state, commit, exit | <= 1 |
| Changes found and applied | Update files + state, commit, exit | <= 5 |
| Single source unreachable | Log error, skip that source, continue | — |
| All sources unreachable | Log error in state, commit, exit | <= 1 |
| ACU budget approaching limit | Flag remaining in pendingNewTopics, commit what's done, exit | <= 5 |
| New topic doesn't map to existing file | Add to pendingNewTopics, don't create new file | — |

### Deliverables (per run)

Every run produces at minimum:
- Updated `doc-monitor-state.json` (always)
- Git commit (always)

If changes detected, additionally:
- Updated documentation files with new version headers
- Updated `sources.md` with refreshed access dates

---

## Advice

### Change Detection Tips
- Blog posts about hiring, company culture, or research papers are NOT relevant — only posts about Devin features, capabilities, and best practices
- Only flag changes as substantive when they involve: new features, changed behavior, new/updated API, changed limits, new best practices, deprecated capabilities
- Typo fixes or minor rewording on source pages do NOT warrant a local file update — only update `lastKnownState` in the state file
- When a source page is significantly restructured (sections renamed, merged, or split), flag for manual review in `pendingNewTopics` rather than attempting to auto-restructure local files

### Version Bumping
- When in doubt between patch and minor, choose patch — it's cheaper and safer
- A single run should rarely produce more than one minor bump per file
- Major version bumps should almost never happen automatically — flag for manual review

### State File Hygiene
- Keep `runHistory` to the last 30 entries — trim older entries on each run
- Keep `changesFound` from only the current run — previous runs are in `runHistory`
- `pendingNewTopics` accumulates until manually cleared — check it periodically

### Source Fetching
- If a source returns a redirect, follow it once — if it redirects again, mark as error
- If a source returns HTML that looks like a login page or CAPTCHA, mark as error
- Rate-limit requests: wait 2 seconds between each source fetch to avoid being throttled

---

## Forbidden Actions

- **Never delete existing content** from documentation files — only add, update, or mark as deprecated
- **Never remove source URLs** from `sources.md` — mark deprecated ones with date suffix
- **Never modify files outside** of `DevinStorage/Devin Documentation/` and `DevinStorage/schedules/`
- **Never search the web** beyond the 11 source URLs listed in this playbook
- **Never fabricate or hallucinate changes** — only document what is actually found on source pages
- **Never exceed 5 ACU** — flag remaining work for the next run
- **Never create new documentation files** automatically — flag new topics for manual review
- **Never modify playbooks, knowledge items, or scripts** — this session only touches DevinStorage/
- **Never hardcode dates or versions** — always read from state file and compute dynamically
- **Never skip the state file update** — even failed runs must update the state
- **Never skip the git commit** — every run produces a commit for audit trail

---

## Required from User

### Environment
- Internet access for fetching the 11 source URLs (all public, no auth required)
- Git push access to the repository (for committing state and doc updates)

### Configuration
- This playbook attached to a Devin scheduled session
- Schedule set to `0 9 * * *` (daily 9am UTC)
- Repository pinned to this repo
- Notifications set to "On failure only"

### No Secrets Required
All 11 source URLs are publicly accessible. No PATs or API keys needed.

### Manual Review Responsibilities
The user should periodically:
- Check `pendingNewTopics` array in the state file for flagged new features
- Create new documentation files for confirmed new topics
- Clear `pendingNewTopics` entries that have been addressed
- Review `runHistory` for patterns (frequent failures, high ACU usage)
