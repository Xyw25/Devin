# External Sources Reference

> Version: 1.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> All sources accessed: 2026-03-25

---

## Official Devin Documentation

| Topic | URL | Used In |
|-------|-----|---------|
| Knowledge Items | https://docs.devin.ai/product-guides/knowledge | knowledge-writing-guide.md |
| Creating Playbooks | https://docs.devin.ai/product-guides/creating-playbooks | playbook-writing-guide.md |
| Scheduled Sessions | https://docs.devin.ai/product-guides/scheduled-sessions | scheduling-guide.md |
| Session Insights | https://docs.devin.ai/product-guides/session-insights | session-sizing-guide.md, acu-reference.md |
| Good vs Bad Instructions | https://docs.devin.ai/essential-guidelines/good-vs-bad-instructions | master-guide.md, patterns-and-anti-patterns.md, prompt-engineering.md |
| When to Use Devin | https://docs.devin.ai/essential-guidelines/when-to-use-devin | master-guide.md, session-sizing-guide.md |
| DeepWiki | https://docs.devin.ai/work-with-devin/deepwiki | deepwiki-guide.md |
| Repo Setup | https://docs.devin.ai/onboard-devin/repo-setup | security-guide.md |
| API Reference / Usage | https://docs.devin.ai/api-reference/v1/usage-examples | security-guide.md |
| Release Notes | https://docs.devin.ai/release-notes | master-guide.md (monitored daily) |
| API Release Notes | https://docs.devin.ai/api-reference/release-notes | sources.md (monitored daily) |

## Cognition Blog

| Topic | URL | Used In |
|-------|-----|---------|
| Devin Can Now Schedule Devins | https://cognition.ai/blog/devin-can-now-schedule-devins | scheduling-guide.md |
| Jan 2025 Product Update | https://cognition.ai/blog/jan-25-product-update | session-sizing-guide.md, acu-reference.md |
| Annual Performance Review 2025 | https://cognition.ai/blog/devin-annual-performance-review-2025 | master-guide.md |
| How Cognition Uses Devin | https://cognition.ai/blog/how-cognition-uses-devin-to-build-devin | master-guide.md, prompt-engineering.md |
| Blog Index (Page 1) | https://cognition.ai/blog/1 | master-guide.md, sources.md (monitored daily) |

## Community Resources

| Topic | URL | Used In |
|-------|-----|---------|
| Coding Agents 101 | https://devin.ai/agents101 | master-guide.md, patterns-and-anti-patterns.md, prompt-engineering.md |
| AI Coding Anti-Patterns | https://docs.bswen.com/blog/2026-03-25-ai-coding-anti-patterns/ | patterns-and-anti-patterns.md |
| How Devin Can Leak Secrets | https://embracethered.com/blog/posts/2025/devin-can-leak-your-secrets/ | security-guide.md |

## Internal Sources

| Topic | Location | Used In |
|-------|----------|---------|
| Session Architecture | `INTENT.md` (this repo) | session-architecture.md |
| ADO API Gotchas | `INTENT.md` (this repo) | patterns-and-anti-patterns.md |
| Script Library | `scripts/ado/` (this repo) | All guides referencing scripts |
| Analysis JSON Schema | `INTENT.md` (this repo) | session-architecture.md |

---

## Source Freshness

All external sources were accessed on **2026-03-25**. Devin documentation
and blog posts are subject to updates. Re-verify sources periodically,
especially after major Devin platform updates.

**Automated re-verification:** Daily via `session-doc-monitor.md` playbook.
State tracked in `DevinStorage/schedules/doc-monitor-state.json`.

**Manual re-verification:** Quarterly, or after any Devin platform
announcement that affects sessions, scheduling, or knowledge items.
