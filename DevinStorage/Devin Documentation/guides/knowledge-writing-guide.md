# Writing Effective Knowledge Items

> Version: 2.0.0
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

## Trigger Specificity Scoring

Use this scoring rubric to evaluate trigger descriptions before saving a knowledge item.

| Score | Characteristics | Example |
|-------|----------------|---------|
| 1 — Very Poor | Matches everything; no domain or operation specified | "helpful information" |
| 2 — Poor | Broad domain only; no operation or context | "Azure DevOps information" |
| 3 — Acceptable | Domain + operation, but still ambiguous | "ADO work item queries" |
| 4 — Good | Domain + operation + narrowing context | "ADO work item field names, patch format, and relations" |
| 5 — Excellent | Domain + operation + specific entity or scenario | "ADO Wiki page creation and update with ETag concurrency requirement" |

**Target score 4 or 5 for all knowledge items.** Items scoring 1-2 should be rewritten
before saving. Items scoring 3 are acceptable only if the domain is inherently narrow.

---

## Real Examples from This Repo

These five knowledge items from `devin/knowledge/` demonstrate effective trigger writing:

| File | Suggested Trigger | Score | Why It Works |
|------|------------------|-------|-------------|
| `ado-auth.md` | "ADO REST API authentication via PAT, Base64 encoding, and per-scope token selection" | 5 | Specifies the exact auth mechanism (PAT), the encoding detail (Base64), and the scoping model — uniquely identifies this item |
| `ado-work-items.md` | "ADO work item field names, patch format, and relations" | 4 | Names the domain (work items) and three distinct content areas — narrows retrieval to work item mutation tasks |
| `ado-wiki.md` | "ADO Wiki page creation and update with ETag concurrency requirement" | 5 | Calls out the ETag gotcha explicitly — Devin loads this precisely when it needs to create or update a Wiki page |
| `ado-pull-requests.md` | "ADO pull request creation, reviewers, comments, and work item linking" | 4 | Lists the four PR operations covered — avoids false matches on general ADO queries |
| `ado-error-handling.md` | "ADO API error diagnosis using error-catalog.md and HTTP status interpretation" | 5 | Points to the specific artifact (error-catalog.md) and the diagnostic approach — triggers only on error-handling tasks |

---

## Knowledge Item Lifecycle

Knowledge items are living documents. They evolve through a predictable cycle:

1. **Create** — Write the initial item based on a real need encountered in a session. Follow the structure convention and aim for score 4+ on the trigger.

2. **Test in session** — Use the item in a real Devin session. Check Session Insights to verify it was retrieved when expected and not retrieved when irrelevant.

3. **Refine trigger** — If the item was missed (not retrieved) or over-matched (retrieved for unrelated tasks), adjust the trigger description. Increase specificity by adding operation names or entity references.

4. **Update content** — As APIs change, scripts are added, or conventions evolve, update the item body. Keep facts current — stale knowledge is worse than no knowledge.

5. **Version bump** — After significant content or trigger changes, increment the version in the item metadata. This helps track when items were last validated.

Repeat steps 2-5 continuously. Items that are never triggered in real sessions should be reviewed — they may have a trigger problem or may no longer be relevant.

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
- [ ] Trigger scores 4 or 5 on the Specificity Scoring rubric
- [ ] Content is facts/context, not procedures
- [ ] Tables used for structured data
- [ ] Code blocks for commands and API calls
- [ ] Scripts section references relevant scripts
- [ ] Length under ~100 lines
- [ ] No duplicated content from other items
- [ ] No inline secrets or credentials
