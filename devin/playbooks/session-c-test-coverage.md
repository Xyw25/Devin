# Session C — Test Coverage

> Version: 2.0.0
> Last updated: 2026-03-25

## Purpose
Find existing test cases, evaluate coverage, create new ones if needed,
link all to the work item, update Wiki and Index.

## Procedure

### Step 1: Read Wiki page and analysis JSON
```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"
```
Read `analyses/{product}/{slug}.json` from DevinStorage.

### Step 2: Check existing test links
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
```
Check `relations` for any `Microsoft.VSTS.Common.TestedBy-Forward` entries.

If tests already linked AND no new analysis was performed -> skip creation,
still update Wiki if needed.

### Step 3: Search codebase for existing tests
Search target repository for test files related to this functionality.
Read and evaluate what they cover and what they miss.

### Step 4: List ADO test plans and cases
```bash
source scripts/ado/auth.sh "$ADO_PAT_TESTS"
bash scripts/ado/tests/get-plans.sh
bash scripts/ado/tests/get-cases.sh "$PLAN_ID" "$SUITE_ID"
```

### Step 5: Create new test cases if gaps exist
```bash
bash scripts/ado/tests/create-case.sh "$TITLE" "$AREA_PATH" "$STEPS_XML"
```
Test cases are work items of type `$Test%20Case`.

> See DevinStorage/AzureDevOps Documentation/operations/test-case-creation.md for XML steps format

### Step 6: Link test cases to work item
For each test case (existing and new):
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/link-relation.sh "$WORK_ITEM_ID" \
  "Microsoft.VSTS.Common.TestedBy-Forward" "$TEST_CASE_ID"
```

### Step 7: Update Wiki dedicated page — Tests section
```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"  # fresh ETag
bash scripts/ado/wiki/update-page.sh "/Functionalities/{slug}" "$CONTENT" "$ETAG"
```

### Step 8: Update Functionality Index — test coverage status
```bash
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"  # fresh ETag
bash scripts/ado/wiki/update-page.sh "/FunctionalityIndex" "$CONTENT" "$ETAG"
```

### Step 9: Update DevinStorage if new tests created
If new test cases were created, update the analysis JSON and commit/push.

### Step 10: Post comment on work item
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Test coverage assessment complete.<br/>
  Tests found: [X]<br/>
  Tests created: [Y]<br/>
  Coverage: [assessment]<br/>
  Should existing tests have caught this? [yes/no and why]</p>"
```

> Comment format: see schemas/work-item-comment.template.md

## Specifications

**Inputs:**
- Work item ID
- Analysis JSON (`analyses/{product}/{slug}.json`)
- Wiki page path (`/Functionalities/{slug}`)

**Outputs:**
- Test cases (ADO work items of type Test Case)
- TestedBy links on the work item
- Wiki updates (Tests section on dedicated page + Functionality Index)
- Work item comment summarizing coverage assessment
- DevinStorage update (if new tests created)

**Exit conditions:**
- Tests already linked + no new analysis = skip creation but still update Wiki
- No test plans found = create test case work items without suite linking
- Gaps found = create new test cases and link them
- No gaps = link existing tests only

## Advice

- "Coverage gap" means: a user workflow step or entry point in the analysis JSON that has no corresponding test case.
- To search for existing tests in the codebase, look for files matching: `*test*`, `*spec*`, `*.test.*`, `*.spec.*` in directories near the entry points.
- When creating test cases, title format: "Verify {what} when {condition}" — e.g., "Verify login succeeds when credentials are valid".
- Test steps XML: use `<steps><step><parameterizedString>` format (see test-case-creation.md). Full format: see schemas/test-case-steps.xml
- If no test plans exist in the project, create the test case work item without suite linkage and note this in the comment.
- Always refresh ETag before any Wiki PUT update — even if you fetched the page earlier.
- Check `docs/error-catalog.md` if any script call fails.

## Forbidden Actions

- Never skip the Wiki update — even if no new tests are created, the Tests section may need updating.
- Never create duplicate test cases — check existing cases first (Step 2 and Step 4).
- Never search online.
- Never write raw curl calls.
- Never hardcode credentials.
- Never PUT Wiki pages without fresh ETag.
- Never omit the work item comment at the end.

## Required from User

- Work item ID
- `ADO_PAT_TESTS`, `ADO_PAT_WIKI`, `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE` in Secrets Manager
- `ADO_WIKI_ID`, `ADO_DEFAULT_AREA` configured
- DevinStorage and target repos accessible
