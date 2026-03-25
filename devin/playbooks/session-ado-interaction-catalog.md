# Session ADO-Interaction-Catalog — Quick Reference for All ADO Operations

## Purpose

Meta-playbook serving as a quick reference card for all 28 ADO operations.
Use this to find the right script for any ADO interaction.

**This is NOT an executable session** — it's a reference document attached as a
playbook so Devin can quickly look up which script to use for any operation.

---

## Work Items (11 Operations)

| # | Operation | Script | PAT | Content-Type |
|---|-----------|--------|-----|-------------|
| 1 | Get work item | `work-items/get.sh <id>` | WORKITEMS | — |
| 2 | Create work item | `work-items/create.sh <type> <body>` | WORKITEMS | json-patch+json |
| 3 | Update work item | `work-items/update.sh <id> <body>` | WORKITEMS | json-patch+json |
| 4 | Post comment | `work-items/comment.sh <id> <html>` | WORKITEMS | json |
| 5 | Add relation | `work-items/link-relation.sh <src> <rel> <tgt>` | WORKITEMS | json-patch+json |
| 6 | Create bug with repro | `work-items/create-bug.sh <title> <repro> [sev] [pri]` | WORKITEMS | json-patch+json |
| 7 | List attachments | `work-items/get-attachments.sh <id>` | WORKITEMS | — |
| 8 | Download attachment | `work-items/download-attachment.sh <url> <path>` | WORKITEMS | — |
| 9 | Upload attachment | `work-items/add-attachment.sh <id> <file> [comment]` | WORKITEMS | octet-stream + json-patch+json |
| 10 | WIQL query | `work-items/query.sh <wiql>` | WORKITEMS | json |
| 11 | List comments | `work-items/get-comments.sh <id> [top] [order]` | WORKITEMS | — |

## Pull Requests (6 Operations)

| # | Operation | Script | PAT | Content-Type |
|---|-----------|--------|-----|-------------|
| 1 | Create PR | `pull-requests/create.sh <repo> <src> <tgt> <title> <desc> [reviewers] [wis]` | CODE | json |
| 2 | Update PR | `pull-requests/update.sh <repo> <pr-id> <body>` | CODE | json |
| 3 | Add reviewer | `pull-requests/add-reviewer.sh <repo> <pr-id> <reviewer-aad-id>` | CODE | json |
| 4 | Add comment | `pull-requests/add-comment.sh <repo> <pr-id> <text> [status]` | CODE | json |
| 5 | Link work item to PR | `pull-requests/link-work-item.sh <wi-id> <repo> <pr-id>` | WORKITEMS | json-patch+json |
| 6 | Get/list PRs | `pull-requests/get.sh <repo> [pr-id]` | CODE | — |

## Wiki (4 Operations)

| # | Operation | Script | PAT | Headers |
|---|-----------|--------|-----|---------|
| 1 | Get page + ETag | `wiki/get-page.sh <path>` | WIKI | — |
| 2 | Create page | `wiki/create-page.sh <path> <content>` | WIKI | — |
| 3 | Update page | `wiki/update-page.sh <path> <content> <etag>` | WIKI | If-Match: {ETag} |
| 4 | List wikis | (inline curl — no dedicated script) | WIKI | — |

## Test Management (4 Operations)

| # | Operation | Script | PAT |
|---|-----------|--------|-----|
| 1 | List test plans | `tests/get-plans.sh` | TESTS |
| 2 | List test cases | `tests/get-cases.sh <plan-id> <suite-id>` | TESTS |
| 3 | Create test case | `tests/create-case.sh <title> <steps-xml> [area]` | WORKITEMS |
| 4 | Get test case detail | `tests/get-case-detail.sh <id>` | WORKITEMS |

## Repository Operations (3 Operations)

| # | Operation | Script | PAT |
|---|-----------|--------|-----|
| 1 | Clone repo | `repos/clone.sh <repo-name> [target-dir]` | CODE (raw PAT) |
| 2 | List repos | `repos/list.sh` | CODE |
| 3 | Get repo details | `repos/get.sh <repo-name-or-id>` | CODE |

---

## PAT Quick Reference

| PAT Name | Script Prefix | Scope |
|----------|--------------|-------|
| `ADO_PAT_WORKITEMS` | work-items/*, tests/create-case, pull-requests/link-work-item | Work Items: R&W |
| `ADO_PAT_WIKI` | wiki/* | Wiki: R&W |
| `ADO_PAT_CODE` | pull-requests/create,update,add-reviewer,add-comment,get; repos/* | Code: Read |
| `ADO_PAT_TESTS` | tests/get-plans, tests/get-cases | Test Management: R&W |

---

## Usage Pattern

All scripts require the same setup:
```bash
# 1. Source auth helper with appropriate PAT
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"

# 2. Run the script
bash scripts/ado/work-items/get.sh 12345

# 3. Switch PAT for different domain
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"
```

---

## Content-Type Rules

| Body Format | Content-Type |
|-------------|-------------|
| JSON Patch array `[{"op":...}]` | `application/json-patch+json` |
| Regular JSON object `{...}` | `application/json` |
| Binary file upload | `application/octet-stream` |
| GET requests | (none) |
