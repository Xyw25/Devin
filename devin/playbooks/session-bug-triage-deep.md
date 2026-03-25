# Session Bug-Triage-Deep — Deep Bug Analysis

> Version: 2.1.0
> Last updated: 2026-03-26

## Purpose

Deep-dive triage for bugs specifically. Beyond Session D's basic linking — this session
reads repro steps, downloads attachments, correlates with functionality documentation,
pulls blame history, and produces a first-pass root cause interpretation.

**Schedule:** On-demand (triggered for complex bugs after Session D)

---

## Procedure

### Step 1: Read the full bug work item

```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
```

Extract: title, description, repro steps (`Microsoft.VSTS.TCM.ReproSteps`), severity,
priority, area path, tags, relations.

### Step 2: Read all comments for additional context

```bash
bash scripts/ado/work-items/get-comments.sh "$WORK_ITEM_ID"
```

Look for: developer notes, test results, user-reported details, prior investigation notes.

### Step 3: Check and download attachments

```bash
bash scripts/ado/work-items/get-attachments.sh "$WORK_ITEM_ID"
```

Download all attachments to `/tmp/attachments/`. Organize: images → `/tmp/attachments/images/`, logs → `/tmp/attachments/logs/`, other → `/tmp/attachments/other/`.

```bash
mkdir -p /tmp/attachments/images /tmp/attachments/logs /tmp/attachments/other
bash scripts/ado/work-items/download-attachment.sh "$ATTACHMENT_URL" "/tmp/attachments/{category}/$FILENAME"
```

For images, note the filename — if it contains descriptive keywords (e.g., 'error-dialog', 'login-screen'), record them. Otherwise, note filename and indicate human review needed.

For logs, search for patterns: stack traces, `Exception`, `Error`, `FATAL`, `null`, `undefined`.

### Step 4: Match to known functionality

Read Functionality Index from Wiki. Extract keywords from the bug, match with
2+ keyword overlap threshold. If matched, read the dedicated Wiki page and
analysis JSON from DevinStorage.

```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "/FunctionalityIndex"
bash scripts/ado/wiki/get-page.sh "/Functionalities/${SLUG}"
```

### Step 5: Analyze codebase around the bug area

```bash
source scripts/ado/auth.sh "$ADO_PAT_CODE"
```

Algorithm:
1. Read `entryPoints` from the analysis JSON
2. For each repro step, search for matching function names or route paths in the entry points
3. Read the matching source file(s)
4. Trace calls one level deep from those functions
5. Run `git log --oneline -10 -- {file}` on the most relevant files to find recent changes
6. Check if any recent commits (last 10) touch the suspected code path

Scope limits: one level deep, max 5 models, max 10 entry points.

### Step 6: Check existing test coverage

```bash
source scripts/ado/auth.sh "$ADO_PAT_TESTS"
```

Read test cases linked to the functionality. Determine:
- Would existing tests have caught this bug?
- What test case is missing?
- Is the bug a regression (previously tested area)?

### Step 7: Post detailed findings comment

```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" "$FINDINGS_HTML"
```

The findings comment MUST include all 6 sections:
1. **Functionality Match** — which area, confidence level, keyword overlap count
2. **Likely Root Cause** — suspect files with paths, recent commits that may have caused it
3. **Attachment Analysis** — what each attachment showed, or "No attachments found"
4. **Test Coverage Gap** — existing tests count, whether they should have caught this, regression yes/no
5. **Suggested Fix Location** — specific `file:method` paths
6. **Suggested New Tests** — test case titles that would prevent recurrence

Full HTML format: see `schemas/bug-findings-comment.template.md`

### Step 8: Update DevinStorage

Add the work item to the functionality's `workItems` array.
If new insights about the functionality were discovered, update the analysis JSON.

Before pushing: `git pull --rebase origin master`. If push still fails, pull --rebase and retry once.

Commit and push DevinStorage.

---

## Specifications

- **PATs:** `ADO_PAT_WORKITEMS`, `ADO_PAT_WIKI`, `ADO_PAT_CODE`, `ADO_PAT_TESTS`
- **Inputs:** Work item ID (must be a Bug type)
- **Outputs:** Detailed findings comment, DevinStorage update
- **Scope limits:** One level deep, max 5 models, max 10 entry points

### Exit Conditions

| Condition | Action |
|-----------|--------|
| Analysis complete | Post findings comment, update DevinStorage, exit |
| Work item is not a Bug | Post comment noting wrong type, exit |
| No functionality match | Post comment with partial matches, suggest Session A |
| Scope limits hit | Post partial findings, note what wasn't analyzed |
| Repro steps missing or fewer than 2 sentences | Post comment noting insufficient repro steps and exit without root cause hypothesis |

---

## Advice

- Prioritize attachments early — screenshots and logs often contain the most useful evidence
- Check git blame before diving deep into code — recent changes are the most likely cause
- If repro steps are missing or vague, say so in the findings — don't guess
- Compare the bug against the user workflow in the analysis JSON to identify where the flow breaks
- If multiple functionalities could match, list all of them with confidence levels

---

## Forbidden Actions

- **Never modify code** — this session only analyzes and reports
- **Never close or resolve the work item** — only add findings
- **Never search online** for debugging help — use existing docs and code only
- **Never exceed scope limits** — post partial findings instead
- **Never include file contents in comments** — reference file paths only
- **Never download attachments from untrusted sources without noting it**

---

## Required from User

- Work item ID (Bug type)
- All 4 PATs configured in Devin Secrets Manager
- Target repository accessible and cloned
- DevinStorage repository accessible
