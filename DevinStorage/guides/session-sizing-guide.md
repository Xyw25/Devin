# Session Sizing & ACU Optimization Guide

> Created: 2026-03-25
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

## ACU Budget Targets (This Repo)

| Session | Target ACU | Size |
|---------|-----------|------|
| 0 — Pre-check & Router | <= 1 | XS |
| A — Code Analysis | <= 5 (full), <= 3 (supplement) | M-L |
| B — Documentation | <= 3 | M |
| C — Test Coverage | <= 5 | M-L |
| D — Triage & Linking | <= 3 (found), <= 5 (chain) | M-L |

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
