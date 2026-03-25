# ADO Endpoint Catalog

> Created: 2026-03-25
> API Version: 7.1
> Base URL: `{ADO_ORG_URL}/{ADO_PROJECT}/_apis/`

---

## Work Items

| Operation | Method | Endpoint | Content-Type | Script |
|-----------|--------|----------|-------------|--------|
| Get work item | GET | `wit/workitems/{id}?$expand=all&api-version=7.1` | — | `work-items/get.sh` |
| Create work item | POST | `wit/workitems/${type}?api-version=7.1` | `application/json-patch+json` | `work-items/create.sh` |
| Update work item | PATCH | `wit/workitems/{id}?api-version=7.1` | `application/json-patch+json` | `work-items/update.sh` |
| Add comment | POST | `wit/workitems/{id}/comments?api-version=7.1-preview.4` | `application/json` | `work-items/comment.sh` |
| Add relation | PATCH | `wit/workitems/{id}?api-version=7.1` | `application/json-patch+json` | `work-items/link-relation.sh` |

## Wiki

| Operation | Method | Endpoint | Content-Type | Headers | Script |
|-----------|--------|----------|-------------|---------|--------|
| List wikis | GET | `wiki/wikis?api-version=7.1` | — | — | — |
| Get page | GET | `wiki/wikis/{wikiId}/pages?path={path}&includeContent=true&api-version=7.1` | — | — | `wiki/get-page.sh` |
| Create page | PUT | `wiki/wikis/{wikiId}/pages?path={path}&api-version=7.1` | `application/json` | — | `wiki/create-page.sh` |
| Update page | PUT | `wiki/wikis/{wikiId}/pages?path={path}&api-version=7.1` | `application/json` | `If-Match: {ETag}` | `wiki/update-page.sh` |

## Pull Requests

| Operation | Method | Endpoint | Content-Type | Script |
|-----------|--------|----------|-------------|--------|
| Create PR | POST | `git/repositories/{repoId}/pullrequests?api-version=7.1` | `application/json` | `pull-requests/create.sh` |
| Update PR | PATCH | `git/repositories/{repoId}/pullrequests/{prId}?api-version=7.1` | `application/json` | `pull-requests/update.sh` |
| Add reviewer | PUT | `git/repositories/{repoId}/pullrequests/{prId}/reviewers/{reviewerId}?api-version=7.1` | `application/json` | `pull-requests/add-reviewer.sh` |

## Test Management

| Operation | Method | Endpoint | Content-Type | Script |
|-----------|--------|----------|-------------|--------|
| List test plans | GET | `test/plans?api-version=7.1` | — | `tests/get-plans.sh` |
| List suites | GET | `test/plans/{planId}/suites?api-version=7.1` | — | — |
| List test cases | GET | `test/plans/{planId}/suites/{suiteId}/testcases?api-version=7.1` | — | `tests/get-cases.sh` |
| Create test case | POST | `wit/workitems/$Test%20Case?api-version=7.1` | `application/json-patch+json` | `tests/create-case.sh` |

---

## Authentication

All endpoints require:
```
Authorization: Basic base64(:PAT)
```

Use `source scripts/ado/auth.sh "$PAT"` to set `ADO_AUTH_HEADER`.

---

## PAT Mapping

| Endpoint Category | PAT Required |
|-------------------|-------------|
| Work Items (all operations) | `ADO_PAT_WORKITEMS` |
| Wiki (all operations) | `ADO_PAT_WIKI` |
| Pull Requests | `ADO_PAT_CODE` |
| Test Plans/Suites/Cases (read) | `ADO_PAT_TESTS` |
| Test Case work items (create) | `ADO_PAT_WORKITEMS` |

---

## Content-Type Quick Reference

| Operation Type | Content-Type |
|----------------|-------------|
| Work item create/update/relation | `application/json-patch+json` |
| Work item comment | `application/json` |
| Wiki create/update | `application/json` |
| PR create/update | `application/json` |
| PR add reviewer | `application/json` |

**Rule:** If the body is a JSON Patch array (`[{"op":...}]`), use `json-patch+json`.
If the body is a regular JSON object (`{...}`), use `json`.
