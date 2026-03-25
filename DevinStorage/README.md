# DevinStorage — Documentation Hub

> Created: 2026-03-25

Central documentation hub containing two major sections:
Devin platform guidance and Azure DevOps API documentation.

---

## Devin Documentation

Best practices, guides, and references for operating Devin effectively.

| Folder | Contents |
|--------|----------|
| [best-practices/](Devin%20Documentation/best-practices/) | Master guide, patterns & anti-patterns, prompt engineering |
| [guides/](Devin%20Documentation/guides/) | Knowledge writing, playbook writing, session sizing, scheduling, DeepWiki, security |
| [references/](Devin%20Documentation/references/) | Session architecture, ACU reference, external sources |

**Start here:** [Master Guide](Devin%20Documentation/best-practices/master-guide.md)

### File Index

#### Best Practices
- [master-guide.md](Devin%20Documentation/best-practices/master-guide.md) — Single entry point for all Devin usage guidance
- [patterns-and-anti-patterns.md](Devin%20Documentation/best-practices/patterns-and-anti-patterns.md) — 10 patterns + 10 anti-patterns with examples
- [prompt-engineering.md](Devin%20Documentation/best-practices/prompt-engineering.md) — Writing effective prompts, templates, cost-aware techniques

#### Guides
- [knowledge-writing-guide.md](Devin%20Documentation/guides/knowledge-writing-guide.md) — Structure, triggers, content rules for Knowledge items
- [playbook-writing-guide.md](Devin%20Documentation/guides/playbook-writing-guide.md) — 5-section structure, deliverables, iteration strategy
- [session-sizing-guide.md](Devin%20Documentation/guides/session-sizing-guide.md) — ACU optimization, scoping, chaining, when to stop
- [scheduling-guide.md](Devin%20Documentation/guides/scheduling-guide.md) — Cron expressions, automation recipes, state persistence
- [deepwiki-guide.md](Devin%20Documentation/guides/deepwiki-guide.md) — wiki.json configuration, repo_notes, indexing
- [security-guide.md](Devin%20Documentation/guides/security-guide.md) — Secret management, leak prevention, PAT rotation

#### References
- [session-architecture.md](Devin%20Documentation/references/session-architecture.md) — Session flow diagram, decision matrix, artifact flow
- [acu-reference.md](Devin%20Documentation/references/acu-reference.md) — ACU sizing table, diagnostics, optimization strategies
- [sources.md](Devin%20Documentation/references/sources.md) — All external sources with URLs and access dates

---

## AzureDevOps Documentation

Complete Azure DevOps REST API documentation for this organization's automation pipeline.

| Folder | Contents |
|--------|----------|
| [api-guides/](AzureDevOps%20Documentation/api-guides/) | Work items, wiki, pull requests, test management, authentication |
| [operations/](AzureDevOps%20Documentation/operations/) | Error handling, ETag workflow, test case creation |
| [references/](AzureDevOps%20Documentation/references/) | Field reference, API gotchas, endpoint catalog |

**Start here:** [AzureDevOps README](AzureDevOps%20Documentation/README.md)

### File Index

#### API Guides
- [work-items-guide.md](AzureDevOps%20Documentation/api-guides/work-items-guide.md) — CRUD, comments, relations, JSON Patch format
- [wiki-guide.md](AzureDevOps%20Documentation/api-guides/wiki-guide.md) — Page CRUD with ETag workflow
- [pull-requests-guide.md](AzureDevOps%20Documentation/api-guides/pull-requests-guide.md) — Creation, reviewers, completion
- [test-management-guide.md](AzureDevOps%20Documentation/api-guides/test-management-guide.md) — Plans, suites, test case creation, TestedBy
- [authentication-guide.md](AzureDevOps%20Documentation/api-guides/authentication-guide.md) — PAT construction, scopes, rotation

#### Operations
- [error-handling.md](AzureDevOps%20Documentation/operations/error-handling.md) — HTTP status diagnosis, recovery procedures
- [wiki-etag-workflow.md](AzureDevOps%20Documentation/operations/wiki-etag-workflow.md) — Step-by-step ETag workflow
- [test-case-creation.md](AzureDevOps%20Documentation/operations/test-case-creation.md) — XML steps format with examples

#### References
- [field-reference.md](AzureDevOps%20Documentation/references/field-reference.md) — All fields, types, relations, state values
- [api-gotchas.md](AzureDevOps%20Documentation/references/api-gotchas.md) — 20 known gotchas (G1-G20)
- [endpoint-catalog.md](AzureDevOps%20Documentation/references/endpoint-catalog.md) — Complete endpoint table with methods and Content-Types
