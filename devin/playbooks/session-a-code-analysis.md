# Session A — Code Analysis

## Purpose
Analyze the codebase around a functionality and write a structured JSON record
to DevinStorage. Scoped and bounded — never open-ended.

## Prerequisites
- `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE` available in secrets
- DevinStorage repo cloned and up to date
- Target repository cloned and up to date
- Work item ID and scope hint from Session 0/D

## Trigger Conditions
- Session D cannot match functionality with 2+ keyword overlap, OR
- DevinStorage file exists but `lastAnalyzedCommit` differs from current HEAD

## Step 1: Read the work item
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
```

## Step 2: Check DevinStorage for existing analysis
Look in `analyses/{product}/` for a matching JSON file.

## Step 3: Compare commit SHA
If file exists, compare `lastAnalyzedCommit` against current HEAD of relevant files.
- **If current** -> skip analysis, hand off to Session B directly
- **If outdated** -> supplement changed areas only
- **If missing** -> full analysis

## Step 4: Analyze within scope limits
**Hard stops — these are non-negotiable:**
- Trace calls and dependencies **one level deep only**
- Maximum **5 models** — stop if exceeded
- Maximum **10 entry points** — stop if exceeded

If either limit is hit:
```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Analysis scope limit reached. Found [X] models and [Y] entry points. Please specify which aspect to focus on: [list what was found]</p>"
```
Then exit cleanly.

## Step 5: Write analysis JSON
Create or update `analyses/{product}/{functionality-slug}.json` following the
schema defined in `INTENT.md`. Include:
- `keywords` array from entry points, model names, route names, UI elements
- `entryPoints`, `models`, `dependencies`, `calledBy`
- `logic`, `userWorkflow`, `actions`
- `knownIssues` for any fragility observed

## Step 6: Update tracking fields
- Append work item to `workItems` array
- Append entry to `analysisHistory` with date, commit SHA, work item ID, and note

## Step 7: Commit and push DevinStorage
```bash
cd /path/to/DevinStorage
git add analyses/
git commit -m "Analysis: {functionality-slug} triggered by WI#{id}"
git push
```

## Step 8: Post comment on work item
```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Code analysis complete for {functionality}. Analysis file: analyses/{product}/{slug}.json</p>"
```

## Step 9: Trigger Session B

## ACU Budget: <= 5 (full), <= 3 (supplement only)
