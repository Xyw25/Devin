# ADO Wiki — Knowledge Item

## Trigger Description
ADO Wiki page creation and update with ETag concurrency requirement

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

- **List Wikis:** `GET /_apis/wiki/wikis?api-version=7.1`
- **Get Page:** Use `scripts/ado/wiki/get-page.sh` — retrieves page content and captures the ETag header.
- **Create Page:** Use `scripts/ado/wiki/create-page.sh` — PUTs a new page. No `If-Match` header needed for first creation.
- **Update Page:** Use `scripts/ado/wiki/update-page.sh` — PUTs updated content with the required `If-Match: {ETag}` header. The ETag **must** come from a fresh GET immediately before the update.

## Wiki Structure for This System

```
/FunctionalityIndex               <- Master index page
/Functionalities/{slug}           <- One page per functionality
```

## Rules

- Always GET before PUT to obtain a fresh ETag
- Never cache or reuse ETags across operations
- Page content is Markdown format
- Use the scripts — they handle ETag capture automatically

## Scripts

Always use scripts in `scripts/ado/wiki/` instead of writing raw curl calls:
- `get-page.sh` — GET page + capture ETag
- `create-page.sh` — PUT new page
- `update-page.sh` — PUT update with ETag
