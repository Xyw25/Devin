# Session D — Triage & Linking

## Purpose
Match a work item to a known functionality, link tests, post findings.
If no match, trigger the full A -> B -> C chain.

## Prerequisites
- `ADO_PAT_WORKITEMS`, `ADO_PAT_WIKI`, `ADO_PAT_TESTS` available
- `ADO_WIKI_ID` set
- DevinStorage repo up to date
- Work item ID and scope hint from Session 0

## Step 1: Read work item and scope hint
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
```

## Step 2: Read Functionality Index
```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"
```

## Step 3: Keyword matching
Extract keywords from work item title and description.
Match against `keywords` array in each Functionality Index entry.

**Minimum 2 overlapping keywords required for a confirmed match.**

## IF FUNCTIONALITY FOUND (2+ keyword match):

### Step 4: Read dedicated Wiki page
```bash
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"
```

### Step 5: Read associated test cases
```bash
source scripts/ado/auth.sh "$ADO_PAT_TESTS"
bash scripts/ado/tests/get-cases.sh "$PLAN_ID" "$SUITE_ID"
```

### Step 6: Link test cases to work item
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/link-relation.sh "$WORK_ITEM_ID" \
  "Microsoft.VSTS.Common.TestedBy-Forward" "$TEST_CASE_ID"
```

### Step 7: Analyze test coverage
Determine whether the bug should have been caught by existing tests.
Suggest new test cases if coverage appears insufficient.

### Step 8: Update Wiki and DevinStorage
Append work item to:
- Dedicated Wiki page work items table (with fresh ETag)
- DevinStorage JSON `workItems` array (commit and push)

### Step 9: Post detailed comment
```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p><b>Triage Complete</b><br/>
  Functionality: {name}<br/>
  Tests linked: [list]<br/>
  Coverage opinion: [should this have been caught?]<br/>
  Suggestions: [if any]<br/>
  Wiki: <a href='{url}'>Functionalities/{slug}</a></p>"
```

## IF FUNCTIONALITY NOT FOUND (< 2 keyword match):

### Step 4: Post partial match comment
```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>No confirmed functionality match found. Closest partial matches: [list]. Triggering full analysis chain.</p>"
```

### Step 5: Trigger Session A -> B -> C chain
After chain completes, return to Step 3 for re-matching.

## ACU Budget: <= 3 (found), <= 5 (chain triggered)
