# AzureDevOps Documentation

> Created: 2026-03-25
> Last updated: 2026-03-25
> API Version: 7.1 (pinned across all operations)

Comprehensive Azure DevOps REST API documentation, operational guides,
and reference material for this organization's Devin automation pipeline.

Covers all **28 ADO operations** across 5 domains: work items, pull requests,
wiki, test management, and repositories.

---

## API Guides

| File | Description |
|------|-------------|
| [work-items-guide.md](api-guides/work-items-guide.md) | Work Items API — CRUD, comments, relations, WIQL queries, attachments, bug creation |
| [wiki-guide.md](api-guides/wiki-guide.md) | Wiki Pages API — CRUD with ETag workflow, page structure, Functionality Index |
| [pull-requests-guide.md](api-guides/pull-requests-guide.md) | Pull Requests API — creation, reviewers, completion, comment threads, work item linking |
| [test-management-guide.md](api-guides/test-management-guide.md) | Test Management — plans, suites, test case creation, TestedBy linking, case details |
| [authentication-guide.md](api-guides/authentication-guide.md) | PAT authentication — header construction, scopes, rotation |
| [repositories-guide.md](api-guides/repositories-guide.md) | Repositories API — list, get details, clone URL construction |
| [attachments-guide.md](api-guides/attachments-guide.md) | Attachments API — 2-step upload process, download, size limits |
| [queries-guide.md](api-guides/queries-guide.md) | WIQL Queries — syntax, operators, common patterns, limits |

## Operations

| File | Description |
|------|-------------|
| [error-handling.md](operations/error-handling.md) | Error diagnosis — HTTP status codes, root causes, recovery procedures |
| [wiki-etag-workflow.md](operations/wiki-etag-workflow.md) | Step-by-step ETag workflow for all Wiki operations |
| [test-case-creation.md](operations/test-case-creation.md) | Creating test cases as work items with XML steps format |
| [attachment-workflow.md](operations/attachment-workflow.md) | Upload and download attachment step-by-step workflow |
| [pr-comment-workflow.md](operations/pr-comment-workflow.md) | Adding general and inline code comments to PRs |
| [bug-creation-workflow.md](operations/bug-creation-workflow.md) | Creating bugs with HTML reproduction steps |

## References

| File | Description |
|------|-------------|
| [field-reference.md](references/field-reference.md) | All work item fields, types, relation types, and state values |
| [api-gotchas.md](references/api-gotchas.md) | 30 known ADO API gotchas (G1-G30) |
| [endpoint-catalog.md](references/endpoint-catalog.md) | Complete 28-endpoint catalog with methods, Content-Types, and scripts |
