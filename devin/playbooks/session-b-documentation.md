# Session B — Functionality Documentation

> Version: 2.0.0
> Last updated: 2026-03-25

## Purpose

Create or update the ADO Wiki dedicated page and Functionality Index entry
from the DevinStorage analysis file. Always triggers Session C on completion.

## Procedure

### Step 1: Read analysis JSON
Read `analyses/{product}/{functionality-slug}.json` from DevinStorage.

### Step 2: Check Functionality Index
```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"
```
Capture ETag from response.

### Step 3: Check for existing dedicated page
```bash
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"
```
If 404 -> page does not exist (create it).
If 200 -> page exists (capture ETag for potential update).

### Step 4: Create or update dedicated page

#### If no dedicated page exists — CREATE:
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

Page format: see `schemas/wiki-functionality-page.template.md`

#### If page exists and analysis was supplemented — UPDATE:
```bash
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"  # fresh ETag
bash scripts/ado/wiki/update-page.sh "/Functionalities/{slug}" "$CONTENT" "$ETAG"
```

#### If page exists and commit was current — SKIP content update.
Still trigger Session C.

### Step 5: Update Functionality Index
```bash
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"  # fresh ETag
bash scripts/ado/wiki/update-page.sh "/FunctionalityIndex" "$CONTENT" "$ETAG"
```

Add or update the row with: name (linked), description, product, test status, date.

Index row format: see `schemas/wiki-functionality-index-row.template.md`

### Step 6: Append work item to dedicated page
Add originating work item to the Associated Work Items table.

### Step 7: Post comment on work item
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Wiki documentation updated: <a href='{wiki_url}'>Functionalities/{slug}</a></p>"
```
Comment format: see `schemas/work-item-comment.template.md`

### Step 8: Trigger Session C — ALWAYS
Regardless of whether content was created, updated, or skipped.

## Specifications

| Field | Value |
|---|---|
| **Inputs** | Analysis JSON from DevinStorage, work item ID |
| **Outputs** | Wiki page at `/Functionalities/{slug}`, Index row, work item comment |

**Critical:** ETag is mandatory for all Wiki PUT updates — GET before PUT, always.

### Exit Conditions

| Condition | Action |
|---|---|
| Page returns 404 | Create path: create new dedicated page and index row |
| Page returns 200 + analysis changed | Update path: update page content and index row |
| Page returns 200 + analysis current | Skip path: skip content update, still trigger Session C |

## Advice

- Always GET the page immediately before PUT — even if you got it earlier in the session. ETags can expire.
- If creating a new page, the Tests section should say "Pending — Session C will populate" not be empty.
- The Overview section must be written from the user's perspective, not the developer's.
- If Wiki returns 409 Conflict, re-GET the page and retry — someone else may have updated it.
- Check `docs/error-catalog.md` if any script call fails.

## Forbidden Actions

- Never PUT a Wiki page without first GET-ing it for a fresh ETag.
- Never skip the Functionality Index update.
- Never search online.
- Never write raw curl calls.
- Never modify DevinStorage in this session — Session A owns DevinStorage writes.
- Never omit the work item comment at the end.

## Required from User

- Work item ID.
- `ADO_PAT_WIKI`, `ADO_PAT_WORKITEMS` in Secrets Manager.
- `ADO_WIKI_ID` configured.
- DevinStorage repo accessible with analysis JSON present.
