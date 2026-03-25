# ADO Wiki — Knowledge Item

## API Endpoint

```
Base: {ADO_ORG_URL}/{ADO_PROJECT}/_apis/wiki/wikis/{ADO_WIKI_ID}
API version: api-version=7.1
```

## ETag Requirement — CRITICAL

Every Wiki page GET returns an `ETag` in the response header.
Every Wiki page PUT update **requires** that ETag in the `If-Match` header.

**Missing ETag on update = 409 Conflict error.**

Workflow:
1. GET the page — capture the `ETag` header from the response
2. PUT the update — include `If-Match: {ETag}` in the request header

Never skip the GET step. Never cache ETags across operations — always
fetch a fresh one immediately before each update.

## Page Operations

### List Wikis
```
GET /{org}/{project}/_apis/wiki/wikis?api-version=7.1
```

### Get Page (with content and ETag)
```
GET /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
    ?path={pagePath}&includeContent=true&api-version=7.1
```
Capture `ETag` from response headers.

### Create Page
```
PUT /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
    ?path={pagePath}&api-version=7.1
Content-Type: application/json
{
  "content": "# Page Title\n\nMarkdown content here"
}
```
No `If-Match` header needed for first creation.

### Update Page
```
PUT /{org}/{project}/_apis/wiki/wikis/{wikiId}/pages
    ?path={pagePath}&api-version=7.1
If-Match: {ETag}
Content-Type: application/json
{
  "content": "# Updated content\n\nNew markdown content"
}
```
**`If-Match` header is mandatory for updates.**

## Wiki Structure for This System

```
/FunctionalityIndex               <- Master index page
/Functionalities/{slug}           <- One page per functionality
```

## Scripts

Always use scripts in `scripts/ado/wiki/` instead of writing raw curl calls:
- `get-page.sh` — GET page + capture ETag
- `create-page.sh` — PUT new page
- `update-page.sh` — PUT update with ETag
