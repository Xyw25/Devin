# Session A — Code Analysis

> Version: 2.0.0
> Last updated: 2026-03-25

## Purpose

Analyze the codebase around a functionality and write a structured JSON record
to DevinStorage. Scoped and bounded — never open-ended.

## Procedure

### Step 1: Read the work item
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
```

### Step 2: Check DevinStorage for existing analysis
Look in `analyses/{product}/` for a matching JSON file.

### Step 3: Compare commit SHA
If file exists, compare `lastAnalyzedCommit` against current HEAD of relevant files.
- **If current** -> skip analysis, hand off to Session B directly
- **If outdated** -> supplement changed areas only
- **If missing** -> full analysis

### Step 4: Analyze within scope limits
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

### Step 5: Write analysis JSON
Create or update `analyses/{product}/{functionality-slug}.json` following the
schema defined in `INTENT.md`. Include:
- `keywords` array from entry points, model names, route names, UI elements
- `entryPoints`, `models`, `dependencies`, `calledBy`
- `logic`, `userWorkflow`, `actions`
- `knownIssues` for any fragility observed

Full JSON schema: see `schemas/analysis-json.schema.md`

### Step 6: Update tracking fields
- Append work item to `workItems` array
- Append entry to `analysisHistory` with date, commit SHA, work item ID, and note

### Step 7: Commit and push DevinStorage
```bash
cd /path/to/DevinStorage
git add analyses/
git commit -m "Analysis: {functionality-slug} triggered by WI#{id}"
git push
```

### Step 8: Post comment on work item
```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Code analysis complete for {functionality}. Analysis file: analyses/{product}/{slug}.json</p>"
```
Comment format: see `schemas/work-item-comment.template.md`

### Step 9: Trigger Session B

## Specifications

| Field | Value |
|---|---|
| **Inputs** | Work item ID, scope hint from Session 0/D |
| **Outputs** | `analyses/{product}/{slug}.json`, work item comment, DevinStorage commit |

### Scope Limits

- Maximum **5 models** per analysis
- Maximum **10 entry points** per analysis
- Trace depth: **one level** of calls only

### Trigger Conditions

- Session D cannot match functionality with 2+ keyword overlap, OR
- DevinStorage file exists but `lastAnalyzedCommit` differs from current HEAD

### Exit Conditions

| Condition | Action |
|---|---|
| Analysis is current (commit SHA matches) | Skip analysis, hand off to Session B |
| Analysis is outdated | Supplement changed areas only |
| No existing analysis | Full analysis |
| Scope limits hit (5 models or 10 entry points) | Post comment and exit |

## Advice

- When supplementing, focus on files changed since last commit SHA — don't re-analyze unchanged files.
- Keywords should include: function names, route paths, UI labels, error messages — not generic terms like "button" or "page".
- If the functionality spans multiple products, pick the primary one for the directory path.
- Check `docs/error-catalog.md` if any script call fails.

## Forbidden Actions

- Never trace deeper than one level of calls.
- Never exceed 5 models or 10 entry points — post comment and exit instead.
- Never search online for API or codebase information.
- Never write raw curl calls.
- Never hardcode credentials or org URLs.
- Never modify the target repository — only analyze and read.

## Required from User

- Work item ID and scope hint.
- `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE` in Secrets Manager.
- DevinStorage repo cloned at known path.
- Target repository cloned and up to date.
