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
