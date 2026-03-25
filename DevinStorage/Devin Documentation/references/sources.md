# External Sources Reference

> Version: 2.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> All sources accessed: 2026-03-25

---

## Official Devin Documentation

| Topic | URL | Used In | Last Verified | Monitoring Status |
|-------|-----|---------|---------------|-------------------|
| Knowledge Items | https://docs.devin.ai/product-guides/knowledge | knowledge-writing-guide.md | 2026-03-25 | No |
| Creating Playbooks | https://docs.devin.ai/product-guides/creating-playbooks | playbook-writing-guide.md | 2026-03-25 | No |
| Scheduled Sessions | https://docs.devin.ai/product-guides/scheduled-sessions | scheduling-guide.md | 2026-03-25 | No |
| Session Insights | https://docs.devin.ai/product-guides/session-insights | session-sizing-guide.md, acu-reference.md | 2026-03-25 | No |
| Good vs Bad Instructions | https://docs.devin.ai/essential-guidelines/good-vs-bad-instructions | master-guide.md, patterns-and-anti-patterns.md, prompt-engineering.md | 2026-03-25 | No |
| When to Use Devin | https://docs.devin.ai/essential-guidelines/when-to-use-devin | master-guide.md, session-sizing-guide.md | 2026-03-25 | No |
| DeepWiki | https://docs.devin.ai/work-with-devin/deepwiki | deepwiki-guide.md | 2026-03-25 | No |
| Repo Setup | https://docs.devin.ai/onboard-devin/repo-setup | security-guide.md | 2026-03-25 | No |
| API Reference / Usage | https://docs.devin.ai/api-reference/v1/usage-examples | security-guide.md | 2026-03-25 | No |
| Release Notes | https://docs.devin.ai/release-notes | master-guide.md (monitored daily) | 2026-03-25 | Yes |
| API Release Notes | https://docs.devin.ai/api-reference/release-notes | sources.md (monitored daily) | 2026-03-25 | Yes |

## Cognition Blog

| Topic | URL | Used In | Last Verified | Monitoring Status |
|-------|-----|---------|---------------|-------------------|
| Devin Can Now Schedule Devins | https://cognition.ai/blog/devin-can-now-schedule-devins | scheduling-guide.md | 2026-03-25 | No |
| Jan 2025 Product Update | https://cognition.ai/blog/jan-25-product-update | session-sizing-guide.md, acu-reference.md | 2026-03-25 | No |
| Annual Performance Review 2025 | https://cognition.ai/blog/devin-annual-performance-review-2025 | master-guide.md | 2026-03-25 | No |
| How Cognition Uses Devin | https://cognition.ai/blog/how-cognition-uses-devin-to-build-devin | master-guide.md, prompt-engineering.md | 2026-03-25 | No |
| Blog Index (Page 1) | https://cognition.ai/blog/1 | master-guide.md, sources.md (monitored daily) | 2026-03-25 | Yes |

## Azure DevOps REST API

| Topic | URL | Used In | Last Verified | Monitoring Status |
|-------|-----|---------|---------------|-------------------|
| Azure DevOps REST API (root) | https://learn.microsoft.com/en-us/rest/api/azure-devops/ | patterns-and-anti-patterns.md, error-recovery-guide.md, secrets-management-guide.md | 2026-03-25 | No |

## Community Resources

| Topic | URL | Used In | Last Verified | Monitoring Status |
|-------|-----|---------|---------------|-------------------|
| Coding Agents 101 | https://devin.ai/agents101 | master-guide.md, patterns-and-anti-patterns.md, prompt-engineering.md | 2026-03-25 | No |
| AI Coding Anti-Patterns | https://docs.bswen.com/blog/2026-03-25-ai-coding-anti-patterns/ | patterns-and-anti-patterns.md | 2026-03-25 | No |
| How Devin Can Leak Secrets | https://embracethered.com/blog/posts/2025/devin-can-leak-your-secrets/ | security-guide.md | 2026-03-25 | No |
| DeepWiki (public site) | https://deepwiki.com | deepwiki-guide.md | 2026-03-25 | No |

## Internal Sources

| Topic | Location | Used In | Last Verified | Monitoring Status |
|-------|----------|---------|---------------|-------------------|
| Session Architecture | `INTENT.md` (this repo) | session-architecture.md | 2026-03-25 | No |
| ADO API Gotchas | `INTENT.md` (this repo) | patterns-and-anti-patterns.md | 2026-03-25 | No |
| Script Library | `scripts/ado/` (this repo) | All guides referencing scripts | 2026-03-25 | No |
| Analysis JSON Schema | `INTENT.md` (this repo) | session-architecture.md | 2026-03-25 | No |

---

## Source Freshness

All external sources were accessed on **2026-03-25**. Devin documentation
and blog posts are subject to updates. Re-verify sources periodically,
especially after major Devin platform updates.

**Automated re-verification:** Daily via `session-doc-monitor.md` playbook.
State tracked in `DevinStorage/schedules/doc-monitor-state.json`.

**Manual re-verification:** Quarterly, or after any Devin platform
announcement that affects sessions, scheduling, or knowledge items.
