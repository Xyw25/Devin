# Session B — Functionality Documentation

## Purpose
Create or update the ADO Wiki dedicated page and Functionality Index entry
from the DevinStorage analysis file. Always triggers Session C on completion.

## Prerequisites
- `ADO_PAT_WIKI`, `ADO_PAT_WORKITEMS` available in secrets
- `ADO_WIKI_ID` set
- DevinStorage repo up to date with analysis JSON
- Work item ID from originating session

## Step 1: Read analysis JSON
Read `analyses/{product}/{functionality-slug}.json` from DevinStorage.

## Step 2: Check Functionality Index
```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"
```
Capture ETag from response.

## Step 3: Check for existing dedicated page
```bash
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"
```
If 404 -> page does not exist (create it).
If 200 -> page exists (capture ETag for potential update).

## Step 4: Create or update dedicated page

### If no dedicated page exists — CREATE:
```bash
bash scripts/ado/wiki/create-page.sh "/Functionalities/{slug}" "$CONTENT"
```

Page content must include these sections:
1. **Overview** — what the functionality does
2. **User Workflow** — ordered steps from user perspective
3. **Actions Triggered** — what happens in the system
4. **Models and Logic Involved** — entities and core logic
5. **Associated Work Items** — table: ID, type, title, link
6. **Tests** — placeholder until Session C populates this

### If page exists and analysis was supplemented — UPDATE:
```bash
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"  # fresh ETag
bash scripts/ado/wiki/update-page.sh "/Functionalities/{slug}" "$CONTENT" "$ETAG"
```

### If page exists and commit was current — SKIP content update.
Still trigger Session C.

## Step 5: Update Functionality Index
```bash
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"  # fresh ETag
bash scripts/ado/wiki/update-page.sh "/FunctionalityIndex" "$CONTENT" "$ETAG"
```

Add or update the row with: name (linked), description, product, test status, date.

## Step 6: Append work item to dedicated page
Add originating work item to the Associated Work Items table.

## Step 7: Post comment on work item
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Wiki documentation updated: <a href='{wiki_url}'>Functionalities/{slug}</a></p>"
```

## Step 8: Trigger Session C — ALWAYS
Regardless of whether content was created, updated, or skipped.

## CRITICAL REMINDER
**ETag is mandatory for all Wiki PUT updates.**
Always GET -> capture ETag -> PUT with If-Match.
Missing ETag = 409 Conflict.

## ACU Budget: <= 3
