# Writing Effective Knowledge Items

> Version: 1.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> Sources accessed: 2026-03-25
> Source: [Devin Docs — Knowledge](https://docs.devin.ai/product-guides/knowledge)

---

## What Knowledge Items Are

Short reference documents that Devin loads based on trigger matching.
They provide **facts and context**, not procedures. Playbooks handle procedures.

Knowledge items are retrieved automatically when Devin's current task matches
the item's trigger description. Bad triggers = bad retrieval = wasted context window.

---

## Structure Convention (This Repo)

```markdown
# {Topic} — Knowledge Item

## {Section 1}
Content...

## {Section 2}
Content...

## Rules
- Bullet list of hard rules

## Scripts
- References to relevant scripts in scripts/ado/
```

- Title as H1 with `— Knowledge Item` suffix
- Sections with H2 headers
- Tables for structured data (fields, scopes, mappings)
- Code blocks for commands and API calls
- `Rules` or `Scripts` section at the bottom

---

## Length

- A handful of sentences per section
- Total: fits on one screen without scrolling (40-100 lines)
- If longer than ~100 lines, split into multiple knowledge items

---

## Trigger Descriptions

The trigger description determines when Devin retrieves the knowledge item.
It must be highly specific to avoid false activations and missed activations.

| Quality | Trigger Description | Problem |
|---------|-------------------|---------|
| Bad | "Azure DevOps information" | Too broad — matches everything ADO-related |
| Bad | "API stuff" | Vague — matches unrelated APIs |
| Good | "ADO Wiki page creation and update with ETag requirement" | Specific domain + specific operation |
| Good | "ADO work item field names, patch format, and relations" | Specific domain + specific content |

---

## Content Rules

### Do

- **Facts and context only** — field names, API versions, Content-Types, format requirements
- **Include specific values** — `System.Title` not "the title field"
- **Reference scripts** — `scripts/ado/wiki/get-page.sh` instead of duplicating curl commands
- **Note gotchas** — case sensitivity, separators, encoding requirements
- **Use tables** for structured reference data (field mappings, scope tables)
- **Keep focused** — one ADO domain per knowledge item

### Don't

- **No step-by-step procedures** — those belong in playbooks
- **No duplicated content** — reference other knowledge items or docs files
- **No overly broad coverage** — "how our entire API works" is too wide
- **No stale information** — update when APIs or conventions change
- **No inline secrets** — reference secrets-reference.md for naming only

---

## Organization Pattern (This Repo)

| Category | Files | Pattern |
|----------|-------|---------|
| ADO domains | `ado-auth.md`, `ado-work-items.md`, `ado-wiki.md`, `ado-pull-requests.md`, `ado-tests.md` | One per ADO service area |
| Cross-cutting | `ado-error-handling.md`, `environment.md` | One per shared concern |
| Devin meta | `session-management.md`, `security-best-practices.md`, etc. | One per platform topic |

---

## Macros

Assign macros (like `!deploy-checklist`) for quick reference in prompts.
This lets you attach specific knowledge items to a session explicitly
rather than relying on trigger matching alone.

---

## Anti-Patterns

| Anti-Pattern | Why It Fails | Fix |
|---|---|---|
| Overly broad content | Matches too many queries, dilutes relevance | Split into focused items |
| Weak trigger descriptions | Item not retrieved when actually needed | Use specific domain + operation language |
| Procedure-heavy content | Competes with playbooks, confuses role | Move procedures to playbooks |
| Stale content | Devin follows outdated instructions | Update when APIs or conventions change |
| Duplicated content | Maintenance burden, drift between copies | Reference other files instead |
| No script references | Devin improvises raw API calls | Always point to scripts/ado/ |

---

## Checklist for New Knowledge Items

- [ ] Title follows `{Topic} — Knowledge Item` convention
- [ ] Trigger description is specific (domain + operation)
- [ ] Content is facts/context, not procedures
- [ ] Tables used for structured data
- [ ] Code blocks for commands and API calls
- [ ] Scripts section references relevant scripts
- [ ] Length under ~100 lines
- [ ] No duplicated content from other items
- [ ] No inline secrets or credentials
