# Session A-.NET-Legacy — .NET 4.8 Code Analysis

> Version: 1.0.0
> Last updated: 2026-03-26

## Purpose

Analyze a .NET 4.8 (legacy) codebase around a functionality and write a structured JSON record
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

### Step 4: Analyze within scope limits (.NET 4.8-specific)

**Hard stops — these are non-negotiable:**
- Trace calls and dependencies **one level deep only**
- Maximum **5 models** — stop if exceeded
- Maximum **10 entry points** — stop if exceeded

Load knowledge items before starting: `dotnet-legacy-entry-points.md`, `dotnet-legacy-models.md`, `dotnet-legacy-project-structure.md`

#### 4a: Identify project structure
```bash
# Confirm .NET 4.8 (or 4.7.x, 4.6.x)
grep "TargetFrameworkVersion" *.csproj
# Check web.config for architecture clues
grep -n "connectionStrings\|authentication\|httpModules\|system.serviceModel" web.config
# Check for .edmx files (EF6 visual designer)
find . -name "*.edmx" -o -name "*.dbml" -o -name "*.xsd"
```

#### 4b: Find entry points
```bash
# ASPX code-behind page handlers
find . -name "*.aspx.cs" -exec grep -l "Page_Load\|btn.*_Click\|gv.*_RowCommand" {} \;
# ASMX web services
grep -rn "\[WebMethod\]" **/*.cs
# WCF services
grep -rn "\[OperationContract\]\|\[ServiceContract\]" **/*.cs
# MVC controllers (if MVC pattern used)
grep -rn ": Controller" **/*.cs
# HTTP handlers
find . -name "*.ashx.cs" -o -name "*.ashx"
```
Record as `file:PageName.EventHandler` or `file:ServiceName.MethodName`. Max 10.

#### 4c: Find models
```bash
# EF6 entities (from .edmx or code-first)
grep -rn ": DbContext\|DbSet<" **/*.cs
find . -name "*.edmx" # Visual designer — maps entire DB schema
# ADO.NET data access
grep -rn "SqlConnection\|SqlCommand\|DataAdapter\|DataTable" **/*.cs
# Stored procedures
grep -rn "StoredProcedure\|CommandType\.StoredProcedure" **/*.cs
# Typed DataSets
find . -name "*.xsd"
```
If `.edmx` exists, extract entity names from it — that's the authoritative model list. Max 5.

#### 4d: Trace dependencies (one level)
.NET 4.8 has NO DI by default. Trace manually:
1. For each entry point, search for `new ClassName()` instantiations
2. For static method calls `ClassName.MethodName()`
3. Note which data access classes are used (DAL layer)
4. STOP — don't trace into the DAL methods

#### 4e: Derive user workflow
For ASPX pages: follow the page lifecycle:
1. Page_Load — what does the page show?
2. Button_Click — what action does the user take?
3. What does the server do? (call service, update DB)
4. Where does the user end up? (redirect, postback, error message)

For WCF/ASMX: follow the request/response pattern.

#### 4f: Check for known issues
```bash
grep -rn "TODO\|FIXME\|HACK\|XXX" **/*.cs **/*.aspx.cs
```
Also note: inline SQL (SQL injection risk), ViewState abuse, Session state for large objects, missing error handling in Page_Error.

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
- `"techStack": "dotnet-legacy"`
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
| **Outputs** | `analyses/{product}/{slug}.json` with `"techStack": "dotnet-legacy"`, work item comment, DevinStorage commit |

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
- `.edmx` files are the authoritative source for entity models in legacy projects — prefer them over code-first classes.
- .NET 4.8 projects often use `web.config` for critical configuration (connection strings, WCF bindings) — read it early.
- Legacy projects may mix ASPX, ASMX, WCF, and MVC in the same solution — identify which pattern each area uses before analyzing.
- `designer.cs` files are auto-generated and should never be treated as hand-written code.

## Forbidden Actions

- Never trace deeper than one level of calls.
- Never exceed 5 models or 10 entry points — post comment and exit instead.
- Never search online for API or codebase information.
- Never write raw curl calls.
- Never hardcode credentials or org URLs.
- Never modify the target repository — only analyze and read.
- Never analyze `bin/` or `obj/` directories.
- Never count auto-generated `.designer.cs` files as entry points.
- Never count `web.config` sections as models.
- Never modify legacy code — analyze and report only.

## Required from User

- Work item ID, scope hint, and repository name.
- `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE` in Secrets Manager.
- DevinStorage repo cloned at known path.
- Target repository cloned and up to date.
