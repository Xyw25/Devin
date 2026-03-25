# DevinStorage — Devin Operations & ADO Best Practices

> Central repository for Devin Knowledge, Playbooks, Skills, scripts,
> and historical analysis records. This repo is always present on Devin's
> machine snapshot and serves as the persistent handoff layer between sessions.

---

## What This Repo Is

DevinStorage has four jobs:

1. **Teach Devin** how to operate correctly in this environment before any session
   starts — via Knowledge items, Skills, and Playbooks stored here and indexed
   by DeepWiki.

2. **Store analysis history** — every functionality that Devin has analyzed lives
   here as a structured JSON file, persisting across sessions and building over time.

3. **Provide hardened scripts** for all ADO operations so Devin never improvises
   raw API calls from scratch.

4. **Document ADO API best practices** so Devin has a reliable local reference
   and never needs to search online for basic operation details.

---

## Repository Structure

```
/
├── README.md                          <- This file. Start here.
├── INTENT.md                          <- Full design intent, session architecture,
│                                         planning notes, and all API call details.
│                                         Read before building anything.
│
├── analyses/                          <- Devin writes here. Never edit manually.
│   └── {product}/
│       └── {functionality-slug}.json  <- One JSON file per functionality
│
├── devin/
│   ├── knowledge/                     <- Paste into Devin Settings > Knowledge
│   │   ├── ado-auth.md                <- PAT format, header construction, scopes
│   │   ├── ado-work-items.md          <- Field names, patch format, relations
│   │   ├── ado-wiki.md                <- Page CRUD, ETag requirement, paths
│   │   ├── ado-pull-requests.md       <- PR creation, reviewers, completion options
│   │   ├── ado-tests.md               <- Test plans, suites, case creation
│   │   ├── ado-error-handling.md      <- Known errors and correct fixes
│   │   └── environment.md             <- Org URL, project, wiki ID, area paths
│   │
│   ├── playbooks/                     <- Import into Devin Settings > Playbooks
│   │   ├── session-0-precheck.md
│   │   ├── session-a-code-analysis.md
│   │   ├── session-b-documentation.md
│   │   ├── session-c-test-coverage.md
│   │   └── session-d-triage.md
│   │
│   └── secrets/
│       └── secrets-reference.md       <- Naming conventions only. No values here.
│
├── scripts/
│   ├── ado/
│   │   ├── auth.sh                    <- PAT base64 encoding helper
│   │   ├── work-items/
│   │   │   ├── get.sh                 <- GET work item by ID
│   │   │   ├── create.sh              <- POST new work item
│   │   │   ├── update.sh              <- PATCH work item fields
│   │   │   ├── comment.sh             <- POST comment on work item
│   │   │   └── link-relation.sh       <- PATCH to add TestedBy or other relation
│   │   ├── wiki/
│   │   │   ├── get-page.sh            <- GET wiki page + capture ETag
│   │   │   ├── create-page.sh         <- PUT new wiki page
│   │   │   └── update-page.sh         <- PUT update wiki page with ETag
│   │   ├── pull-requests/
│   │   │   ├── create.sh              <- POST new PR with reviewers and work item links
│   │   │   ├── update.sh              <- PATCH PR status or completion options
│   │   │   └── add-reviewer.sh        <- PUT reviewer by AAD Object ID
│   │   └── tests/
│   │       ├── get-plans.sh           <- GET test plans
│   │       ├── get-cases.sh           <- GET test cases in a suite
│   │       └── create-case.sh         <- POST new test case work item
│   │
│   └── maintenance/
│       ├── check-api-versions.sh      <- Detect deprecated API versions in scripts
│       └── validate-scripts.sh        <- Smoke-test all scripts
│
├── docs/
│   ├── ado-api-reference.md           <- Canonical ADO API notes for this org
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

Five sessions handle the full lifecycle. Full details, all API calls,
and all design decisions are in `INTENT.md`.

| Session | Name | Entry Condition | Target ACU |
|---|---|---|---|
| 0 | Pre-check & Router | Work item arrives | <= 1 |
| A | Code Analysis | Session 0 -> not found or outdated | <= 5 |
| B | Documentation | Session A completes or is current | <= 3 |
| C | Test Coverage | Session B completes or updates | <= 5 |
| D | Triage & Linking | Session 0 -> functionality found | <= 3 |

---

## Secrets Reference

| Secret Name | Purpose | Minimum Scope |
|---|---|---|
| `ADO_PAT_WORKITEMS` | Read/write work items, post comments, add relations | Work Items: Read & Write |
| `ADO_PAT_WIKI` | Read and write ADO Wiki pages | Wiki: Read & Write |
| `ADO_PAT_CODE` | Clone and read repositories | Code: Read |
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

---

## ADO API Version

All scripts pin to **`api-version=7.1`**. Preview versions (`7.1-preview.*`)
are not used in production scripts. The maintenance scripts check for
deprecation notices on this version periodically.

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
