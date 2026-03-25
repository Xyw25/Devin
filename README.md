# Devin — Process Control & ADO Automation

> Central repository for Devin Knowledge, Playbooks, Skills, scripts,
> and historical analysis records. This repo is always present on Devin's
> machine snapshot and serves as the persistent handoff layer between sessions.

---

## What This Repo Is

This repo has five jobs:

1. **Teach Devin** how to operate correctly in this environment before any session
   starts — via Knowledge items (12), Playbooks (10), and DeepWiki indexing.

2. **Store analysis history** — every functionality that Devin has analyzed lives
   here as a structured JSON file, persisting across sessions and building over time.

3. **Provide hardened scripts** for all 28 ADO operations so Devin never improvises
   raw API calls from scratch.

4. **Document ADO API best practices** so Devin has a reliable local reference
   and never needs to search online for basic operation details.

5. **Comprehensive Devin platform documentation** — best practices, guides,
   patterns, anti-patterns, and references for operating Devin effectively.

---

## Repository Structure

```
/
├── README.md                          <- This file. Start here.
├── INTENT.md                          <- Full design intent, session architecture,
│                                         planning notes, and all API call details.
│
├── analyses/                          <- Devin writes here. Never edit manually.
│   └── {product}/
│       └── {functionality-slug}.json  <- One JSON file per functionality
│
├── devin/
│   ├── knowledge/                     <- Paste into Devin Settings > Knowledge (11 items)
│   │   ├── ado-auth.md                <- PAT format, header construction, scopes
│   │   ├── ado-work-items.md          <- Field names, patch format, relations
│   │   ├── ado-wiki.md                <- Page CRUD, ETag requirement, paths
│   │   ├── ado-pull-requests.md       <- PR creation, reviewers, completion options
│   │   ├── ado-tests.md               <- Test plans, suites, case creation
│   │   ├── ado-error-handling.md      <- Known errors and correct fixes
│   │   ├── ado-attachments.md         <- Attachment upload/download, 2-step process
│   │   ├── ado-queries.md             <- WIQL query syntax and patterns
│   │   ├── ado-repos.md               <- Repository listing, details, clone URLs
│   │   ├── ado-pr-comments.md         <- PR comment threads, inline code comments
│   │   └── environment.md             <- Org URL, project, wiki ID, area paths
│   │
│   ├── playbooks/                     <- Import into Devin Settings > Playbooks (10 playbooks)
│   │   ├── session-0-precheck.md      <- Gate check: tag, state, description
│   │   ├── session-a-code-analysis.md <- Analyze codebase, write JSON
│   │   ├── session-b-documentation.md <- Create/update Wiki pages
│   │   ├── session-c-test-coverage.md <- Find/create tests, link, update Wiki
│   │   ├── session-d-triage.md        <- Match to functionality, link tests
│   │   ├── session-doc-monitor.md     <- Daily doc source monitoring
│   │   ├── session-pr-creation.md     <- PR lifecycle with enriched context
│   │   ├── session-bug-triage-deep.md <- Deep bug analysis with attachments
│   │   ├── session-attachment-handler.md <- Attachment operations
│   │   └── session-ado-doc-monitor.md <- Weekly ADO API doc monitoring
│   │
│   └── secrets/
│       └── secrets-reference.md       <- Naming conventions only. No values here.
│
├── scripts/
│   ├── ado/
│   │   ├── auth.sh                    <- PAT base64 encoding helper
│   │   ├── work-items/                <- 11 scripts
│   │   │   ├── get.sh                 <- GET work item by ID
│   │   │   ├── create.sh              <- POST new work item
│   │   │   ├── update.sh              <- PATCH work item fields
│   │   │   ├── comment.sh             <- POST comment on work item
│   │   │   ├── link-relation.sh       <- PATCH to add TestedBy or other relation
│   │   │   ├── create-bug.sh          <- POST Bug with repro steps, severity, priority
│   │   │   ├── get-attachments.sh     <- List attachments on a work item
│   │   │   ├── download-attachment.sh <- Download attachment by URL
│   │   │   ├── add-attachment.sh      <- Upload + link attachment (2-step)
│   │   │   ├── query.sh              <- Execute WIQL query
│   │   │   └── get-comments.sh        <- List comments on work item
│   │   ├── wiki/                      <- 3 scripts
│   │   │   ├── get-page.sh            <- GET wiki page + capture ETag
│   │   │   ├── create-page.sh         <- PUT new wiki page
│   │   │   └── update-page.sh         <- PUT update wiki page with ETag
│   │   ├── pull-requests/             <- 6 scripts
│   │   │   ├── create.sh              <- POST new PR with reviewers and work item links
│   │   │   ├── update.sh              <- PATCH PR status or completion options
│   │   │   ├── add-reviewer.sh        <- PUT reviewer by AAD Object ID
│   │   │   ├── add-comment.sh         <- POST comment thread on PR
│   │   │   ├── link-work-item.sh      <- Link work item to existing PR
│   │   │   └── get.sh                 <- GET PR details or list active PRs
│   │   ├── tests/                     <- 4 scripts
│   │   │   ├── get-plans.sh           <- GET test plans
│   │   │   ├── get-cases.sh           <- GET test cases in a suite
│   │   │   ├── create-case.sh         <- POST new test case work item
│   │   │   └── get-case-detail.sh     <- GET full test case details
│   │   └── repos/                     <- 3 scripts
│   │       ├── list.sh                <- List all repos in project
│   │       ├── get.sh                 <- GET repo details by name or ID
│   │       └── clone.sh               <- Clone repo with PAT auth
│   │
│   └── maintenance/
│       ├── check-api-versions.sh      <- Detect deprecated API versions in scripts
│       └── validate-scripts.sh        <- Smoke-test all scripts
│
├── DevinStorage/                      <- Documentation hub
│   ├── README.md                      <- Documentation index
│   ├── Devin Documentation/           <- 15 files: best practices, guides, references
│   ├── AzureDevOps Documentation/     <- 18 files: API guides, operations, references
│   └── schedules/                     <- State files for scheduled tasks
│
├── schemas/                           <- Output format definitions
│   ├── analysis-json.schema.md        <- JSON structure for analyses/ files
│   ├── wiki-functionality-page.template.md <- Wiki page markdown template
│   ├── wiki-functionality-index-row.template.md <- Index table row format
│   ├── work-item-comment.template.md  <- HTML comment templates per session
│   ├── bug-findings-comment.template.md <- Bug triage findings format
│   └── pr-description.template.md     <- PR description markdown format
│
├── docs/
│   ├── ado-api-reference.md           <- Canonical ADO API notes for this org
│   ├── ado-operation-reference.md     <- Quick reference for all 28 ADO operations
│   ├── field-reference.md             <- Work item fields, types, allowed values
│   ├── error-catalog.md               <- Every error encountered and its resolution
│   └── changelog.md                   <- Script and doc changes over time
│
└── .devin/
    └── wiki.json                      <- DeepWiki indexing configuration
```

---

## The Only Trigger Tag

**`devin-process`** — added to a work item to signal Devin should process it.

No tag = Session 0 exits immediately. No other tags are used.
All internal state (analyzed, documented, tested) is tracked via commit SHA
checks, Wiki page existence, and test relation checks — not tags.

---

## Session Overview

Eight sessions handle the full lifecycle plus specialized operations.
Full details, all API calls, and all design decisions are in `INTENT.md`.

| Session | Name | Entry Condition | Target ACU |
|---|---|---|---|
| 0 | Pre-check & Router | Work item arrives | <= 1 |
| A | Code Analysis | Session 0 -> not found or outdated | <= 5 |
| B | Documentation | Session A completes or is current | <= 3 |
| C | Test Coverage | Session B completes or updates | <= 5 |
| D | Triage & Linking | Session 0 -> functionality found | <= 3 |
| PR | PR Creation | After implementation | <= 3 |
| BT | Bug Deep Triage | Complex bugs after Session D | <= 5 |
| Doc-Monitor | Daily Doc Check | Scheduled daily 9am UTC | <= 5 |
| ATT | Attachment Handler | On-demand (utility) | <= 2 |
| ADO-Monitor | ADO Doc Check | Weekly Monday 10am UTC | <= 5 |

---

## ADO Operations (28 Total)

| Domain | Count | Scripts |
|--------|-------|---------|
| Work Items | 11 | CRUD, comments, relations, WIQL, attachments, bugs |
| Pull Requests | 6 | Create, update, review, comment, link, get |
| Wiki | 3 | Get page, create page, update page (ETag) |
| Tests | 4 | Plans, cases, create case, get detail |
| Repositories | 3 | List, get, clone |

---

## Secrets Reference

| Secret Name | Purpose | Minimum Scope |
|---|---|---|
| `ADO_PAT_WORKITEMS` | Read/write work items, post comments, add relations, attachments | Work Items: Read & Write |
| `ADO_PAT_WIKI` | Read and write ADO Wiki pages | Wiki: Read & Write |
| `ADO_PAT_CODE` | Clone repos, create/manage PRs | Code: Read |
| `ADO_PAT_TESTS` | Read and create test plans and cases | Test Management: Read & Write |
| `ADO_ORG_URL` | Base org URL | n/a |
| `ADO_PROJECT` | Default project name | n/a |
| `ADO_WIKI_ID` | Target wiki identifier | n/a |
| `ADO_DEFAULT_AREA` | Default area path for new items | n/a |

---

## Hard Rules for Devin

- Read `INTENT.md` before starting any session work
- Check `analyses/` before analyzing any functionality
- Compare `lastAnalyzedCommit` to current HEAD before re-analyzing
- Session A scope: one level deep only, hard stop at 5 models and 10 entry points
- Always GET a Wiki page and store its ETag before any PUT update
- Use scripts in `scripts/ado/` — never write raw curl calls from scratch
- Check `docs/error-catalog.md` before any other action when an ADO call fails
- Never search online for ADO API details
- Post a comment on the originating work item at the end of every session
- Append the work item ID to the functionality's `workItems` array in `analyses/`
- Attachment uploads are always 2-step: upload blob, then link to work item
- Always check attachments on bugs before starting analysis

---

## ADO API Version

All scripts pin to **`api-version=7.1`**. Preview versions (`7.1-preview.*`)
are not used in production scripts except the comments API (`7.1-preview.4`).

---

## MCP Note

An official Microsoft ADO MCP Server (public preview) and a community server
(`AzureDevOps-MCP` by RyanCardin15) both exist. Neither is used here by design.
Scripts in `scripts/ado/` are preferred — transparent, controlled, no external
dependency. Revisit if maintenance becomes burdensome.

---

## Continuing Development

All planning notes, full session steps, specific API calls, design decisions,
and the DevinStorage JSON schema are in **`INTENT.md`**.

Start there before building any Playbook, Knowledge item, or script.

*Last updated: 2026-03-25*
