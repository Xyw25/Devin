# ACU Quick Reference

> Version: 2.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> Sources accessed: 2026-03-25
> Sources:
> - [Devin Docs — Session Insights](https://docs.devin.ai/product-guides/session-insights)
> - [Cognition Blog — Jan 2025 Product Update](https://cognition.ai/blog/jan-25-product-update)

---

## What is ACU?

ACU (Agent Compute Unit) is a normalized measure of resources consumed by
a Devin session. It includes virtual machine time, model inference, and
networking bandwidth.

**Lower ACU = more efficient session for a given task.**

---

## Size Classification

| Size | ACU Range | Messages | Health | Action |
|------|-----------|----------|--------|--------|
| XS | < 1 | 0-1 | Healthy | Ideal for gate checks |
| S | 1-2 | 1-3 | Healthy | Target for simple tasks |
| M | 2-4 | 2-5 | Healthy | Target for most work |
| L | 4-7 | 5-10 | Unhealthy | Consider splitting |
| XL | 7-10 | 10+ | Unhealthy | Must redesign |

---

## Session Budgets (This Repo)

| Session | Budget | Typical Size |
|---------|--------|-------------|
| 0 — Pre-check | <= 1 | XS |
| A — Analysis (full) | <= 5 | M-L |
| A — Analysis (supplement) | <= 3 | M |
| B — Documentation | <= 3 | M |
| C — Test Coverage | <= 5 | M-L |
| D — Triage (found) | <= 3 | M |
| D — Triage (chain) | <= 5 | M-L |

---

## Real Measured ACU Values (Estimates)

The following values are **estimates** based on observed typical runs. Actual
ACU consumption varies by codebase size, API response times, and session context.

| Session & Mode | Estimated ACU | Messages | Notes |
|---------------|--------------|----------|-------|
| Session 0 — tag check only (no tag, exit) | ~0.1 | 0 | Reads work item, finds no tag, exits |
| Session 0 — tag check (valid, route) | ~0.3 | 0-1 | Reads work item, extracts scope hint, routes |
| Session 0 — with clarification comment | ~0.8 | 1 | Reads work item, posts comment, exits |
| Session D — found match, link & comment | ~2.0 | 1-2 | Queries index, matches, links tests, posts |
| Session D — no match, triggers chain | ~1.5 | 1 | Queries index, no match, triggers Session A |
| Session A — full new analysis | ~4.2 | 2-4 | Clones repo, analyzes 5 models, writes JSON |
| Session A — supplement (HEAD moved) | ~2.1 | 1-3 | Reads existing JSON, analyzes diff, updates |
| Session A — skip (commit matches) | ~0.2 | 0 | Checks commit SHA, hands off immediately |
| Session A — scope overflow exit | ~3.5 | 2-3 | Starts analysis, hits limit, posts comment |
| Session B — create new Wiki page | ~2.5 | 1-2 | Reads JSON, creates page + index entry |
| Session B — update existing page | ~2.0 | 1-2 | Reads JSON, GETs page (ETag), PUTs update |
| Session B — skip (no new analysis) | ~0.2 | 0 | Checks state, hands off immediately |
| Session C — create tests from scratch | ~4.5 | 3-5 | Reads JSON + Wiki, creates test cases, links |
| Session C — update tests | ~3.5 | 2-4 | Reads new analysis, updates/creates tests |
| Session C — skip (tests linked, no change) | ~0.2 | 0 | Checks linkage, hands off immediately |
| Full chain (D->A->B->C->D) worst case | ~12.0 | 8-14 | All sessions run full, no skips |
| Full chain with skips (typical) | ~6.0 | 4-8 | Some sessions skip or supplement |

---

## Diagnostic Matrix

| ACU | Messages | Diagnosis | Fix |
|-----|----------|-----------|-----|
| High | Few | Devin struggled autonomously | Missing context or broken setup |
| Low | Many | Too many corrections | Improve prompt specificity |
| High | Many | Both problems | Redesign scope, improve prompt |
| Low | Few | Ideal | Keep doing this |

---

## Red Flags

| Signal | Threshold | Action |
|--------|-----------|--------|
| ACU exceeds 2x budget | Any session | Stop immediately, redesign |
| Same error 3+ times | During session | Stop, check error-catalog.md |
| No artifacts produced | End of session | Playbook missing deliverables |
| L/XL size consistently | Recurring | Split into smaller sessions |
| Output quality declining | During session | Stop, re-plan approach |

---

## Optimization Strategies

| Strategy | Implementation | Expected Savings | Applies To |
|----------|---------------|-----------------|-----------|
| Frontload context | Provide all relevant files, links, and constraints in the first prompt. Attach analysis JSON, scope hints, and error catalog. | 20-40% ACU reduction. Eliminates back-and-forth clarification cycles. | All sessions |
| Set explicit ACU limits | State budget in the playbook prompt (e.g., "Complete within 3 ACU"). Devin will self-regulate. | Prevents runaway sessions. Saves 2-5 ACU on sessions that would otherwise spiral. | All sessions |
| Use playbooks | Tested, deterministic instruction sets that follow proven paths. Avoids improvisation and trial-and-error. | 30-50% ACU reduction vs. ad-hoc prompts. Playbooks encode learned paths. | All sessions |
| Attach knowledge items | Pre-written context files attached to the session. Reduces inference overhead since Devin doesn't need to discover information. | 15-25% ACU reduction. Fewer API calls to gather context. | Sessions A, B, C |
| Chain sessions | Split large tasks into smaller, focused sessions with clear artifact handoffs. Each session stays in the M size range. | Avoids L/XL degradation. Total ACU may be similar but reliability improves significantly. | Complex workflows |
| Review Session Insights | After each run, check the Session Insights dashboard. Identify high-cost steps (e.g., repeated API retries, large file reads). | 10-20% ACU reduction on subsequent runs by eliminating identified waste. | All sessions (post-run) |
| Use scripts | Pre-built shell scripts for ADO API operations. Eliminates trial-and-error `curl` construction. | 1-2 ACU saved per session that would otherwise build API calls from scratch. | Sessions A, B, C, D |
| Skip/supplement logic | Check if work already exists before doing it. Use commit SHA comparison and Wiki page existence checks. | Saves 2-5 ACU per session that would otherwise redo existing work. | Sessions A, B, C |
| Scope limits | Enforce hard limits: 5 models, 10 entry points, one level deep. Prevents unbounded analysis. | Prevents 5-10 ACU overruns on large codebases. | Session A |

---

## Maximum Recommended ACU

**Never exceed 10 ACU per session.** Devin's performance degrades in
long sessions. If a task requires more than 10 ACU, break it into
multiple chained sessions with clear artifact handoffs.
