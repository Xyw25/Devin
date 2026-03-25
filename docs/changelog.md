# Changelog

All notable changes to scripts and documentation in this repository.

---

## 2026-03-25 — Initial Setup

- Created repository structure
- Added all Knowledge items (`devin/knowledge/`)
- Added all Playbooks (`devin/playbooks/`)
- Added all ADO scripts (`scripts/ado/`)
- Added maintenance scripts (`scripts/maintenance/`)
- Added documentation (`docs/`)
- Added secrets reference and DeepWiki configuration
- Created `README.md` and `INTENT.md`

## 2026-03-25 — Documentation Enhancement Round

- Added `DevinStorage/` folder with best practices, guides, and references
- Added `DevinStorage/best-practices/master-guide.md` — Master best practices guide
- Added `DevinStorage/best-practices/patterns-and-anti-patterns.md` — 10 patterns + 10 anti-patterns
- Added `DevinStorage/best-practices/prompt-engineering.md` — Effective prompt writing for Devin
- Added `DevinStorage/guides/knowledge-writing-guide.md` — Writing effective Knowledge items
- Added `DevinStorage/guides/playbook-writing-guide.md` — Writing effective Playbooks
- Added `DevinStorage/guides/session-sizing-guide.md` — ACU optimization and session scoping
- Added `DevinStorage/guides/scheduling-guide.md` — Cron expressions and automation recipes
- Added `DevinStorage/guides/deepwiki-guide.md` — DeepWiki configuration guide
- Added `DevinStorage/guides/security-guide.md` — Secret management and leak prevention
- Added `DevinStorage/references/session-architecture.md` — Full session flow and artifact diagram
- Added `DevinStorage/references/acu-reference.md` — ACU sizing table and diagnostics
- Added `DevinStorage/references/sources.md` — All external sources with URLs and access dates
- Updated `.devin/wiki.json` — Added 7 repo_notes and "Best Practices & Guides" section
- Updated `docs/changelog.md` — This entry

## 2026-03-25 — DevinStorage Restructure + AzureDevOps Documentation

- Restructured `DevinStorage/` into two top-level sections:
  - `DevinStorage/Devin Documentation/` — moved best-practices/, guides/, references/
  - `DevinStorage/AzureDevOps Documentation/` — new ADO-specific documentation
- Added `AzureDevOps Documentation/api-guides/` (5 files):
  - work-items-guide.md, wiki-guide.md, pull-requests-guide.md,
    test-management-guide.md, authentication-guide.md
- Added `AzureDevOps Documentation/operations/` (3 files):
  - error-handling.md, wiki-etag-workflow.md, test-case-creation.md
- Added `AzureDevOps Documentation/references/` (3 files):
  - field-reference.md, api-gotchas.md (20 gotchas G1-G20), endpoint-catalog.md
- Updated `DevinStorage/README.md` — now indexes both documentation sections
- Updated `.devin/wiki.json` — split into separate Devin and ADO wiki sections

## 2026-03-25 — Daily Doc Monitor Playbook

- Added `devin/playbooks/session-doc-monitor.md` — daily Devin documentation monitoring playbook
  - Checks 11 source URLs (docs.devin.ai, cognition.ai/blog) for changes
  - Updates local files in `DevinStorage/Devin Documentation/` when changes detected
  - Maintains versioned state in `DevinStorage/schedules/doc-monitor-state.json`
  - ACU budget: <= 1 (no changes), <= 5 (with updates)
  - Schedule: daily at 9am UTC (`0 9 * * *`)
- Added `DevinStorage/schedules/doc-monitor-state.json` — initial state file with source mappings
- Added version headers (Version, Last updated, Sources re-verified) to all 12 Devin Documentation files
- Updated `DevinStorage/Devin Documentation/references/sources.md` — added monitoring URLs
- Updated `.devin/wiki.json` — added schedules to indexing and sections

## 2026-03-25 — Major Expansion: 28 ADO Operations + Comprehensive Documentation

### New Scripts (12 scripts)
- `scripts/ado/work-items/create-bug.sh` — Create Bug with repro steps, severity, priority
- `scripts/ado/work-items/get-attachments.sh` — List attachments on a work item
- `scripts/ado/work-items/download-attachment.sh` — Download attachment by URL
- `scripts/ado/work-items/add-attachment.sh` — Upload + link attachment (2-step process)
- `scripts/ado/work-items/query.sh` — Execute WIQL query
- `scripts/ado/work-items/get-comments.sh` — List comments on work item
- `scripts/ado/pull-requests/add-comment.sh` — Add comment thread to PR
- `scripts/ado/pull-requests/link-work-item.sh` — Link work item to existing PR
- `scripts/ado/pull-requests/get.sh` — Get PR details or list active PRs
- `scripts/ado/tests/get-case-detail.sh` — Get full test case work item details
- `scripts/ado/repos/list.sh` — List all repos in project
- `scripts/ado/repos/get.sh` — Get repo details by name or ID
- `scripts/ado/repos/clone.sh` — Clone repo with PAT authentication

### New Knowledge Items (4 items)
- `devin/knowledge/ado-attachments.md` — Attachment operations, 2-step upload
- `devin/knowledge/ado-queries.md` — WIQL syntax, common patterns
- `devin/knowledge/ado-repos.md` — Repository API, clone URLs
- `devin/knowledge/ado-pr-comments.md` — PR comment threads, inline comments

### New Playbooks (4 playbooks)
- `devin/playbooks/session-pr-creation.md` — PR lifecycle with enriched context
- `devin/playbooks/session-bug-triage-deep.md` — Deep bug analysis with attachments
- `devin/playbooks/session-attachment-handler.md` — Attachment operations
- `devin/playbooks/session-ado-interaction-catalog.md` — Quick reference for all 28 ADO operations

### Expanded Devin Documentation (all 12 files + 3 new)
- All files expanded to v2.0.0 with deeper content, timestamps, source references
- `patterns-and-anti-patterns.md` — expanded from 10+10 to 15+15
- `prompt-engineering.md` — added cost-per-prompt analysis, complexity tiers
- `session-sizing-guide.md` — added decision tree, cumulative cost calculator
- `scheduling-guide.md` — added state persistence patterns, cron gotchas
- `security-guide.md` — added leak detection checklist, incident response steps
- `deepwiki-guide.md` — added wiki.json schema reference, limits table
- NEW: `guides/error-recovery-guide.md` — diagnosis flowchart, failure modes
- NEW: `guides/secrets-management-guide.md` — Secrets Manager deep-dive
- NEW: `references/glossary.md` — 30+ terms defined

### Expanded AzureDevOps Documentation (all 11 files + 6 new)
- `work-items-guide.md` — added WIQL, attachments, comments, bug creation
- `pull-requests-guide.md` — added PR comments, work item linking, get/list
- `test-management-guide.md` — added get case detail
- `endpoint-catalog.md` — expanded from 16 to 28 endpoints
- `api-gotchas.md` — expanded from G1-G20 to G1-G30
- `error-handling.md` — added new error scenarios (413, WIQL parse, etc.)
- NEW: `api-guides/repositories-guide.md` — Repos API
- NEW: `api-guides/attachments-guide.md` — Attachments 2-step upload
- NEW: `api-guides/queries-guide.md` — WIQL reference
- NEW: `operations/attachment-workflow.md` — Upload/download steps
- NEW: `operations/pr-comment-workflow.md` — PR comment operations
- NEW: `operations/bug-creation-workflow.md` — Bug creation with repro steps

### Updated Infrastructure
- `README.md` — reflects 28 operations, 11 knowledge, 10 playbooks, 8 sessions
- `DevinStorage/README.md` — updated indexes for all new files
- `AzureDevOps Documentation/README.md` — updated with 8 API guides, 6 operations, 3 references
- `.devin/wiki.json` — added ADO Operations Coverage note, updated script count
