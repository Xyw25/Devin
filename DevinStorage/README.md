# DevinStorage — Best Practices, Guides & References

> Created: 2026-03-25
> All sources accessed: 2026-03-25

Central documentation for Devin platform best practices, operational guides,
patterns, anti-patterns, and reference material. Everything Devin needs to
operate effectively — compiled from official Devin docs, Cognition blog posts,
community resources, and internal conventions.

---

## Best Practices

| File | Description |
|------|-------------|
| [master-guide.md](best-practices/master-guide.md) | Single entry point — covers all Devin usage areas with cross-references |
| [patterns-and-anti-patterns.md](best-practices/patterns-and-anti-patterns.md) | 10 proven patterns (P1-P10) and 10 anti-patterns (A1-A10) with concrete examples |
| [prompt-engineering.md](best-practices/prompt-engineering.md) | How to write effective prompts — good/bad examples, templates, cost-aware techniques |

## Guides

| File | Description |
|------|-------------|
| [knowledge-writing-guide.md](guides/knowledge-writing-guide.md) | How to write effective Knowledge items — structure, triggers, content rules |
| [playbook-writing-guide.md](guides/playbook-writing-guide.md) | How to write effective Playbooks — 5-section structure, deliverables, iteration |
| [session-sizing-guide.md](guides/session-sizing-guide.md) | ACU optimization, session scoping, chaining strategy, when to stop |
| [scheduling-guide.md](guides/scheduling-guide.md) | Cron expressions, automation recipes, state persistence, attaching playbooks |
| [deepwiki-guide.md](guides/deepwiki-guide.md) | wiki.json configuration, repo_notes, indexing strategies |
| [security-guide.md](guides/security-guide.md) | Secret management, leak prevention, PAT rotation, incident response |

## References

| File | Description |
|------|-------------|
| [session-architecture.md](references/session-architecture.md) | Full session flow diagram, decision matrix, artifact flow |
| [acu-reference.md](references/acu-reference.md) | ACU sizing table, diagnostic matrix, red flags, optimization strategies |
| [sources.md](references/sources.md) | All external sources with URLs and access dates |

---

## Quick Navigation

**Starting out?** Read [master-guide.md](best-practices/master-guide.md) first.

**Writing a Knowledge item?** Follow [knowledge-writing-guide.md](guides/knowledge-writing-guide.md).

**Writing a Playbook?** Follow [playbook-writing-guide.md](guides/playbook-writing-guide.md).

**Sizing a session?** Check [acu-reference.md](references/acu-reference.md) and [session-sizing-guide.md](guides/session-sizing-guide.md).

**Setting up automation?** Follow [scheduling-guide.md](guides/scheduling-guide.md).

**Configuring DeepWiki?** Follow [deepwiki-guide.md](guides/deepwiki-guide.md).

**Security review?** Check [security-guide.md](guides/security-guide.md).

**Understanding the session pipeline?** See [session-architecture.md](references/session-architecture.md).
