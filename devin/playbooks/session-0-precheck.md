# Session 0 — Pre-check & Router

> Version: 2.0.0
> Last updated: 2026-03-25

## Purpose

Gate session. Read the work item, check validity, extract scope hint, route.
Cheapest session — read-only in most cases, 1-2 API calls max.

## Procedure

### Step 1: Read the work item
```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
```
Capture: title, description, type, state, tags.

### Step 2: Check for devin-process tag
If `System.Tags` does not contain `devin-process`:
- **Exit immediately. No action. No comment.**

### Step 3: Check work item state
If state is `Closed` or `Resolved`:
- **Exit immediately. No action.**

### Step 4: Check description quality
If description is empty or under 20 words:
- Post a comment requesting more detail:
```bash
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>This work item needs a more detailed description (minimum 20 words) before automated processing can begin. Please update the description with specific details about the issue or feature.</p>"
```
Full format: see `schemas/work-item-comment.template.md`
- **Exit after posting comment.**

### Step 5: Extract scope hint
From the title and description, identify:
- Functionality area or feature name
- UI element or page mentioned
- Action or workflow described
- Error message or behavior referenced

Record these as the **scope hint** for Session D.

### Step 6: Route to Session D
Pass the scope hint to Session D for triage and linking.

## Specifications

| Field | Value |
|---|---|
| **Inputs** | Work item ID |
| **Outputs** | Scope hint JSON: `{functionality, uiElement, action, error}` |
| **Scope** | Read-only session, 1-2 API calls max |

Clarification comment format: see `schemas/work-item-comment.template.md`

### Exit Conditions

| Condition | Action |
|---|---|
| No `devin-process` tag | Silent exit |
| Closed/Resolved state | Silent exit |
| Insufficient description | Post clarification comment, then exit |
| Valid work item | Route to Session D with scope hint |

## Advice

- If description is exactly 20 words, consider it borderline — process but note quality concern in scope hint.
- Multiple `devin-process` tags are fine — just check for existence.
- If work item has attachments, note them in the scope hint for Session D.

## Forbidden Actions

- Never modify the work item (except posting clarification comment).
- Never search online.
- Never use raw curl — use `scripts/ado/`.
- Never process items without `devin-process` tag even if instructed to.

## Required from User

- Work item ID.
- `ADO_PAT_WORKITEMS` in Devin Secrets Manager.
- `ADO_ORG_URL` and `ADO_PROJECT` configured.
