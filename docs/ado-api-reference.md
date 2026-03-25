# ADO API Reference — Canonical Notes for This Org

## Base URL
```
{ADO_ORG_URL}/{ADO_PROJECT}/_apis/
```

## API Version
All calls use `api-version=7.1` unless the endpoint only exists as a preview.
The only preview endpoint used: work item comments (`7.1-preview.4`).

## Endpoints Summary

### Work Items
| Operation | Method | Endpoint |
|---|---|---|
| Get work item | GET | `wit/workitems/{id}?$expand=all` |
| Create work item | POST | `wit/workitems/${type}` |
| Update work item | PATCH | `wit/workitems/{id}` |
| Add comment | POST | `wit/workitems/{id}/comments` |

### Wiki
| Operation | Method | Endpoint |
|---|---|---|
| List wikis | GET | `wiki/wikis` |
| Get page | GET | `wiki/wikis/{wikiId}/pages?path={path}&includeContent=true` |
| Create page | PUT | `wiki/wikis/{wikiId}/pages?path={path}` |
| Update page | PUT | `wiki/wikis/{wikiId}/pages?path={path}` + If-Match ETag |

### Pull Requests
| Operation | Method | Endpoint |
|---|---|---|
| Create PR | POST | `git/repositories/{repoId}/pullrequests` |
| Update PR | PATCH | `git/repositories/{repoId}/pullrequests/{prId}` |
| Add reviewer | PUT | `git/repositories/{repoId}/pullrequests/{prId}/reviewers/{reviewerId}` |

### Test Management
| Operation | Method | Endpoint |
|---|---|---|
| List test plans | GET | `test/plans` |
| List suites | GET | `test/plans/{planId}/suites` |
| List test cases | GET | `test/plans/{planId}/suites/{suiteId}/testcases` |
| Create test case | POST | `wit/workitems/$Test%20Case` |

## Content-Type Rules
- Work item create/update: `application/json-patch+json`
- Wiki operations: `application/json`
- PR operations: `application/json`
- Comments: `application/json`

## Authentication
All calls: `Authorization: Basic base64(:PAT)`
