# Session A-React — Vite/React Code Analysis

> Version: 1.0.0
> Last updated: 2026-03-26

## Purpose

Analyze a Vite/React codebase around a functionality and write a structured JSON record
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

### Step 4: Analyze within scope limits (React-specific)

**Hard stops — these are non-negotiable:**
- Trace calls and dependencies **one level deep only**
- Maximum **5 models** — stop if exceeded
- Maximum **10 entry points** — stop if exceeded

Load knowledge items before starting: `react-entry-points.md`, `react-models-state.md`, `react-project-structure.md`

#### 4a: Identify project structure
```bash
# Check it's a React project
cat package.json | grep -E "react|vite"
# Map key directories
ls src/pages/ src/views/ src/components/ src/hooks/ src/api/ src/services/ src/store/ src/types/ 2>/dev/null
```

#### 4b: Find entry points
```bash
# Route definitions
grep -rn "path=\|<Route\|createBrowserRouter" src/
# Page components
grep -rn "export default function\|export default class" src/pages/ src/views/
# API integration points
grep -rn "fetch(\|axios\.\|useQuery\|useMutation" src/api/ src/services/ src/hooks/
```
Record as `file:componentName` or `file:handlerName`. Max 10.

#### 4c: Find models (state/types)
```bash
# TypeScript interfaces and types
grep -rn "^export interface\|^export type " src/types/ src/models/ src/interfaces/
# Redux slices / Zustand stores
grep -rn "createSlice\|create(" src/store/ src/redux/
# API response types
grep -rn "interface.*Response\|interface.*Request\|type.*DTO" src/
```
Include types with 3+ business fields. Max 5.

#### 4d: Trace dependencies (one level)
For each entry point component:
1. Read its import statements
2. Follow imported hooks and API service functions
3. Note which API endpoints they call (the `actions` array)
4. STOP — don't trace into utility functions or shared components

#### 4e: Derive user workflow
Read the route/page component top-down:
1. What URL does the user navigate to?
2. What does the component render (form, list, detail view)?
3. What actions can the user take (buttons, links, form submissions)?
4. What happens after each action (API call, navigation, state update)?

#### 4f: Check for known issues
```bash
grep -rn "TODO\|FIXME\|HACK\|XXX\|eslint-disable" src/
```
Also note: `any` type usage, missing error boundaries, uncaught promise rejections.

If scope limits are hit:
1. Write a **partial** analysis JSON with what was found so far
2. Add fields: `"partial": true` and `"scopeLimitHit": "{reason}"` to the JSON
3. Post comment listing findings and asking which aspect to focus on:
```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Analysis scope limit reached. Found [X] models and [Y] entry points. Please specify which aspect to focus on: [list what was found]</p>"
```
4. Commit and push the partial analysis to DevinStorage
5. Exit — Session B can still create a partial Wiki page from available data

### Step 5: Write analysis JSON
Create or update `analyses/{product}/{functionality-slug}.json` following the
schema defined in `INTENT.md`. Include:
- `"techStack": "react"`
- `keywords` array from entry points, model names, route names, UI elements
- `entryPoints`, `models`, `dependencies`, `calledBy`
- `logic`, `userWorkflow`, `actions`
- `knownIssues` for any fragility observed

Full JSON schema: see `schemas/analysis-json.schema.md`

### Step 6: Update tracking fields
- Append work item to `workItems` array (Before appending, check if the work item ID already exists in the `workItems` array. Skip if duplicate.)
- Append entry to `analysisHistory` with date, commit SHA, work item ID, and note

### Step 7: Commit and push DevinStorage
```bash
cd /path/to/DevinStorage
git add analyses/
git commit -m "Analysis: {functionality-slug} triggered by WI#{id}"
```

Before pushing: `git pull --rebase origin master`. If push still fails, pull --rebase and retry once.

```bash
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
| **Inputs** | Work item ID, scope hint, repository name (provided by external orchestration) |
| **Outputs** | `analyses/{product}/{slug}.json` with `"techStack": "react"`, work item comment, DevinStorage commit |

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
- Only analyze `src/` — never look inside `node_modules/`, `dist/`, or `public/` for code.
- Component prop types are not models — only include types that represent business data with 3+ fields.
- UI-only components (buttons, icons, layout wrappers) are not entry points — entry points are page-level or route-level components.

## Forbidden Actions

- Never trace deeper than one level of calls.
- Never exceed 5 models or 10 entry points — post comment and exit instead.
- Never search online for API or codebase information.
- Never write raw curl calls.
- Never hardcode credentials or org URLs.
- Never modify the target repository — only analyze and read.
- Never analyze `node_modules/` — only `src/`.
- Never count UI-only components (buttons, icons) as entry points.
- Never count component prop types as models.

## Required from User

- Work item ID, scope hint, and repository name.
- `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE` in Secrets Manager.
- DevinStorage repo cloned at known path.
- Target repository cloned and up to date.
