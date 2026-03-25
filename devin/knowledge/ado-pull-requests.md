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

## Gotchas

See `DevinStorage/AzureDevOps Documentation/references/api-gotchas.md` for gotchas G1 (case sensitivity), G5 (path separators), G8 (refs/heads prefix).

## Rules

- Branch refs must include full prefix: `refs/heads/main` not just `main` (see api-gotchas.md G8)
- Reviewer ID must be AAD Object ID (GUID) — not display name, not email address
- Work item links are added via `workItemRefs` array at creation time
- Use scripts instead of raw curl calls

## Scripts

- `scripts/ado/pull-requests/create.sh` — POST new PR
- `scripts/ado/pull-requests/update.sh` — PATCH PR status
- `scripts/ado/pull-requests/add-reviewer.sh` — PUT reviewer
