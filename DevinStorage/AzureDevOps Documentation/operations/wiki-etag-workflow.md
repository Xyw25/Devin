# Wiki ETag Workflow — Step-by-Step

> Created: 2026-03-25
> API Version: 7.1

---

## Why ETags Matter

The ADO Wiki API uses **optimistic concurrency control** via ETags.
Every page has a version identifier (ETag) that changes with each update.
To update a page, you must prove you read the latest version by sending
its ETag back in the `If-Match` header.

**Without ETag: 409 Conflict error. Every time. No exceptions.**

---

## The Workflow

### Step 1: GET the page

```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"

# get-page.sh outputs body to stdout, ETag to stderr
RESPONSE=$(bash scripts/ado/wiki/get-page.sh "/Functionalities/user-login" 2>etag.txt)
ETAG=$(cat etag.txt)
```

Or manually:
```bash
curl -s -D headers.txt \
  -H "${ADO_AUTH_HEADER}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wiki/wikis/${ADO_WIKI_ID}/pages?path=%2FFunctionalities%2Fuser-login&includeContent=true&api-version=7.1"

ETAG=$(grep -i "^etag:" headers.txt | sed 's/^[eE][tT][aA][gG]: *//' | tr -d '\r\n')
```

### Step 2: Modify the content

Parse the response, update the markdown content as needed.

### Step 3: PUT the update with ETag

```bash
bash scripts/ado/wiki/update-page.sh "/Functionalities/user-login" "$NEW_CONTENT" "$ETAG"
```

Or manually:
```bash
curl -s -X PUT \
  -H "${ADO_AUTH_HEADER}" \
  -H "Content-Type: application/json" \
  -H "If-Match: ${ETAG}" \
  -d "{\"content\": \"${NEW_CONTENT}\"}" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wiki/wikis/${ADO_WIKI_ID}/pages?path=%2FFunctionalities%2Fuser-login&api-version=7.1"
```

---

## Create vs Update

| Operation | ETag Required? | Script |
|-----------|---------------|--------|
| Create (new page) | No | `create-page.sh` |
| Update (existing page) | **Yes** | `update-page.sh` |

To determine which to use:
1. GET the page
2. If 404: page doesn't exist -> use `create-page.sh`
3. If 200: page exists -> capture ETag, use `update-page.sh`

---

## Handling 409 Conflict

If you get 409 despite providing an ETag:

1. Someone else modified the page between your GET and PUT
2. Re-GET the page for a fresh ETag
3. Merge your changes with the new content if needed
4. Retry the PUT with the new ETag

```
GET (ETag: "v1")
     |
     v
Someone else updates page (ETag becomes "v2")
     |
     v
PUT with If-Match: "v1" --> 409 Conflict
     |
     v
Re-GET (ETag: "v2")
     |
     v
PUT with If-Match: "v2" --> 200 OK
```

---

## Common Mistakes

| Mistake | Result | Fix |
|---------|--------|-----|
| Skipping GET before PUT | 409 Conflict | Always GET first |
| Caching ETag from earlier | 409 Conflict (stale) | Always fetch fresh ETag |
| Using ETag from different page | 409/412 error | Each page has its own ETag |
| Omitting `If-Match` header | 409 Conflict | Include `If-Match: {ETag}` |
| Using ETag for creation | Unnecessary but harmless | Omit for new pages |

---

## Script Enforcement

The `update-page.sh` script **requires** the ETag parameter:
```bash
ETAG="${3:?Usage: update-page.sh <page-path> <markdown-content> <etag> — ETag is REQUIRED for updates}"
```

This prevents accidental updates without ETag at the script level.
