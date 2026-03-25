# INTENT.md — Devin ADO Automation Full Design Intent

> This document captures the complete design intent for the Devin + Azure DevOps
> automation system. It is the authoritative planning reference for all sessions,
> scripts, knowledge items, and playbooks in this repository.
> Continue implementation in Claude Code using this file as the primary context source.

---

## Background and Purpose

The core problem this system solves: Devin, by default, has no context about our
environment. When a basic ADO operation fails, Devin's fallback is to search online
randomly — burning ACUs on recovery rather than execution. This system inverts that
model by giving Devin everything it needs before a session starts.

Secondary goal: build a living, growing knowledge base of our codebase's
functionalities, their user workflows, their test coverage, and their history of
work items. This knowledge lives in two places — the ADO Wiki (human-facing) and
DevinStorage (machine-facing JSON).

---

## Companion Repository: DevinStorage

A dedicated repository named **DevinStorage** serves as the persistent handoff
layer between all sessions. It is not a codebase — it is a structured data store
and historical record.

**Why a separate repo and not ADO Wiki comments or work item fields:**
- JSON files are machine-readable and queryable by Devin without parsing markdown
- Commit history provides a natural audit trail
- All sessions on Devin's VM have access to all connected repos simultaneously
- Grows into a permanent organizational knowledge base over time

**File location pattern:**
```
/analyses/{product}/{functionality-slug}.json
```

**Analysis file JSON structure:**
```json
{
  "functionality": "string — human readable name",
  "slug": "string — kebab-case identifier",
  "product": "string — product or area name",
  "keywords": ["list of terms", "feature area names", "button labels", "route names"],
  "lastAnalyzedCommit": "string — full commit SHA of last analyzed state",
  "lastAnalyzedDate": "string — ISO 8601 date",
  "repositoryUrl": "string",
  "entryPoints": ["file paths and method names"],
  "models": ["models/entities involved — hard cap at 5"],
  "dependencies": ["direct dependencies only — one level deep"],
  "calledBy": ["what directly calls this functionality"],
  "logic": "string — concise description of core logic",
  "userWorkflow": ["ordered steps from user perspective"],
  "actions": ["actions triggered"],
  "knownIssues": "string — notable fragility or complexity",
  "workItems": [
    {
      "id": "integer",
      "type": "string — Bug / User Story / Dev Bug",
      "title": "string",
      "url": "string"
    }
  ],
  "wikiPagePath": "string — path to dedicated Wiki page",
  "analysisHistory": [
    {
      "date": "string — ISO 8601",
      "commit": "string — SHA",
      "triggeredBy": "integer — work item ID",
      "note": "string — what changed or was supplemented"
    }
  ]
}
```

**Format rationale:** JSON chosen over XML (verbose), YAML (ambiguous), and
Markdown (not reliably machine-parseable). Markdown reserved for Wiki pages only.

---

## The devin-process Tag

**`devin-process`** is the only tag used in this entire system.

Session 0 checks for it first. No tag means no processing, no exceptions.
No other tags are needed for any state tracking — skip, supplement, and
update logic is self-regulating via:
- Commit SHA comparison in DevinStorage JSON
- Wiki page existence check
- Test linkage check via TestedBy relations on work items

---

## ADO Wiki Structure

```
/FunctionalityIndex               <- Master index, one entry per functionality
/Functionalities/{slug}           <- Dedicated page per functionality
```

**FunctionalityIndex entry format (per row):**
- Functionality name (linked to dedicated page)
- Short description
- Product / area
- Test coverage status
- Last updated date

**Dedicated page sections:**
1. Overview
2. User Workflow (ordered steps from user perspective)
3. Actions Triggered
4. Models and Logic Involved
5. Associated Work Items (table: ID, type, title, link)
6. Tests (list of test case IDs, titles, and coverage status)

---

## Session Specifications

### Session 0 — Pre-check and Router

**Purpose:** Gate. Reads the work item, checks the tag, checks basic validity,
extracts a scope hint, routes to Session D. Cheapest session — <= 1 ACU.
Read-only in almost all cases.

**Steps:**
1. Read the full work item including tags, title, description, type, state
2. Check for `devin-process` tag — absent means exit immediately, no action
3. Check state — Closed or Resolved means exit immediately
4. Check description — empty or under 20 words means post clarification comment and exit
5. Extract scope hint (functionality area, feature name, UI element, action mentioned)
6. Route to Session D with scope hint

**ADO API calls:**
```
GET /{org}/{project}/_apis/wit/workitems/{id}?$expand=all&api-version=7.1
POST /{org}/{project}/_apis/wit/workitems/{id}/comments?api-version=7.1-preview.4
```

**PATs:** `ADO_PAT_WORKITEMS` (read, occasional comment)
**Target ACU:** <= 1

---

### Session A — Code Analysis

**Purpose:** Analyze the codebase around a functionality and write a structured
JSON record to DevinStorage. Scoped and bounded — never open-ended.

**Trigger:** Session D cannot match the functionality with 2+ keyword overlap,
OR DevinStorage file exists but commit SHA has changed.

**Skip condition:** DevinStorage file exists AND `lastAnalyzedCommit` matches
current HEAD of relevant files -> skip, hand off to Session B directly.

**Supplement condition:** File exists but HEAD has moved -> re-analyze changed
areas only, update `lastAnalyzedCommit`, append to `analysisHistory`,
re-trigger Session B.

**Scope limits (hard stops):**
- Trace direct calls and dependencies **one level deep only**
- Hard stop at **5 models**
- Hard stop at **10 entry points**
- If either limit is hit: post a comment on the work item listing what was found
  and asking which specific aspect to focus on, then exit cleanly

**Steps:**
1. Read full work item and scope hint from Session 0
2. Check DevinStorage for existing analysis file
3. Compare `lastAnalyzedCommit` to current HEAD
4. If current — skip, trigger Session B
5. If outdated or missing — analyze within scope limits
6. Write or update JSON file in DevinStorage including `keywords` array
7. Append work item to `workItems` array
8. Append entry to `analysisHistory`
9. Commit and push to DevinStorage
10. Post comment on work item confirming analysis, referencing DevinStorage path
11. Trigger Session B

**ADO API calls:**
```
GET  /{org}/{project}/_apis/wit/workitems/{id}?$expand=all&api-version=7.1
POST /{org}/{project}/_apis/wit/workitems/{id}/comments?api-version=7.1-preview.4
```

**Git operations:**
```
git clone / git pull — target repository
git pull             — DevinStorage
git add / commit / push — DevinStorage
```

**PATs:** `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE`, DevinStorage access
**Target ACU:** <= 5 (<= 3 if supplement only)

---

### Session B — Functionality Documentation

**Purpose:** Create or update the ADO Wiki dedicated page and Functionality Index
entry from the DevinStorage analysis file. Always triggers Session C on completion.

**Skip condition:** Wiki page exists AND analysis was not supplemented (commit was
already current in Session A) -> skip page content, still trigger Session C.

**Steps:**
1. Read analysis JSON from DevinStorage
2. Check ADO Wiki for Functionality Index page
3. Check ADO Wiki for existing dedicated page for this functionality
4. If no dedicated page — create with all sections
5. If page exists and analysis was supplemented — update changed sections
6. If page exists and commit was current — skip content, trigger Session C
7. Update Functionality Index entry
8. Append originating work item to work items table on dedicated page
9. Post comment on work item with direct Wiki link
10. Always trigger Session C

**CRITICAL — ETag requirement:**
Every Wiki GET returns an ETag in the response header.
Every Wiki PUT update requires that ETag in the `If-Match` header.
Missing ETag on update = 409 Conflict error.
Always GET before PUT. Never skip this step.

**ADO API calls:**
```
GET  /{org}/{project}/_apis/wiki/wikis?api-version=7.1
GET  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/FunctionalityIndex&includeContent=true&api-version=7.1
GET  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/Functionalities/{slug}&includeContent=true&api-version=7.1
PUT  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/Functionalities/{slug}&api-version=7.1
     If-Match: {ETag}
PUT  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/FunctionalityIndex&api-version=7.1
     If-Match: {ETag}
POST /{org}/{project}/_apis/wit/workitems/{id}/comments?api-version=7.1-preview.4
```

**Git operations:**
```
git pull — DevinStorage (read analysis JSON)
```

**PATs:** `ADO_PAT_WIKI`, `ADO_PAT_WORKITEMS`, DevinStorage read
**Target ACU:** <= 3

---

### Session C — Test Coverage

**Purpose:** Find existing test cases, evaluate coverage, create new ones if needed,
link all to the work item, update Wiki and Index.

**Trigger:** Session B completes or updates (always). Also triggers if Session B
determines page is current but analysis was recently supplemented.

**Skip condition:** Tests already linked via TestedBy AND no new analysis was
performed -> skip creation, still update Wiki if needed.

**Steps:**
1. Read dedicated Wiki page
2. Read analysis JSON from DevinStorage
3. Check existing TestedBy relations on work item
4. Search codebase for existing test cases related to functionality
5. Read and evaluate coverage
6. If gaps exist — create new test cases as ADO work items of type Test Case
7. Link all test cases (existing and new) to work item via TestedBy-Forward relation
8. Update dedicated Wiki page tests section
9. Update Functionality Index test coverage status
10. Update DevinStorage JSON if new tests were created
11. Post comment summarizing tests found, tests created, coverage assessment,
    and whether the bug should have been caught by existing tests

**Note on test case creation:**
Test cases are work items of type `$Test%20Case` created via the work items API,
not the test plans API. They are linked to test suites separately after creation.

**ADO API calls:**
```
GET  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/Functionalities/{slug}&includeContent=true&api-version=7.1
GET  /{org}/{project}/_apis/test/plans?api-version=7.1
GET  /{org}/{project}/_apis/test/plans/{planId}/suites?api-version=7.1
GET  /{org}/{project}/_apis/test/plans/{planId}/suites/{suiteId}/testcases
     ?api-version=7.1
POST /{org}/{project}/_apis/wit/workitems/$Test%20Case?api-version=7.1
     Content-Type: application/json-patch+json
PATCH /{org}/{project}/_apis/wit/workitems/{id}?api-version=7.1
      Content-Type: application/json-patch+json
      [relation: Microsoft.VSTS.Common.TestedBy-Forward]
PUT  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/Functionalities/{slug}&api-version=7.1
     If-Match: {ETag}
PUT  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/FunctionalityIndex&api-version=7.1
     If-Match: {ETag}
POST /{org}/{project}/_apis/wit/workitems/{id}/comments?api-version=7.1-preview.4
```

**Git operations:**
```
git pull             — DevinStorage and target repository
git add / commit / push — DevinStorage (if new tests created)
```

**PATs:** `ADO_PAT_TESTS`, `ADO_PAT_WIKI`, `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE`,
DevinStorage read/write
**Target ACU:** <= 5

---

### Session D — Triage and Linking

**Purpose:** Match a work item to a known functionality, link tests, post findings.
If no match, trigger the full A -> B -> C chain.

**Trigger:** Routed from Session 0 with scope hint.

**Keyword matching logic:**
- Extract keywords from work item title and description
- Match against `keywords` array in each Functionality Index entry
- Minimum 2 overlapping keywords required for a confirmed match
- Below threshold: post comment listing closest partial matches, trigger Session A

**Steps (functionality found):**
1. Read work item and scope hint
2. Read Functionality Index Wiki page
3. Extract keywords, match against index entries
4. Read dedicated Wiki page for matched functionality
5. Read associated test cases from ADO test plans
6. Link relevant test cases to work item via TestedBy-Forward relation
7. Analyze whether bug should have been caught by existing tests
8. Suggest new test cases if coverage appears insufficient
9. Append work item to dedicated Wiki page work items table
10. Append work item to DevinStorage JSON workItems array
11. Post detailed comment: functionality identified, tests linked, coverage opinion,
    suggestions, Wiki link

**Steps (functionality not found):**
1. Post comment listing closest partial matches found if any
2. Trigger Session A -> B -> C chain
3. After chain completes, return to match step

**ADO API calls:**
```
GET  /{org}/{project}/_apis/wit/workitems/{id}?$expand=all&api-version=7.1
GET  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/FunctionalityIndex&includeContent=true&api-version=7.1
GET  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/Functionalities/{slug}&includeContent=true&api-version=7.1
GET  /{org}/{project}/_apis/test/plans/{planId}/suites/{suiteId}/testcases
     ?api-version=7.1
PATCH /{org}/{project}/_apis/wit/workitems/{id}?api-version=7.1
      Content-Type: application/json-patch+json
      [relation: Microsoft.VSTS.Common.TestedBy-Forward]
PUT  /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
     ?path=/Functionalities/{slug}&api-version=7.1
     If-Match: {ETag}
POST /{org}/{project}/_apis/wit/workitems/{id}/comments?api-version=7.1-preview.4
```

**Git operations:**
```
git pull             — DevinStorage
git add / commit / push — DevinStorage
```

**PATs:** `ADO_PAT_WORKITEMS`, `ADO_PAT_WIKI`, `ADO_PAT_TESTS`, DevinStorage read/write
**Target ACU:** <= 3 (found), <= 5 (chain triggered)

---

## Secrets Reference

| Secret | Sessions | Minimum Scope |
|---|---|---|
| `ADO_PAT_WORKITEMS` | 0, A, B, C, D | Work Items: Read & Write |
| `ADO_PAT_WIKI` | B, C, D | Wiki: Read & Write |
| `ADO_PAT_CODE` | A, C | Code (Repositories): Read |
| `ADO_PAT_TESTS` | C, D | Test Management: Read & Write |
| `ADO_ORG_URL` | All | n/a |
| `ADO_PROJECT` | All | n/a |
| `ADO_WIKI_ID` | B, C, D | n/a |
| `ADO_DEFAULT_AREA` | A, C | n/a |

---

## Planned Future Sessions (Not Yet Designed)

**PR Creation Session**
When work is done and a PR needs to be raised — create it with a well-formed
description, link to the relevant work item, follow team conventions, pull context
from the functionality Wiki page to enrich the PR description.

**Bug Deep Triage Session**
Beyond Session D's linking — deeper analysis for bugs specifically. Read the bug,
correlate with functionality documentation, pull blame history and recent commits
on affected files, produce a first-pass interpretation of root cause and where to look.

These two sessions were identified during planning but not yet fully specified.
They will be designed in a follow-up session in Claude Code.

---

## Known ADO API Gotchas

- `Content-Type` for work item create/update must be `application/json-patch+json`
  not `application/json` — wrong type returns 400
- Field names are case-sensitive: `System.Title` not `system.title` or `title`
- Area path and Iteration path use backslash `\` as separator not forward slash
- Wiki PUT updates require ETag from prior GET in `If-Match` header — missing = 409
- Source and target branch refs must include full `refs/heads/` prefix for PR creation
- Reviewer ID must be AAD Object ID (GUID) not display name or email
- Test cases are work items (`$Test%20Case`) not test plan resources
- `System.Description` accepts HTML — plain text needs `<p>` tags

---

## MCP Decision Log

**Microsoft official ADO MCP Server** — public preview, not yet used.
Reason: public preview instability, adds an uncontrolled layer between Devin and ADO.
Revisit when GA.

**RyanCardin15/AzureDevOps-MCP** — community package, not used.
Reason: third-party dependency, trust and maintenance concerns, no security advantage
over current PAT approach since both require the same credentials.

**Decision:** Direct shell scripts with raw ADO REST API calls. Full transparency,
full control, no external dependencies beyond `curl` and `jq`.

---

## Implementation Notes for Claude Code

When continuing implementation in Claude Code:

1. Start with `scripts/ado/auth.sh` — PAT base64 encoding helper used by all scripts
2. Build wiki scripts next (`get-page.sh`, `create-page.sh`, `update-page.sh`) —
   these are the most critical and the ETag handling must be correct
3. Build work item scripts (`comment.sh`, `link-relation.sh`)
4. Build test case scripts
5. Write Playbooks only after scripts are validated
6. Write Knowledge items last — they reference the scripts and docs that exist by then

All scripts should accept org URL, project, and credentials as environment variables
sourced from Devin's Secrets Manager. No hardcoded values anywhere.

---

*Created: 2026-03-25 — mobile planning session*
*Continue implementation: Claude Code*
