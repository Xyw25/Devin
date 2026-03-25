# Azure DevOps Wiki Pages API Guide

> Created: 2026-03-25
> API Version: 7.1
> Source: [Azure DevOps REST API — Wiki](https://learn.microsoft.com/en-us/rest/api/azure-devops/wiki)

---

## Base Endpoint

```
{ADO_ORG_URL}/{ADO_PROJECT}/_apis/wiki/wikis/{ADO_WIKI_ID}
```

---

## CRITICAL: ETag Requirement

Every Wiki page GET returns an **ETag** in the response header.
Every Wiki page PUT update **requires** that ETag in the `If-Match` header.

```
Missing ETag on update = 409 Conflict error.
```

**Mandatory workflow:**
1. GET the page -> capture `ETag` from response headers
2. PUT the update -> include `If-Match: {ETag}` in request headers

Never cache ETags across operations. Always fetch a fresh one immediately
before each update. See [wiki-etag-workflow.md](../operations/wiki-etag-workflow.md)
for the step-by-step procedure.

---

## Operations

### List Wikis

```
GET /{org}/{project}/_apis/wiki/wikis?api-version=7.1
```

Returns all wikis in the project. Use to discover the wiki ID.

### Get Page (with content and ETag)

```
GET /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
    ?path={pagePath}&includeContent=true&api-version=7.1
```

- `includeContent=true` returns the markdown body
- Capture `ETag` from response headers for subsequent updates
- Returns 404 if page does not exist

**Script:** `scripts/ado/wiki/get-page.sh <page-path>`
Outputs: response body to stdout, ETag to stderr.

### Create Page

```
PUT /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
    ?path={pagePath}&api-version=7.1
Content-Type: application/json
```

**Body:**
```json
{
  "content": "# Page Title\n\nMarkdown content here"
}
```

No `If-Match` header needed for first creation.

**Script:** `scripts/ado/wiki/create-page.sh <page-path> <markdown-content>`

### Update Page

```
PUT /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
    ?path={pagePath}&api-version=7.1
If-Match: {ETag}
Content-Type: application/json
```

**Body:**
```json
{
  "content": "# Updated Title\n\nNew markdown content"
}
```

**`If-Match` header is MANDATORY for updates.**

**Script:** `scripts/ado/wiki/update-page.sh <page-path> <markdown-content> <etag>`

---

## Wiki Structure (This System)

```
/FunctionalityIndex               <- Master index, one entry per functionality
/Functionalities/{slug}           <- Dedicated page per functionality
```

### FunctionalityIndex Entry Format

Each row contains:
- Functionality name (linked to dedicated page)
- Short description
- Product / area
- Test coverage status
- Last updated date

### Dedicated Page Sections

1. **Overview** — what the functionality does
2. **User Workflow** — ordered steps from user perspective
3. **Actions Triggered** — system actions
4. **Models and Logic Involved** — entities and core logic
5. **Associated Work Items** — table: ID, type, title, link
6. **Tests** — test case IDs, titles, coverage status

---

## Page Path Encoding

Wiki paths are URL-encoded in the query parameter:
- `/FunctionalityIndex` -> `%2FFunctionalityIndex`
- `/Functionalities/user-login` -> `%2FFunctionalities%2Fuser-login`

The scripts handle encoding automatically.

---

## PAT Required

`ADO_PAT_WIKI` — Wiki: Read & Write
