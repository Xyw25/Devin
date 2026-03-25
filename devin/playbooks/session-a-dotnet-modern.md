# Session A-.NET-Modern — .NET 10 Code Analysis

> Version: 1.0.0
> Last updated: 2026-03-26

## Purpose

Analyze a .NET 10 codebase around a functionality and write a structured JSON record
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

### Step 4: Analyze within scope limits (.NET 10-specific)

**Hard stops — these are non-negotiable:**
- Trace calls and dependencies **one level deep only**
- Maximum **5 models** — stop if exceeded
- Maximum **10 entry points** — stop if exceeded

Load knowledge items before starting: `dotnet-modern-entry-points.md`, `dotnet-modern-models.md`, `dotnet-modern-project-structure.md`

#### 4a: Identify project structure
```bash
# Confirm .NET version
grep "TargetFramework" *.csproj
# Map solution structure
find . -name "*.csproj" -exec grep -l "net10.0\|net9.0" {} \;
# Check DI registrations (the dependency map)
grep -n "builder.Services\.\|services\.\(AddScoped\|AddTransient\|AddSingleton\)" Program.cs Startup.cs 2>/dev/null
```

#### 4b: Find entry points
```bash
# API Controllers
grep -rn "\[ApiController\]\|\[HttpGet\]\|\[HttpPost\]\|\[HttpPut\]\|\[HttpDelete\]" **/*.cs
# Minimal APIs
grep -rn "app\.Map\(Get\|Post\|Put\|Delete\)" Program.cs
# Razor Pages
grep -rn "OnGet\|OnPost\|OnPut\|OnDelete" **/*.cshtml.cs
# SignalR
grep -rn ": Hub\b\|: Hub<" **/*.cs
# Background services
grep -rn "BackgroundService\|IHostedService" **/*.cs
```
Record as `file:ControllerName.ActionMethod`. Max 10.

#### 4c: Find models
```bash
# EF Core entities via DbContext
grep -rn "DbSet<\|: DbContext" **/*.cs
# DTOs and records
grep -rn "record \|class.*Dto\|class.*Request\|class.*Response" Models/ Dtos/ Contracts/ 2>/dev/null
# Migrations (schema history)
ls Migrations/*.cs 2>/dev/null | head -5
```
DbSet properties = definitive model list. Max 5.

#### 4d: Trace dependencies (one level)
Read the DI container registrations in `Program.cs`:
1. For each controller, find its constructor parameters (injected services)
2. For each injected service, note what it does (data access, external API, business logic)
3. STOP — don't trace what the injected services inject internally

#### 4e: Derive user workflow
Read the controller action methods in order:
1. What HTTP verb and route? (the trigger)
2. What does the action do? (call service, query DB, return result)
3. What response does the user see? (200 OK, 201 Created, 400 Bad Request)

#### 4f: Check for known issues
```bash
grep -rn "TODO\|FIXME\|HACK\|XXX" **/*.cs
```
Also note: missing model validation (`[Required]`), empty catch blocks, `Task.Result` (sync-over-async).

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
- `"techStack": "dotnet-modern"`
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
| **Outputs** | `analyses/{product}/{slug}.json` with `"techStack": "dotnet-modern"`, work item comment, DevinStorage commit |

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
- DI registrations in `Program.cs` are your dependency map — read them first to understand the architecture.
- DbSet properties are the authoritative model list — prefer them over standalone DTO classes.
- Test projects often mirror production structure; always verify you are not analyzing test code.

## Forbidden Actions

- Never trace deeper than one level of calls.
- Never exceed 5 models or 10 entry points — post comment and exit instead.
- Never search online for API or codebase information.
- Never write raw curl calls.
- Never hardcode credentials or org URLs.
- Never modify the target repository — only analyze and read.
- Never analyze test projects (`*.Tests.csproj`) as production code.
- Never count migration files as models.
- Never count DI configuration classes as entry points.

## Required from User

- Work item ID, scope hint, and repository name.
- `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE` in Secrets Manager.
- DevinStorage repo cloned at known path.
- Target repository cloned and up to date.
