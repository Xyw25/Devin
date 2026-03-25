# Writing Effective Playbooks

> Version: 2.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> Sources accessed: 2026-03-25
> Source: [Devin Docs — Creating Playbooks](https://docs.devin.ai/product-guides/creating-playbooks)

---

## What Playbooks Are

Step-by-step procedures for Devin to execute. They define the **"how"**.
Knowledge items define the "what" — playbooks define the sequence of actions.

Playbooks are prompt templates that ensure Devin follows a consistent,
tested procedure every time a specific type of work is triggered.

---

## Five Required Sections

### 1. Procedure

The ordered steps Devin must follow. This is the core of the playbook.

**Rules for writing procedures:**
- One action per line — mutually exclusive steps
- Collectively exhaustive — no gaps between steps
- Include specific commands, file paths, and script references
- Cover setup, execution, and delivery phases
- Use code blocks for actual commands:

```markdown
### Step 3: Post comment on work item
\`\`\`bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>Analysis complete. File: analyses/{product}/{slug}.json</p>"
\`\`\`
```

### 2. Specifications

Hard limits and output requirements that define the session's boundaries.

- ACU budget (e.g., `<= 3 ACU`)
- Scope limits (e.g., `max 5 models, 10 entry points`)
- Output format (e.g., JSON schema, Wiki section structure)
- API versions and Content-Types
- Exit conditions (when to stop)

### 3. Advice

Tips for common edge cases and preferred approaches.

- When to supplement vs full re-analysis
- How to handle ambiguous keyword matches
- Which fields are most error-prone
- Nested bullets under specific steps for step-specific advice

### 4. Forbidden Actions

What Devin must absolutely never do during this session.

- Never search online for API details
- Never write raw curl calls (use `scripts/ado/`)
- Never skip ETag fetch before Wiki update
- Never exceed scope limits without asking for clarification
- Never hardcode credentials

### 5. Required from User

External inputs the playbook needs to begin.

- Work item ID
- Scope hint (from Session 0)
- Secrets configured in Devin Secrets Manager
- Repos accessible and cloned

---

## Deliverables Requirement

Every playbook must produce at least one tangible artifact:

| Artifact Type | Example |
|---|---|
| File in DevinStorage | `analyses/{product}/{slug}.json` |
| Wiki page | `/Functionalities/{slug}` created or updated |
| Work item comment | Summary posted on originating work item |
| Test case | ADO Test Case work item created |
| Git commit | DevinStorage changes committed and pushed |

**If a playbook produces no artifact, it's not a playbook — it's a discussion prompt.**

---

## Naming Convention (This Repo)

```
session-{identifier}-{descriptive-name}.md
```

Examples:
- `session-0-precheck.md`
- `session-a-code-analysis.md`
- `session-b-documentation.md`
- `session-c-test-coverage.md`
- `session-d-triage.md`

---

## .devin.md Files

Playbooks can be uploaded as `.devin.md` files at the repo root for
automatic loading during session start. Use drag-and-drop in Devin UI.

- Blue pill indicator confirms successful attachment
- Use macros (e.g., `!data-tutorial`) for quick attachment in prompts
- Useful for playbooks that should always be active for a repo

---

## How Devin Consumes Playbooks

1. Created in Devin web app via "Create a new Playbook"
2. Uploaded as `.devin.md` files (drag-and-drop)
3. Accessed via macros in session prompts
4. Attached to scheduled sessions for recurring automation

---

## Iteration Strategy with Version Tracking

Playbooks are living documents. They improve through trial runs and structural changes. Use semantic versioning to communicate the nature of each change.

### Version Scheme

| Version | Meaning | When to Bump | Example Change |
|---------|---------|-------------- |----------------|
| **v1.0** | Initial release | First time the playbook is committed | New playbook written and committed |
| **v1.1** | Patch after first trial | After the first 1-3 test sessions reveal minor issues | Reworded a step that Devin misinterpreted, added a missing advice bullet |
| **v1.2** | Second round of fixes | After further trials reveal additional edge cases | Added error handling for 404 response, clarified scope limit wording |
| **v2.0** | Structural change | When steps are added, removed, reordered, or the playbook's scope changes | Added a new step between steps 3 and 4, changed output format from markdown to JSON |
| **v2.1** | Patch on new structure | Minor fixes after the structural change is tested | Fixed file path in new step, adjusted ACU budget |

### Tracking Changes in a Changelog

Add a changelog section at the bottom of each playbook (or in a separate `CHANGELOG.md` if the team prefers). Format:

```markdown
## Changelog

| Version | Date | Change |
|---------|------|--------|
| v1.0 | 2026-03-15 | Initial playbook |
| v1.1 | 2026-03-17 | Fixed step 4: added ETag fetch before Wiki update |
| v1.2 | 2026-03-20 | Added advice for 404 when dedicated page does not exist |
| v2.0 | 2026-03-25 | Restructured: split step 3 into 3a (check index) and 3b (check dedicated page) |
```

### Iteration Workflow

1. **Write v1.0** — Draft the playbook following the Five Required Sections.
2. **Run 2-3 parallel test sessions** — Use different work items to exercise different code paths.
3. **Collect failures** — Note which steps fail, produce wrong output, or consume excess ACUs.
4. **Bump to v1.1** — Fix the issues found. Do not restructure yet.
5. **Run 2-3 more trials** — Confirm fixes and identify any remaining issues.
6. **Stabilize at v1.x** — Once trials pass consistently, the playbook is stable.
7. **Bump to v2.0 only when** — A new requirement changes the playbook's scope, steps need reordering, or a fundamentally different approach is needed.

### Using Session Insights

After each trial session, review Devin's Session Insights to identify:
- Which steps consumed the most ACUs (optimize or simplify those steps)
- Where Devin deviated from the procedure (clarify wording or add forbidden actions)
- Which advice bullets were never triggered (consider removing or generalizing them)

---

## Real Examples from This Repo

This repository contains 6 playbooks. Each demonstrates specific strengths worth noting.

### 1. `session-0-precheck.md` — Gate Session

**Structure:** Purpose, Prerequisites, Steps (1-5), Specifications, Forbidden Actions
**What makes it effective:**
- Cheapest session in the pipeline (target <= 1 ACU) — gate sessions should be fast and read-only
- Clear exit conditions at multiple steps (no tag -> exit, closed state -> exit, empty description -> exit)
- Extracts a "scope hint" that downstream sessions depend on — the playbook explicitly names this output
- Steps are strictly read-only; no writes to any system unless routing to another session

### 2. `session-a-code-analysis.md` — Code Analysis

**Structure:** Purpose, Prerequisites, Trigger Conditions, Steps (1-7), Specifications, Advice, Forbidden Actions
**What makes it effective:**
- Includes **Trigger Conditions** that define when this session should even run (no match in triage, or outdated analysis)
- Step 3 has a three-way branch (current/outdated/missing) with different actions for each — clear decision tree
- Scope limits are concrete: max 5 models, 10 entry points, one level deep
- Output is a structured JSON file with a defined schema — not free-form text

### 3. `session-b-documentation.md` — Wiki Documentation

**Structure:** Purpose, Prerequisites, Steps (1-7), Specifications, Forbidden Actions
**What makes it effective:**
- Captures ETag before every Wiki write (step 2 and step 3) — prevents concurrent edit conflicts
- Handles both create (404) and update (200) paths for dedicated pages
- Always triggers Session C on completion — the playbook explicitly defines the handoff
- Wiki content structure is specified (which sections, what goes in each)

### 4. `session-c-test-coverage.md` — Test Coverage

**Structure:** Purpose, Prerequisites, Steps (1-7), Specifications, Advice, Forbidden Actions
**What makes it effective:**
- Requires all 4 PATs — the prerequisites section makes this explicit so the session does not fail mid-run
- Checks for existing test links before creating duplicates (step 2)
- Searches the codebase for existing tests before writing new ones (step 3) — avoids redundancy
- Links test cases to work items with proper relation types

### 5. `session-d-triage.md` — Triage and Linking

**Structure:** Purpose, Prerequisites, Steps (1-6), Specifications, Advice, Forbidden Actions
**What makes it effective:**
- Keyword matching has a concrete threshold: minimum 2 overlapping keywords for a confirmed match
- Routes to the full A->B->C chain when no match is found — clear escalation path
- Reads the Functionality Index once and matches against it — no redundant API calls
- Advice section covers ambiguous matches (1 keyword overlap) with specific guidance

### 6. `session-doc-monitor.md` — Daily Documentation Monitor

**Structure:** Purpose, Procedure (Steps 1-8), Specifications, Advice, Forbidden Actions, Required from User
**What makes it effective:**
- Scheduled playbook (`0 9 * * *`) — demonstrates recurring automation pattern
- Maintains a state file (`doc-monitor-state.json`) for tracking across runs — most runs detect no changes and exit cheaply
- Includes a `pendingNewTopics` mechanism for flagging items that need manual review
- Version-bumps local files when changes are detected — traceability built in

---

## Common Playbook Pitfalls

Five specific mistakes seen in real playbook development, with concrete corrections.

### Pitfall 1: Missing Error Catalog Reference

**The mistake:** The playbook's Forbidden Actions section says "Never search online for API troubleshooting" but does not tell Devin **where** to look instead. Devin hits an error, cannot search online, and stalls.

**Bad:**
```markdown
## Forbidden Actions
- Never search online for ADO API details
```

**Fixed:**
```markdown
## Forbidden Actions
- Never search online for ADO API details
- If an API call returns an unexpected error, check `docs/error-catalog.md` first
- If the error is not in the catalog, post a comment on the work item describing the error and exit
```

**Why it matters:** Forbidden actions create dead ends if there is no alternative path. Always pair a "never do X" with a "do Y instead".

### Pitfall 2: No Git Push After DevinStorage Changes

**The mistake:** The playbook writes a JSON analysis file to DevinStorage but does not include a step to commit and push. The next session (on a different machine or Devin instance) does not see the changes.

**Bad:**
```markdown
## Step 6: Save analysis
Write the JSON to `analyses/{product}/{slug}.json`.
```

**Fixed:**
```markdown
## Step 6: Save analysis
Write the JSON to `analyses/{product}/{slug}.json`.

## Step 7: Commit and push DevinStorage
\`\`\`bash
cd DevinStorage
git add analyses/{product}/{slug}.json
git commit -m "Analysis: {slug} — session A"
git push origin master
\`\`\`
```

**Why it matters:** DevinStorage is a shared repository. Local writes without push are invisible to other sessions. Every playbook that writes to DevinStorage must include an explicit commit-and-push step.

### Pitfall 3: ETag Not Captured Before Wiki Update

**The mistake:** The playbook updates a Wiki page without first fetching the current ETag. The ADO Wiki API requires an `If-Match` header with the current ETag for updates. Without it, the update returns 412 Precondition Failed.

**Bad:**
```markdown
## Step 4: Update Wiki page
\`\`\`bash
bash scripts/ado/wiki/update-page.sh "/Functionalities/{slug}" "$CONTENT"
\`\`\`
```

**Fixed:**
```markdown
## Step 3: Fetch current page and ETag
\`\`\`bash
bash scripts/ado/wiki/get-page.sh "/Functionalities/{slug}"
\`\`\`
Capture the `ETag` header from the response. Store as `$PAGE_ETAG`.
If 404: page does not exist — use create-page.sh instead of update-page.sh.

## Step 4: Update Wiki page
\`\`\`bash
bash scripts/ado/wiki/update-page.sh "/Functionalities/{slug}" "$CONTENT" "$PAGE_ETAG"
\`\`\`
```

**Why it matters:** The ADO Wiki API uses optimistic concurrency control via ETags. Skipping the ETag fetch guarantees a 412 error. This is the single most common API error in Wiki-writing sessions.

### Pitfall 4: Scope Limits Not Enforced

**The mistake:** The playbook says "analyze the codebase" without defining boundaries. Devin recursively explores the entire repository, consuming 10+ ACUs and producing an unfocused analysis.

**Bad:**
```markdown
## Step 3: Analyze the code
Analyze all relevant code files related to the functionality.
```

**Fixed:**
```markdown
## Step 3: Analyze the code
Analyze the code within these hard limits:
- **Max 5 models/classes** (pick the most relevant based on scope hint keywords)
- **Max 10 entry points** (public methods or API endpoints)
- **One level deep only** (direct dependencies, not transitive)
- **If the scope hint references more than 5 models**, pick the top 5 by keyword relevance and note the others as "out of scope — requires follow-up session"

## Specifications
- ACU budget: <= 3 ACU
- If approaching 2.5 ACU: stop analysis, save what you have, and note incomplete scope
```

**Why it matters:** Without concrete scope limits, Devin optimizes for completeness and will explore everything reachable. ACU budgets alone are not enough — Devin needs item-count limits to know when to stop.

### Pitfall 5: No Work Item Comment at End

**The mistake:** The playbook completes all technical work but does not post a summary comment on the originating work item. The human reviewing the work item has no visibility into what happened.

**Bad:**
```markdown
## Step 7: Done
Session complete.
```

**Fixed:**
```markdown
## Step 7: Post completion comment
\`\`\`bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p><b>Session B complete.</b></p>
   <p>Wiki page created: /Functionalities/{slug}</p>
   <p>Analysis file: analyses/{product}/{slug}.json</p>
   <p>Next: Session C (test coverage)</p>"
\`\`\`
```

**Why it matters:** Work item comments are the primary audit trail for humans. Without a completion comment, there is no record in ADO that the session ran, what it produced, or what should happen next. Every playbook should end with a work item comment summarizing deliverables and next steps.

---

## Iteration Strategy

- Run the playbook in 2-3 parallel test sessions to identify failures
- Refine steps that fail or produce inconsistent results
- Version playbooks in changelog when significant changes are made
- Use Session Insights to identify which steps consume the most ACUs

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | Fix |
|---|---|---|
| Confusing with Knowledge | Procedures don't belong in knowledge items | Knowledge = facts, Playbooks = procedures |
| Over-specifying | Removes Devin's problem-solving ability | Specify outcomes, not micro-steps |
| Steps that overlap | Causes confusion about execution order | Make steps mutually exclusive |
| Missing deliverables | Session runs but produces nothing tangible | Every playbook must output an artifact |
| No ACU budget | Session runs indefinitely | Always include ACU target |
| No exit conditions | No way to know when to stop | Define clear success and failure exits |
| No forbidden actions | Devin improvises risky approaches | List what must never happen |
| Procedures too granular | 50-step playbooks confuse more than help | Aim for 6-12 main steps |

---

## Checklist for New Playbooks

- [ ] All 5 sections present (Procedure, Specifications, Advice, Forbidden, Required)
- [ ] Steps are mutually exclusive and collectively exhaustive
- [ ] Specific commands and script references included
- [ ] ACU budget stated
- [ ] Exit conditions defined (success and failure)
- [ ] At least one deliverable artifact specified
- [ ] Forbidden actions listed
- [ ] Required inputs listed
- [ ] File naming follows convention
- [ ] Tested in at least one trial session
