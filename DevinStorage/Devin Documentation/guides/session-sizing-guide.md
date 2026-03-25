# Session Sizing & ACU Optimization Guide

> Version: 2.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> Sources accessed: 2026-03-25
> Sources:
> - [Devin Docs — Session Insights](https://docs.devin.ai/product-guides/session-insights)
> - [Cognition Blog — Jan 2025 Product Update](https://cognition.ai/blog/jan-25-product-update)
> - [Devin Docs — When to Use Devin](https://docs.devin.ai/essential-guidelines/when-to-use-devin)

---

## ACU Overview

ACU (Agent Compute Unit) is a normalized measure of resources used by Devin.
It includes virtual machine time, model inference, and networking bandwidth.
Lower ACU = more efficient session for a given task.

---

## Session Size Classification

| Size | ACU Range | Message Count | Health | Example |
|------|-----------|---------------|--------|---------|
| XS | < 1 | 0-1 | Healthy | Session 0: tag check + route |
| S | 1-2 | 1-3 | Healthy | Post a comment, update one field |
| M | 2-4 | 2-5 | Healthy | Session B: create/update Wiki page |
| L | 4-7 | 5-10 | Unhealthy | Session A: full code analysis |
| XL | 7-10 | 10+ | Unhealthy | Full chain when functionality is new |

**L and XL sessions are flagged as unhealthy.** If your sessions regularly
land in L/XL territory, redesign them into smaller chained sessions.

---

## Decision Tree

Use this tree to pick the right session size before writing your prompt:

```
Start
 |
 +--> Is the task a single API call or lookup?
 |     YES --> XS session (< 1 ACU)
 |     NO  --+
 |            |
 |            +--> Is it multi-step but within one domain?
 |                  (e.g., read file + update file in same repo)
 |                  YES --> S-M session (1-4 ACU)
 |                  NO  --+
 |                         |
 |                         +--> Does it cross domains?
 |                               (e.g., wiki + work items + tests)
 |                               YES --> M-L session (2-7 ACU)
 |                               NO  --+
 |                                      |
 |                                      +--> Does it require full analysis from scratch?
 |                                            YES --> L session (4-7 ACU)
 |                                                    Consider splitting into chained sessions
 |                                            NO  --> Re-evaluate scope; likely S-M
```

**Rule of thumb:** If the decision tree leads you to L, look for a way to
split the task so each piece lands in S-M territory.

---

## ACU Budget Targets (This Repo)

| Session | Target ACU | Size |
|---------|-----------|------|
| 0 — Pre-check & Router | <= 1 | XS |
| A — Code Analysis | <= 5 (full), <= 3 (supplement) | M-L |
| B — Documentation | <= 3 | M |
| C — Test Coverage | <= 5 | M-L |
| D — Triage & Linking | <= 3 (found), <= 5 (chain) | M-L |

---

## Real ACU Budget Examples

Concrete examples showing how each session type maps to ACU consumption:

| Session | Scenario | Steps | ACU |
|---------|----------|-------|-----|
| 0 — Pre-check | Read work item, check tag, return route | 2 API calls | ~0.5 |
| A — Supplement | Diff 3 changed files, update analysis JSON | Read diff + write JSON | ~2.5 |
| A — Full | Analyze new functionality from scratch (5 models, 10 entry points) | Clone, scan, produce JSON | ~5.0 |
| B — New page | Create Wiki page from analysis JSON + update index | Read JSON, create page, update index | ~2.8 |
| B — Update page | Refresh existing Wiki page with new analysis data | Read JSON, diff, patch page | ~1.5 |
| C — Test cases | Generate test cases from analysis JSON + link to work items | Read JSON, write tests, post links | ~4.5 |
| C — Supplement | Add tests for newly analyzed entry points only | Read delta, write tests | ~2.0 |
| D — Match found | Search existing analyses, find match, link + comment | Query, match, comment | ~2.0 |
| D — No match | Search, no match, trigger full chain (A+B+C) | Query, miss, kick off chain | ~0.5 (own cost) |

---

## Cumulative ACU Calculator

When the full chain runs (Session 0 -> D -> A -> B -> C), total ACU depends
on whether the functionality is new or already has analysis data.

### Worst Case: All New (no prior analysis exists)

```
Session 0 (Pre-check)    =  0.5 ACU
Session D (Triage)        =  0.5 ACU  (no match, triggers chain)
Session A (Full analysis) =  5.0 ACU
Session B (New Wiki page) =  3.0 ACU
Session C (Test coverage) =  5.0 ACU
                            ─────────
Total worst case          = 14.0 ACU
Rounded budget ceiling    = 16.0 ACU  (with margin)
```

### Best Case: All Current (analysis exists, minor supplement)

```
Session 0 (Pre-check)    =  0.5 ACU
Session D (Triage)        =  2.0 ACU  (match found, link + comment)
Session A (skipped)       =  0.0 ACU
Session B (skipped)       =  0.0 ACU
Session C (supplement)    =  2.0 ACU  (only if new tests needed)
                            ─────────
Total best case           =  4.5 ACU
Rounded budget floor      =  4.0 ACU
```

### Typical Case: Partial Update

```
Session 0 (Pre-check)    =  0.5 ACU
Session D (Triage)        =  0.5 ACU  (no match on new scope)
Session A (Supplement)    =  2.5 ACU
Session B (Update page)   =  1.5 ACU
Session C (Supplement)    =  2.0 ACU
                            ─────────
Total typical case        =  7.0 ACU
```

Use these estimates when planning sprint capacity and ACU budgets.

---

## Healthy vs Unhealthy Session Indicators

### Healthy Signs
- ACU stays within budget
- Few user messages needed (Devin works autonomously)
- Clear artifacts produced (JSON files, Wiki pages, comments)
- Session exits cleanly via defined exit conditions

### Unhealthy Signs
- High ACU, few messages: Devin is struggling autonomously — missing setup or ambiguous requirements
- Many messages, low ACU: Frequent corrections needed — improve prompt specificity
- ACU exceeds 2x budget: Task scope was too broad or requirements unclear
- Looping on same error 3+ times: Missing knowledge or broken script
- No artifacts produced: Session ran but accomplished nothing tangible

---

## Scoping Principles

### Do

- **One clear objective per session** — "analyze this functionality" not "analyze and document and test"
- **Define exit conditions upfront** — success exits and failure exits
- **Set hard stops** — model count, entry point count, file count, ACU limit
- **Include ACU budget in playbook** — makes the limit visible to Devin
- **Frontload all information** — provide everything in the first prompt
- **Break large work into chained sessions** — each session produces artifacts for the next

### Don't

- **Chain multiple unrelated objectives** — each session should have one job
- **Leave scope open-ended** — "analyze everything" burns ACUs indefinitely
- **Skip setting an ACU limit** — sessions without limits can run away
- **Assume context carries** — DevinStorage JSON files are the state layer, not memory
- **Mix investigation with execution** — use one session to investigate, another to implement

---

## Session Chaining Strategy

Each session produces artifacts that the next session consumes:

```
Session 0 (XS)
  Output: scope hint
  |
  v
Session D (M)
  Input: scope hint
  Output: match result
  |
  +-- Match found --> link tests, post comment (done)
  |
  +-- No match --> trigger chain:
      |
      v
    Session A (M-L)
      Input: scope hint, work item
      Output: analyses/{product}/{slug}.json
      |
      v
    Session B (M)
      Input: analysis JSON
      Output: Wiki page, Index entry
      |
      v
    Session C (M-L)
      Input: analysis JSON, Wiki page
      Output: test cases, TestedBy links
```

**Key principle:** Each link in the chain is independently re-runnable.
If Session B fails, fix and re-run B — don't restart from A.

---

## Context Management Between Sessions

There is **no reliable in-memory state between sessions**. Context is
carried exclusively through persistent artifacts:

| Artifact | Purpose | Location |
|----------|---------|----------|
| Analysis JSON | Machine-readable state | `analyses/{product}/{slug}.json` |
| Wiki pages | Human-readable state | ADO Wiki `/Functionalities/{slug}` |
| Work item comments | Audit trail | ADO work item comment thread |
| Git commits | Version markers | DevinStorage commit history |
| `lastAnalyzedCommit` | Freshness check | Analysis JSON field |

---

## When to Stop a Session

| Signal | Action |
|--------|--------|
| ACU exceeds 2x budget | Stop immediately, redesign scope |
| Looping on same error 3+ times | Stop, check `docs/error-catalog.md` |
| Output quality declining | Stop, redesign the approach |
| Scope limits hit (5 models, 10 entry points) | Post clarification comment, exit cleanly |
| New information invalidates approach | Stop, re-plan with new context |
| Work veering off track | Discontinue — more messages won't fix it |

---

## Using Session Insights

After important or complex sessions, check Session Insights for:

1. **Issue Timeline** — obstacles encountered during the session
2. **Actionable Feedback** — recommended prompt improvements
3. **Knowledge Usage** — which knowledge items influenced behavior

Use these to:
- Identify high-cost steps for optimization
- Refactor L/XL sessions into smaller chains
- Improve playbooks with better advice sections
- Add missing knowledge items that would have prevented issues

---

## Optimal Use Cases for Devin

Tasks where Devin performs best:
- Clear, upfront requirements with verifiable outcomes
- Tasks that would take a junior engineer 4-8 hours
- **Test writing** — Devin's strongest capability (bounded, pattern-driven)
- Repetitive, well-defined workflows
- Tasks with existing patterns to follow (scripts, templates)

Tasks where Devin struggles:
- Ambiguous or subjective requirements
- Tasks requiring deep architectural judgment
- Open-ended exploration without clear boundaries
- Multi-objective sessions mixing investigation and implementation
