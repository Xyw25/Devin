# AzureDevOps Documentation

> Created: 2026-03-25
> API Version: 7.1 (pinned across all operations)

Comprehensive Azure DevOps REST API documentation, operational guides,
and reference material for this organization's Devin automation pipeline.

---

## API Guides

| File | Description |
|------|-------------|
| [work-items-guide.md](api-guides/work-items-guide.md) | Complete Work Items API — fields, CRUD, comments, relations, JSON Patch format |
| [wiki-guide.md](api-guides/wiki-guide.md) | Wiki Pages API — CRUD with ETag workflow, page structure, Functionality Index |
| [pull-requests-guide.md](api-guides/pull-requests-guide.md) | Pull Requests API — creation, reviewers, completion, branch ref format |
| [test-management-guide.md](api-guides/test-management-guide.md) | Test Management — plans, suites, test case creation, TestedBy linking |
| [authentication-guide.md](api-guides/authentication-guide.md) | PAT authentication — header construction, scopes, rotation |

## Operations

| File | Description |
|------|-------------|
| [error-handling.md](operations/error-handling.md) | Error diagnosis — HTTP status codes, root causes, recovery procedures |
| [wiki-etag-workflow.md](operations/wiki-etag-workflow.md) | Step-by-step ETag workflow for all Wiki operations |
| [test-case-creation.md](operations/test-case-creation.md) | Creating test cases as work items with XML steps format |

## References

| File | Description |
|------|-------------|
| [field-reference.md](references/field-reference.md) | All work item fields, types, relation types, and state values |
| [api-gotchas.md](references/api-gotchas.md) | Every known ADO API gotcha collected in one place |
| [endpoint-catalog.md](references/endpoint-catalog.md) | Complete endpoint catalog with methods and Content-Types |
