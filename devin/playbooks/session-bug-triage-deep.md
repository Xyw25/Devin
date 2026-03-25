# Session Bug-Triage-Deep — Deep Bug Analysis

## Purpose

Deep-dive triage for bugs specifically. Beyond Session D's basic linking — this session
reads repro steps, downloads attachments, correlates with functionality documentation,
pulls blame history, and produces a first-pass root cause interpretation.

**Schedule:** On-demand (triggered for complex bugs after Session D)
**Target ACU:** <= 5

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

For each attachment:
- Screenshots: note what they show (error dialogs, UI state, console output)
- Log files: download and scan for error patterns
- Other files: note their names and purposes

```bash
bash scripts/ado/work-items/download-attachment.sh "$ATTACHMENT_URL" "/tmp/$FILENAME"
```

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

Using the analysis JSON entry points and the bug's repro steps:
- Identify the likely code path involved
- Check git blame on the most relevant files (last 10 commits)
- Look for recent changes that could have introduced the bug
- Check if the affected area has existing test coverage

**Scope limits:** Same as Session A — one level deep, max 5 models, max 10 entry points.

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

Comment must include:
1. **Functionality match** — which functionality area, confidence level
2. **Likely root cause** — code path, recent changes, contributing factors
3. **Attachment analysis** — what evidence was found in attachments
4. **Test coverage gap** — what tests exist, what's missing, was this a regression
5. **Suggested fix location** — specific files and methods to investigate
6. **New test suggestions** — test cases that would prevent recurrence

### Step 8: Update DevinStorage

Add the work item to the functionality's `workItems` array.
If new insights about the functionality were discovered, update the analysis JSON.
Commit and push DevinStorage.

---

## Specifications

- **ACU Budget:** <= 5
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
| ACU approaching limit | Post what was found so far, exit |

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
