# Session 0 — Pre-check & Router

## Purpose
Gate session. Read the work item, check validity, extract scope hint, route.
Cheapest session — target <= 1 ACU. Read-only in most cases.

## Prerequisites
- `ADO_PAT_WORKITEMS` available in secrets
- `ADO_ORG_URL` and `ADO_PROJECT` set
- Work item ID provided as input

## Steps

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

## Exit Conditions
- No `devin-process` tag -> silent exit
- Closed/Resolved state -> silent exit
- Insufficient description -> comment + exit
- Valid work item -> route to Session D

## ACU Budget: <= 1
