# DeepWiki Configuration Guide

> Created: 2026-03-25
> Sources accessed: 2026-03-25
> Source: [Devin Docs — DeepWiki](https://docs.devin.ai/work-with-devin/deepwiki)

---

## What DeepWiki Does

DeepWiki auto-indexes connected repositories and produces wikis with:
- Architecture diagrams
- Source links
- Codebase summaries
- Component relationship maps

It integrates with Devin to help understand unfamiliar code sections.
Public version available at [deepwiki.com](https://deepwiki.com) for open-source repos.

---

## wiki.json Location and Purpose

```
.devin/wiki.json    <- at the repo root
```

This file controls what DeepWiki indexes, how it organizes content,
and what contextual notes it uses to understand the repository.

---

## wiki.json Structure

```json
{
  "name": "Repository display name",
  "description": "One-line description",
  "repo_notes": [
    {
      "topic": "Note title",
      "content": "Contextual information..."
    }
  ],
  "indexing": {
    "include": ["pattern1", "pattern2"],
    "exclude": ["pattern3"]
  },
  "sections": [
    {
      "name": "Section Name",
      "files": ["glob/pattern/*.md"]
    }
  ]
}
```

---

## repo_notes — Critical for Context

`repo_notes` provide architectural context that helps DeepWiki generate
useful documentation about your repo. Without them, DeepWiki makes
generic assumptions.

### Limits
- Maximum **100 notes** per repository
- Maximum **10,000 characters** per note
- Recommended: 500-1000 characters per note (leave room for growth)

### What to Include in Notes

| Topic | Example Content |
|-------|----------------|
| Architecture | "5-session pipeline: 0 (gate) -> D (triage) -> A (analyze) -> B (document) -> C (test)" |
| Naming conventions | "Knowledge items use '— Knowledge Item' suffix. Playbooks use 'session-{id}-{name}.md'" |
| Secret management | "4 separate PATs with minimum scope. No hardcoded values. All from Secrets Manager" |
| API conventions | "All scripts pin to api-version=7.1. No preview versions in production" |
| Error philosophy | "Check docs/error-catalog.md first. Never search online for ADO API troubleshooting" |
| Storage split | "Machine-facing JSON in analyses/. Human-facing markdown in ADO Wiki" |
| Scope limits | "Session A: max 5 models, 10 entry points, one level deep only" |

### Best Practices for Notes
- One topic per note — don't combine unrelated information
- Explain architectural decisions that aren't obvious from code
- Update notes when major structural changes occur
- Prioritize notes that help DeepWiki understand the session pipeline

---

## Indexing Configuration

### Include Patterns
```json
"include": [
  "README.md",
  "INTENT.md",
  "devin/knowledge/**/*.md",
  "devin/playbooks/**/*.md",
  "docs/**/*.md",
  "analyses/**/*.json",
  "DevinStorage/**/*.md"
]
```

### Exclude Patterns
```json
"exclude": [
  "devin/secrets/**",
  ".git/**",
  "scripts/**/*.sh"
]
```

**Why exclude scripts?** Scripts are implementation details — tested and
validated separately. DeepWiki should index knowledge and documentation,
not shell script internals.

**Why exclude secrets?** Even though `secrets-reference.md` contains no
values, excluding the entire directory prevents any accidental inclusion.

---

## Sections

Sections organize the DeepWiki-generated wiki into logical groups:

```json
"sections": [
  {"name": "Getting Started", "files": ["README.md", "INTENT.md"]},
  {"name": "Knowledge Items", "files": ["devin/knowledge/*.md"]},
  {"name": "Playbooks", "files": ["devin/playbooks/*.md"]},
  {"name": "API Reference", "files": ["docs/*.md"]},
  {"name": "Analysis Records", "files": ["analyses/**/*.json"]},
  {"name": "DevinStorage Guides", "files": ["DevinStorage/**/*.md"]}
]
```

### Page Limits
- Standard repos: max **30 pages**
- Enterprise repos: max **80 pages**

---

## Current Configuration (This Repo)

The current `.devin/wiki.json` defines:
- 5 original sections + 1 new (DevinStorage Guides)
- Excludes secrets and scripts
- Includes all markdown docs and JSON analyses

---

## When to Update wiki.json

- Adding a new top-level directory with documentation
- Adding a new category of knowledge items
- Major architectural changes that need new repo_notes
- Removing deprecated sections

---

## Regeneration

After updating `wiki.json`, DeepWiki regenerates on next indexing cycle.
Test effectiveness by reviewing the generated wiki content and adjusting
repo_notes and sections as needed.

---

## Anti-Patterns

| Anti-Pattern | Fix |
|---|---|
| No repo_notes | Add notes explaining architecture and conventions |
| Including secrets in indexing | Always exclude `devin/secrets/**` |
| Indexing script internals | Exclude `scripts/**/*.sh` |
| Notes too long (10k chars) | Keep notes to 500-1000 chars, split if needed |
| Stale notes after restructure | Update notes when architecture changes |
| Too many sections (30+ pages) | Consolidate related files into fewer sections |
