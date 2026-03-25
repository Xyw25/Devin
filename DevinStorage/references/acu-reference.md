# ACU Quick Reference

> Created: 2026-03-25
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

1. **Frontload context** — provide everything in the first prompt
2. **Set explicit ACU limits** — prevent runaway sessions
3. **Use playbooks** — tested paths are cheaper than improvised ones
4. **Attach knowledge items** — reduces inference overhead
5. **Chain sessions** — smaller sessions are more efficient than large ones
6. **Review Session Insights** — identify high-cost steps to optimize
7. **Use scripts** — pre-built scripts eliminate trial-and-error API calls

---

## Maximum Recommended ACU

**Never exceed 10 ACU per session.** Devin's performance degrades in
long sessions. If a task requires more than 10 ACU, break it into
multiple chained sessions with clear artifact handoffs.
