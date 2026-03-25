# Session D — Triage & Linking

> Version: 2.0.0
> Last updated: 2026-03-25

## Purpose
Match a work item to a known functionality, link tests, post findings.
If no match, trigger the full A -> B -> C chain.

## Procedure

### Step 1: Read work item and scope hint
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
```

### Step 2: Read Functionality Index
```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"
```

### Step 3: Keyword matching
Extract keywords from work item title and description.
Match against `keywords` array in each Functionality Index entry.

**Minimum 2 overlapping keywords required for a confirmed match.**

### IF FUNCTIONALITY FOUND (2+ keyword match):

#### Step 4: Read dedicated Wiki page
```bash
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"
```

#### Step 5: Read associated test cases
```bash
source scripts/ado/auth.sh "$ADO_PAT_TESTS"
bash scripts/ado/tests/get-cases.sh "$PLAN_ID" "$SUITE_ID"
```

#### Step 6: Link test cases to work item
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/link-relation.sh "$WORK_ITEM_ID" \
  "Microsoft.VSTS.Common.TestedBy-Forward" "$TEST_CASE_ID"
```

#### Step 7: Analyze test coverage
Determine whether the bug should have been caught by existing tests.
Suggest new test cases if coverage appears insufficient.

#### Step 8: Update Wiki and DevinStorage
Append work item to:
- Dedicated Wiki page work items table (with fresh ETag)
- DevinStorage JSON `workItems` array (commit and push)

#### Step 9: Post detailed comment
```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p><b>Triage Complete</b><br/>
  Functionality: {name}<br/>
  Tests linked: [list]<br/>
  Coverage opinion: [should this have been caught?]<br/>
  Suggestions: [if any]<br/>
  Wiki: <a href='{url}'>Functionalities/{slug}</a></p>"
```

> Comment format: see schemas/work-item-comment.template.md

### IF FUNCTIONALITY NOT FOUND (< 2 keyword match):

#### Step 4: Post partial match comment
```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>No confirmed functionality match found. Closest partial matches: [list]. Triggering full analysis chain.</p>"
```

> Comment format: see schemas/work-item-comment.template.md

#### Step 5: Trigger Session A -> B -> C chain
After chain completes, return to Step 3 for re-matching.

## Specifications

**Inputs:**
- Work item ID
- Scope hint from Session 0

**Outputs (found path):**
- TestedBy links on the work item
- Wiki page update (dedicated page work items table)
- DevinStorage update (`workItems` array in analysis JSON)
- Work item comment with triage details

**Outputs (not found path):**
- Work item comment noting partial matches
- Trigger A->B->C chain, then re-match

**Match criteria:**
- Minimum 2 overlapping keywords between work item and `keywords` array in analysis JSON.
- The Functionality Index Wiki page contains names and links — but the `keywords` arrays are in DevinStorage JSON files. Read both.

## Advice

- Keyword extraction: pull nouns, proper names, route paths, and technical terms from work item title + description. Ignore common words (the, is, was, bug, fix, issue, etc.).
- If multiple functionalities match with 2+ keywords, pick the one with the highest overlap count. If tied, list all matches in the comment and ask the user which is correct.
- "Analyze test coverage" means: read the Tests section of the Wiki page, count linked test cases, and state whether the bug's specific scenario is covered by any existing test.
- When triggering the A->B->C chain, pass the work item ID and the extracted keywords as inputs. After the chain completes, re-run Step 3 matching with the newly created analysis.
- Check `docs/error-catalog.md` if any script call fails.

## Forbidden Actions

- Never confirm a match with fewer than 2 keyword overlaps.
- Never skip posting a comment — even when triggering the chain.
- Never search online.
- Never write raw curl calls.
- Never hardcode credentials.
- Never PUT Wiki pages without fresh ETag.
- Never modify DevinStorage without committing and pushing.

## Required from User

- Work item ID and scope hint from Session 0
- `ADO_PAT_WORKITEMS`, `ADO_PAT_WIKI`, `ADO_PAT_TESTS` in Secrets Manager
- `ADO_WIKI_ID` configured
- DevinStorage repo accessible
