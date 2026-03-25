# Session C — Test Coverage

## Purpose
Find existing test cases, evaluate coverage, create new ones if needed,
link all to the work item, update Wiki and Index.

## Prerequisites
- `ADO_PAT_TESTS`, `ADO_PAT_WIKI`, `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE` available
- `ADO_WIKI_ID`, `ADO_DEFAULT_AREA` set
- DevinStorage repo and target repository up to date
- Work item ID from originating session

## Step 1: Read Wiki page and analysis JSON
```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"
```
Read `analyses/{product}/{slug}.json` from DevinStorage.

## Step 2: Check existing test links
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
```
Check `relations` for any `Microsoft.VSTS.Common.TestedBy-Forward` entries.

If tests already linked AND no new analysis was performed -> skip creation,
still update Wiki if needed.

## Step 3: Search codebase for existing tests
Search target repository for test files related to this functionality.
Read and evaluate what they cover and what they miss.

## Step 4: List ADO test plans and cases
```bash
source scripts/ado/auth.sh "$ADO_PAT_TESTS"
bash scripts/ado/tests/get-plans.sh
bash scripts/ado/tests/get-cases.sh "$PLAN_ID" "$SUITE_ID"
```

## Step 5: Create new test cases if gaps exist
```bash
bash scripts/ado/tests/create-case.sh "$TITLE" "$AREA_PATH" "$STEPS_XML"
```
Test cases are work items of type `$Test%20Case`.

## Step 6: Link test cases to work item
For each test case (existing and new):
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/link-relation.sh "$WORK_ITEM_ID" \
  "Microsoft.VSTS.Common.TestedBy-Forward" "$TEST_CASE_ID"
```

## Step 7: Update Wiki dedicated page — Tests section
```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"  # fresh ETag
bash scripts/ado/wiki/update-page.sh "/Functionalities/{slug}" "$CONTENT" "$ETAG"
```

## Step 8: Update Functionality Index — test coverage status
```bash
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"  # fresh ETag
bash scripts/ado/wiki/update-page.sh "/FunctionalityIndex" "$CONTENT" "$ETAG"
```

## Step 9: Update DevinStorage if new tests created
If new test cases were created, update the analysis JSON and commit/push.

## Step 10: Post comment on work item
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Test coverage assessment complete.<br/>
  Tests found: [X]<br/>
  Tests created: [Y]<br/>
  Coverage: [assessment]<br/>
  Should existing tests have caught this? [yes/no and why]</p>"
```

## ACU Budget: <= 5
