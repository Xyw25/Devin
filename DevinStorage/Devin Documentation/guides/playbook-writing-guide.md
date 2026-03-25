# Writing Effective Playbooks

> Version: 1.0.0
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
