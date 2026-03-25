# Wiki Functionality Page Template

> Wiki path: `/Functionalities/{slug}`
> Produced by: Session B (Documentation)
> Updated by: Session C (Test Coverage), Session D (Triage)

---

## Template

```markdown
# {Functionality Name}

## Overview

{2-3 sentence description of what this functionality does, from the user's perspective.}

**Product:** {product}
**Last Updated:** {ISO date}
**Analysis:** [DevinStorage](analyses/{product}/{slug}.json)

---

## User Workflow

1. {Step 1 from user perspective}
2. {Step 2}
3. {Step 3}
...

---

## Actions Triggered

- {Action 1 — e.g., POST /api/auth/login}
- {Action 2 — e.g., emit LoginEvent}
...

---

## Models and Logic

**Models:** {Model1}, {Model2}, {Model3}

**Core Logic:** {Concise description of the logic flow — 2-3 sentences}

**Entry Points:**
- `{file:method}` — {brief description}
- `{file:method}` — {brief description}

---

## Associated Work Items

| ID | Type | Title | Link |
|----|------|-------|------|
| {id} | {Bug/User Story/Task} | {title} | [#{id}]({url}) |

---

## Tests

| Test Case ID | Title | Coverage |
|-------------|-------|----------|
| {id} | {test case title} | {what it covers} |

**Coverage Status:** {Adequate / Gaps identified / No tests yet}
**Last Evaluated:** {ISO date}
```

## Rules

- **Overview** must be written from the user's perspective, not the developer's
- **User Workflow** steps must be ordered and numbered
- **Associated Work Items** table is append-only — never remove entries
- **Tests** section is updated by Session C, not Session B
- Always update **Last Updated** date when modifying the page
