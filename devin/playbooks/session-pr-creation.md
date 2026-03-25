# Session PR-Creation — Pull Request Lifecycle

## Purpose

Create a well-formed pull request with enriched description, work item links,
reviewers, and functionality context pulled from the Wiki page.

**Schedule:** On-demand (triggered manually or after implementation session)
**Target ACU:** <= 3

---

## Procedure

### Step 1: Read the work item and gather context

```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/get.sh "$WORK_ITEM_ID"
```

Extract: title, description, type, area path, tags, related work items.

### Step 2: Identify the functionality from DevinStorage

Check `analyses/` for a matching JSON file using keywords from the work item.
If found, read the analysis for: `functionality`, `userWorkflow`, `logic`, `wikiPagePath`.

### Step 3: Read the Wiki page for additional context

```bash
source scripts/ado/auth.sh "$ADO_PAT_WIKI"
bash scripts/ado/wiki/get-page.sh "$WIKI_PAGE_PATH"
```

Extract relevant sections to enrich the PR description.

### Step 4: Look up the repository ID

```bash
source scripts/ado/auth.sh "$ADO_PAT_CODE"
bash scripts/ado/repos/get.sh "$REPO_NAME"
```

Capture the repo ID (GUID) for PR creation.

### Step 5: Create the PR

```bash
bash scripts/ado/pull-requests/create.sh \
  "$REPO_ID" \
  "$SOURCE_BRANCH" \
  "$TARGET_BRANCH" \
  "$PR_TITLE" \
  "$PR_DESCRIPTION" \
  "$REVIEWER_IDS" \
  "$WORK_ITEM_ID"
```

PR description should include:
- Summary of changes
- Functionality context from Wiki (brief)
- Work item reference
- Test coverage status (from analysis JSON)

### Step 6: Add additional context as PR comment (if needed)

```bash
bash scripts/ado/pull-requests/add-comment.sh \
  "$REPO_ID" "$PR_ID" \
  "Functionality: ${FUNCTIONALITY_NAME}. Wiki: ${WIKI_URL}. Analysis: analyses/${PRODUCT}/${SLUG}.json"
```

### Step 7: Post comment on work item with PR link

```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"
bash scripts/ado/work-items/comment.sh "$WORK_ITEM_ID" \
  "<p>PR created: <a href=\"${PR_URL}\">${PR_TITLE}</a></p>"
```

### Step 8: Update DevinStorage

Append PR reference to the functionality's `workItems` array in the analysis JSON.
Commit and push DevinStorage.

---

## Specifications

- **ACU Budget:** <= 3
- **PATs:** `ADO_PAT_WORKITEMS`, `ADO_PAT_WIKI`, `ADO_PAT_CODE`
- **Inputs:** Work item ID, source branch, target branch, reviewer AAD IDs
- **Outputs:** PR created with work item link, work item comment, DevinStorage update

### Exit Conditions

| Condition | Action |
|-----------|--------|
| PR created successfully | Post comment on work item, exit |
| Source branch doesn't exist | Post error comment on work item, exit |
| No reviewer IDs provided | Create PR without reviewers, note in comment |
| Repo not found | Post error comment on work item, exit |

---

## Advice

- Always use the full `refs/heads/` prefix for branch names — the script handles this but be explicit
- Reviewer IDs must be AAD Object IDs (GUIDs), not emails or display names
- Keep PR descriptions under 4000 characters — ADO truncates longer descriptions
- If the Wiki page has a tests section, include test coverage status in the PR description
- For draft PRs, add `"isDraft": true` to the PR body (modify create.sh call)

---

## Forbidden Actions

- **Never hardcode reviewer IDs** — pass them as parameters
- **Never skip the work item link** — PRs must always reference their work item
- **Never search online** for PR API details — use `docs/ado-api-reference.md`
- **Never create PRs without checking the source branch exists first**
- **Never include credential values in PR descriptions or comments**

---

## Required from User

- Work item ID to link
- Source and target branch names
- Reviewer AAD Object IDs (optional but recommended)
- Repository name
- All PATs configured in Devin Secrets Manager
