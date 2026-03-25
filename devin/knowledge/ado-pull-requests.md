# ADO Pull Requests — Knowledge Item

## Trigger Description
ADO pull request creation, update, reviewer management, branch ref format

## API Endpoint

```
Base: {ADO_ORG_URL}/{ADO_PROJECT}/_apis/git/repositories/{repoId}/pullrequests
API version: api-version=7.1
```

## Creating a PR

See `scripts/ado/pull-requests/create.sh` for the full create payload. Key fields in the JSON body:
- `sourceRefName` / `targetRefName` — full branch refs (e.g., `refs/heads/main`)
- `title` / `description` — PR metadata (description supports markdown)
- `reviewers` — array of `{ "id": "{AAD-Object-ID-GUID}" }` objects
- `workItemRefs` — array of `{ "id": "{work-item-id}" }` objects

## Updating a PR

See `scripts/ado/pull-requests/update.sh` for the update payload format.

## Merge Strategies

| Strategy | Value |
|---|---|
| Merge (no fast-forward) | `noFastForward` |
| Squash | `squash` |
| Rebase | `rebase` |
| Rebase + merge | `rebaseMerge` |

## Adding a Reviewer

See `scripts/ado/pull-requests/add-reviewer.sh` for usage.

## Required Fields for PR Creation

| Field | Required | Format | Example |
|-------|----------|--------|---------|
| `sourceRefName` | Yes | Full branch ref | `refs/heads/feature/login-fix` |
| `targetRefName` | Yes | Full branch ref | `refs/heads/main` |
| `title` | Yes | String | `"Fix null check in login flow"` |
| `description` | No | Markdown string | `"## Summary\n..."` |
| `reviewers` | No | Array of `{id: GUID}` | `[{"id": "a1b2c3d4-..."}]` |
| `workItemRefs` | No | Array of `{id: string}` | `[{"id": "12345"}]` |

## Rules

- Branch refs **must** include full prefix: `refs/heads/main` not just `main`. Without it, the API returns 400. The `create.sh` script auto-adds the prefix if missing, but always be explicit.
- Reviewer ID **must** be AAD Object ID (GUID) — not display name, not email. Wrong format silently fails.
- Work item links are added via `workItemRefs` array at creation time
- Use scripts instead of raw curl calls
- PR descriptions support markdown and have a 4000-character limit

## Scripts

- `scripts/ado/pull-requests/create.sh` — POST new PR
- `scripts/ado/pull-requests/update.sh` — PATCH PR status
- `scripts/ado/pull-requests/add-reviewer.sh` — PUT reviewer
- `scripts/ado/pull-requests/add-comment.sh` — POST comment thread
- `scripts/ado/pull-requests/link-work-item.sh` — Link work item post-creation
- `scripts/ado/pull-requests/get.sh` — GET PR details or list active PRs

## Scripts

- `scripts/ado/pull-requests/create.sh` — POST new PR
- `scripts/ado/pull-requests/update.sh` — PATCH PR status
- `scripts/ado/pull-requests/add-reviewer.sh` — PUT reviewer
