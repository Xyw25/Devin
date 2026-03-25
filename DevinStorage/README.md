# DevinStorage — Documentation Hub

> Created: 2026-03-25
> Last updated: 2026-03-25

Central documentation hub containing two major sections:
Devin platform guidance and Azure DevOps API documentation.

---

## Devin Documentation

Best practices, guides, and references for operating Devin effectively.

| Folder | Contents |
|--------|----------|
| [best-practices/](Devin%20Documentation/best-practices/) | Master guide, patterns & anti-patterns, prompt engineering |
| [guides/](Devin%20Documentation/guides/) | Knowledge writing, playbook writing, session sizing, scheduling, DeepWiki, security, error recovery, secrets management |
| [references/](Devin%20Documentation/references/) | Session architecture, ACU reference, external sources, glossary |

**Start here:** [Master Guide](Devin%20Documentation/best-practices/master-guide.md)

### File Index

#### Best Practices
- [master-guide.md](Devin%20Documentation/best-practices/master-guide.md) — Single entry point for all Devin usage guidance (14 sections)
- [patterns-and-anti-patterns.md](Devin%20Documentation/best-practices/patterns-and-anti-patterns.md) — 15 patterns + 15 anti-patterns with examples
- [prompt-engineering.md](Devin%20Documentation/best-practices/prompt-engineering.md) — Writing effective prompts, templates, cost-per-prompt analysis

#### Guides
- [knowledge-writing-guide.md](Devin%20Documentation/guides/knowledge-writing-guide.md) — Structure, triggers, content rules, specificity scoring
- [playbook-writing-guide.md](Devin%20Documentation/guides/playbook-writing-guide.md) — 5-section structure, deliverables, iteration strategy, real examples
- [session-sizing-guide.md](Devin%20Documentation/guides/session-sizing-guide.md) — ACU optimization, decision tree, cumulative cost calculator
- [scheduling-guide.md](Devin%20Documentation/guides/scheduling-guide.md) — Cron expressions, state persistence, cost calculator, gotchas
- [deepwiki-guide.md](Devin%20Documentation/guides/deepwiki-guide.md) — wiki.json schema, limits, repo_notes best practices
- [security-guide.md](Devin%20Documentation/guides/security-guide.md) — Secret management, leak detection, incident response, PAT rotation
- [error-recovery-guide.md](Devin%20Documentation/guides/error-recovery-guide.md) — Diagnosis flowchart, failure modes, recovery patterns
- [secrets-management-guide.md](Devin%20Documentation/guides/secrets-management-guide.md) — Devin Secrets Manager deep-dive, naming, rotation

#### References
- [session-architecture.md](Devin%20Documentation/references/session-architecture.md) — Session flow diagram, decision matrix, artifact flow, error recovery
- [acu-reference.md](Devin%20Documentation/references/acu-reference.md) — ACU sizing table, real measurements, optimization strategies
- [sources.md](Devin%20Documentation/references/sources.md) — All external sources with URLs, access dates, monitoring status
- [glossary.md](Devin%20Documentation/references/glossary.md) — 30+ terms defined with cross-references

---

## AzureDevOps Documentation

Complete Azure DevOps REST API documentation covering all 28 operations
used by this organization's Devin automation pipeline.

| Folder | Contents |
|--------|----------|
| [api-guides/](AzureDevOps%20Documentation/api-guides/) | Work items, wiki, PRs, tests, auth, repos, attachments, queries |
| [operations/](AzureDevOps%20Documentation/operations/) | Error handling, ETag workflow, test creation, attachments, PR comments, bugs |
| [references/](AzureDevOps%20Documentation/references/) | Field reference, API gotchas (G1-G30), endpoint catalog (28 endpoints) |

**Start here:** [AzureDevOps README](AzureDevOps%20Documentation/README.md)

### File Index

#### API Guides
- [work-items-guide.md](AzureDevOps%20Documentation/api-guides/work-items-guide.md) — CRUD, comments, relations, WIQL, attachments, bug creation
- [wiki-guide.md](AzureDevOps%20Documentation/api-guides/wiki-guide.md) — Page CRUD with ETag workflow
- [pull-requests-guide.md](AzureDevOps%20Documentation/api-guides/pull-requests-guide.md) — Creation, reviewers, completion, comments, work item linking
- [test-management-guide.md](AzureDevOps%20Documentation/api-guides/test-management-guide.md) — Plans, suites, test case creation, TestedBy, case details
- [authentication-guide.md](AzureDevOps%20Documentation/api-guides/authentication-guide.md) — PAT construction, scopes, rotation
- [repositories-guide.md](AzureDevOps%20Documentation/api-guides/repositories-guide.md) — List, get, clone URL construction
- [attachments-guide.md](AzureDevOps%20Documentation/api-guides/attachments-guide.md) — 2-step upload, download, size limits
- [queries-guide.md](AzureDevOps%20Documentation/api-guides/queries-guide.md) — WIQL syntax, patterns, operators

#### Operations
- [error-handling.md](AzureDevOps%20Documentation/operations/error-handling.md) — HTTP status diagnosis, recovery, new error scenarios
- [wiki-etag-workflow.md](AzureDevOps%20Documentation/operations/wiki-etag-workflow.md) — Step-by-step ETag workflow
- [test-case-creation.md](AzureDevOps%20Documentation/operations/test-case-creation.md) — XML steps format with examples
- [attachment-workflow.md](AzureDevOps%20Documentation/operations/attachment-workflow.md) — Upload/download step-by-step
- [pr-comment-workflow.md](AzureDevOps%20Documentation/operations/pr-comment-workflow.md) — General and inline PR comments
- [bug-creation-workflow.md](AzureDevOps%20Documentation/operations/bug-creation-workflow.md) — Bugs with HTML repro steps

#### References
- [field-reference.md](AzureDevOps%20Documentation/references/field-reference.md) — All fields, types, relations, state values
- [api-gotchas.md](AzureDevOps%20Documentation/references/api-gotchas.md) — 30 known gotchas (G1-G30)
- [endpoint-catalog.md](AzureDevOps%20Documentation/references/endpoint-catalog.md) — Complete 28-endpoint catalog with methods and Content-Types
