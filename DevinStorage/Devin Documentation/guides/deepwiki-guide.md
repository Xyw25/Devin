# DeepWiki Configuration Guide

> Version: 2.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
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

## wiki.json Schema Reference

Complete field-by-field definition of every possible field in `wiki.json`.

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | `string` | Yes | — | Display name shown in the DeepWiki-generated wiki title. Should be human-readable (e.g., `"ADO Automation Pipeline"` not `"ado-auto"`). |
| `description` | `string` | Yes | — | One-line description of the repository's purpose. Appears as subtitle in generated wiki. |
| `repo_notes` | `array<object>` | No | `[]` | Array of contextual notes that provide architectural context to DeepWiki. Max 100 items. |
| `repo_notes[].topic` | `string` | Yes (if note exists) | — | Title of the note. Should be a short, descriptive label (e.g., `"Session Pipeline"`, `"API Conventions"`). |
| `repo_notes[].content` | `string` | Yes (if note exists) | — | Body of the note. Max 10,000 characters. Plain text, no markdown rendering. |
| `indexing` | `object` | No | Index all files | Object controlling which files DeepWiki indexes. |
| `indexing.include` | `array<string>` | No | `["**/*"]` | Glob patterns for files to include. Patterns are relative to repo root. |
| `indexing.exclude` | `array<string>` | No | `[]` | Glob patterns for files to exclude. Evaluated after include. Takes precedence over include. |
| `sections` | `array<object>` | No | Auto-generated | Ordered array defining how the generated wiki is organized into sections. |
| `sections[].name` | `string` | Yes (if section exists) | — | Display name of the section in the generated wiki sidebar. |
| `sections[].files` | `array<string>` | Yes (if section exists) | — | Glob patterns matching files that belong to this section. A file matching multiple sections appears in the first match only. |

### Example: Minimal Valid wiki.json

```json
{
  "name": "My Project",
  "description": "A brief description of what the project does"
}
```

### Example: Fully Specified wiki.json

```json
{
  "name": "ADO Automation Pipeline",
  "description": "5-session pipeline for Azure DevOps work item processing",
  "repo_notes": [
    {
      "topic": "Architecture",
      "content": "5-session pipeline: 0 (gate) -> D (triage) -> A (analyze) -> B (document) -> C (test)"
    }
  ],
  "indexing": {
    "include": ["README.md", "docs/**/*.md", "analyses/**/*.json"],
    "exclude": ["devin/secrets/**", ".git/**"]
  },
  "sections": [
    {"name": "Getting Started", "files": ["README.md", "INTENT.md"]},
    {"name": "Knowledge Items", "files": ["devin/knowledge/*.md"]}
  ]
}
```

---

## Limits Table

All known DeepWiki limits in one reference:

| Resource | Limit | Notes |
|----------|-------|-------|
| `repo_notes` count | **100** per repository | Add more notes by splitting topics; do not combine unrelated info into one note |
| `repo_notes[].content` size | **10,000 characters** per note | Recommended working range: 500-1000 characters to leave room for growth |
| Pages (standard repos) | **30 pages** | Consolidate sections if approaching limit |
| Pages (enterprise repos) | **80 pages** | Enterprise plan required |
| Sections count | No hard limit documented | Practical limit tied to page count — more sections means more pages consumed |
| `indexing.include` patterns | No hard limit documented | Keep patterns specific to avoid indexing irrelevant files |
| `indexing.exclude` patterns | No hard limit documented | Always exclude secrets, build artifacts, and vendored dependencies |
| `sections[].files` patterns | No hard limit documented | A file matching multiple sections appears in the first matching section only |

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

## repo_notes Best Practices (Expanded)

### Topic Naming Guidelines

Choose topic names that are **short, categorical, and scannable**. DeepWiki uses the topic as a label — it should tell the reader what domain the note covers without reading the content.

| Good Topic Name | Bad Topic Name | Why |
|-----------------|----------------|-----|
| `Architecture` | `How the system works` | Too vague, reads like a sentence |
| `Session Pipeline` | `Sessions` | More specific about what aspect of sessions |
| `API Conventions` | `API` | Clarifies it covers conventions, not endpoints |
| `Error Handling` | `What to do when things break` | Categorical, not conversational |
| `Secret Management` | `PATs and tokens and auth stuff` | Concise, single domain |
| `Scope Limits — Session A` | `Limits` | Scoped to a specific session |

### Content Guidelines

1. **State facts, not instructions.** Notes describe "what is", not "what to do". DeepWiki uses them as context, not as commands.
   - Good: `"All scripts pin to api-version=7.1. No preview versions in production."`
   - Bad: `"Make sure you always use api-version=7.1 and never use preview versions."`

2. **Be specific and concrete.** Numbers, file paths, and names are more useful than vague descriptions.
   - Good: `"5 sessions: 0, A, B, C, D. Each has a dedicated playbook in devin/playbooks/."`
   - Bad: `"There are several sessions, each with its own playbook file."`

3. **One concept per note.** If a note covers two unrelated topics, split it. DeepWiki retrieves notes by relevance — mixed notes reduce retrieval quality.

4. **Keep under 1000 characters.** The 10,000 character limit is a ceiling, not a target. Shorter notes are retrieved and processed faster.

5. **Include relationship information.** Notes that explain how components connect are more valuable than notes describing components in isolation.
   - Good: `"Session B reads from analyses/{product}/{slug}.json (written by Session A) and writes to ADO Wiki at /Functionalities/{slug}."`
   - Bad: `"Session B writes to the Wiki."`

### When to Update Notes

| Trigger | Action |
|---------|--------|
| New top-level directory added | Add note explaining its purpose and relationship to existing structure |
| Session added or removed | Update architecture note with new pipeline flow |
| API version pinned or changed | Update API conventions note |
| New naming convention adopted | Add or update naming conventions note |
| Major refactor of file layout | Review and update all notes referencing file paths |
| New secret or PAT added | Update secret management note |

### Examples: Good vs Bad Notes

**Good note:**
```json
{
  "topic": "Storage Split",
  "content": "Machine-facing data lives in analyses/ as JSON files with a fixed schema (see docs/analysis-schema.md). Human-facing documentation is published to the ADO Wiki under /Functionalities/. Session A writes JSON, Session B reads JSON and writes Wiki. Never mix the two: JSON has no prose, Wiki has no raw data."
}
```
Why it works: States the split clearly, names the directories, references the schema doc, explains which sessions interact with which store, and includes the key constraint.

**Bad note:**
```json
{
  "topic": "Storage",
  "content": "We store stuff in two places. The analyses folder has JSON and the Wiki has documentation. Make sure to keep them separate and don't put the wrong thing in the wrong place. Also remember that the scripts are in the scripts folder and the playbooks are in the playbooks folder."
}
```
Why it fails: Vague topic name, conversational tone, mixes storage split with unrelated directory info, no file paths or session references, no schema link.

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

## Troubleshooting

### Wiki Not Regenerating After wiki.json Update

**Symptoms:** You updated `wiki.json`, pushed to the default branch, but the DeepWiki content has not changed.

**Possible causes and fixes:**

1. **Indexing cycle not yet run.** DeepWiki does not regenerate instantly. Wait for the next indexing cycle (timing depends on plan and repo activity). Check back after 15-30 minutes.
2. **wiki.json not on default branch.** DeepWiki reads `wiki.json` from the default branch only. If your changes are on a feature branch, they will not take effect until merged.
3. **JSON syntax error.** An invalid `wiki.json` is silently ignored — DeepWiki falls back to default behavior. Validate your JSON with `jq . .devin/wiki.json` or any JSON linter before pushing.
4. **File not at correct path.** The file must be at `.devin/wiki.json` (note the leading dot). Placing it at `devin/wiki.json` (no dot) or any other path will not work.

### repo_notes Not Appearing in Generated Wiki

**Symptoms:** You added `repo_notes` entries but the generated wiki does not reflect the context you provided.

**Possible causes and fixes:**

1. **Notes are informational context, not direct content.** `repo_notes` influence how DeepWiki interprets and describes code — they do not appear as literal text in the wiki. Review the generated descriptions to see if your context improved them.
2. **Note content is too vague.** Generic notes like `"This is a web app"` provide no useful signal. Be specific with file paths, numbers, and architectural details.
3. **Exceeded 100-note limit.** Notes beyond the 100th are silently dropped. Count your notes and consolidate if needed.
4. **Note content exceeds 10,000 characters.** Oversized notes may be truncated or ignored. Check character counts.

### Indexing Delays

**Symptoms:** New files added to the repo are not appearing in the wiki.

**Possible causes and fixes:**

1. **File not matched by include patterns.** Verify your glob patterns match the new file path. Test with: does the path match at least one `indexing.include` pattern and zero `indexing.exclude` patterns?
2. **File matched by exclude pattern.** Exclude patterns take precedence. Check that no exclude pattern inadvertently matches your file.
3. **Page limit reached.** If you are at 30 pages (standard) or 80 pages (enterprise), new files will not generate additional pages. Consolidate sections or remove stale content.
4. **Repository not connected.** Verify the repository is connected to Devin and DeepWiki indexing is enabled in the Devin workspace settings.

### Sections Not Grouping Files Correctly

**Symptoms:** Files appear in the wrong section or are missing from all sections.

**Possible causes and fixes:**

1. **First-match wins.** A file matching multiple `sections[].files` patterns appears only in the first matching section. Reorder sections so the most specific patterns come first.
2. **Glob pattern mismatch.** `*.md` matches files in the directory only; `**/*.md` matches recursively. Use `**` for nested directories.
3. **File not in any section.** Files not matched by any section's patterns may appear in an "Other" or uncategorized group, or may not appear at all. Add a catch-all section at the end if needed.

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
