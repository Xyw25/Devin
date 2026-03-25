# Devin Best Practices — Master Guide

> Created: 2026-03-25
> Sources accessed: 2026-03-25
> Sources:
> - [Devin Docs — Good vs Bad Instructions](https://docs.devin.ai/essential-guidelines/good-vs-bad-instructions)
> - [Devin Docs — When to Use Devin](https://docs.devin.ai/essential-guidelines/when-to-use-devin)
> - [Devin Docs — Session Insights](https://docs.devin.ai/product-guides/session-insights)
> - [Cognition Blog — Annual Performance Review 2025](https://cognition.ai/blog/devin-annual-performance-review-2025)
> - [Cognition Blog — How Cognition Uses Devin](https://cognition.ai/blog/how-cognition-uses-devin-to-build-devin)
> - [Coding Agents 101](https://devin.ai/agents101)

This is the single entry point for all Devin usage guidance. Each section
summarizes the key points and links to the specialized guide for details.

---

## 1. Session Design

**Core rule: one objective per session, frontload all context.**

- Target most sessions at S or M size (1-4 ACU)
- Set explicit ACU limits on every session
- Break large work into chained sessions with clear handoffs
- Provide all information in the first prompt — mid-session additions cost more
- Define exit conditions upfront (success exits and failure exits)

**Detailed guide:** [Session Sizing Guide](../guides/session-sizing-guide.md)

---

## 2. Knowledge Items

### Do
- Keep concise — fits on one screen (40-100 lines)
- Use highly specific trigger descriptions
- Focus on facts and context, not procedures
- Split large items into smaller focused pieces
- Include tables, code blocks, and script references
- Assign macros for quick reference (`!deploy-checklist`)

### Don't
- Write overly broad content covering multiple domains
- Use weak trigger descriptions that match everything
- Include step-by-step procedures (those belong in playbooks)
- Let items go stale when APIs or conventions change
- Duplicate content from other knowledge items

**Detailed guide:** [Knowledge Writing Guide](../guides/knowledge-writing-guide.md)

---

## 3. Playbooks

### Do
- Include all 5 sections: Procedure, Specifications, Advice, Forbidden Actions, Required from User
- Make steps mutually exclusive and collectively exhaustive
- Include specific commands, file paths, and script references
- Specify at least one deliverable artifact per playbook
- State ACU budget and exit conditions
- Test in trial sessions before relying on them

### Don't
- Confuse playbooks with knowledge items (procedures vs facts)
- Over-specify to the point of removing problem-solving ability
- Write 50-step playbooks — aim for 6-12 main steps
- Omit deliverables (no artifact = no value)
- Skip forbidden actions (Devin will improvise without guardrails)

**Detailed guide:** [Playbook Writing Guide](../guides/playbook-writing-guide.md)

---

## 4. Prompt Engineering

### Clear Requirements
- Include file paths, class names, and specific references
- Set measurable success criteria — not "make it better"
- Specify validation steps — how to verify the work
- Include test requirements upfront
- Reference existing patterns to emulate

### Avoid
- Vague requests: "Fix the login bug" -> "Fix null check in `src/auth/login.ts:42`"
- Subjective language: "user-friendly" -> "error messages for all form validation failures"
- Task dumping: "Fix, document, test, and deploy" -> separate sessions
- Missing context: always include relevant file paths and component names
- Assumption-heavy prompts: spell out requirements explicitly

**Detailed guide:** [Prompt Engineering Guide](prompt-engineering.md)

---

## 5. Security

- All credentials in Devin Secrets Manager — never paste in chat
- Each PAT has minimum scope (4 separate PATs in this repo)
- Scripts read from environment variables — no hardcoded values
- Secrets can leak via: git commits, comments, logs, error messages, PRs, Wiki pages
- Rotate PATs before expiration — 401 errors are the symptom

**Detailed guide:** [Security Guide](../guides/security-guide.md)

---

## 6. DeepWiki Integration

- Configure via `.devin/wiki.json` at repo root
- Use `repo_notes` to provide architectural context
- Exclude secrets and script internals from indexing
- Organize sections by content type (knowledge, playbooks, docs)
- Max 100 notes (10k chars each), 30 pages (80 enterprise)

**Detailed guide:** [DeepWiki Guide](../guides/deepwiki-guide.md)

---

## 7. Scheduling & Automation

- Attach playbooks to all scheduled tasks for consistency
- Set ACU limits on recurring schedules — costs accumulate
- Use state persistence (DevinStorage JSON) to avoid re-processing
- Monitor cumulative ACU consumption regularly
- All cron times are UTC (displayed in local timezone in UI)
- Start with weekly frequency, increase only if justified

**Detailed guide:** [Scheduling Guide](../guides/scheduling-guide.md)

---

## 8. Review Philosophy

### Treat Output Like Junior Developer Code
Devin's implementation is often correct, but benefits from senior review.
Pay attention to edge cases, error handling, and architectural decisions.

### Review Plans Before Execution
Approve or adjust Devin's proposed steps before committing ACUs.
Collaborate on task breakdown before letting Devin execute.

### Know When to Stop
Don't over-invest in failing sessions. If work veers off track:
- More messages to a struggling agent rarely fixes the problem
- Discontinue and redesign the approach
- Check if missing knowledge or broken scripts caused the issue

### Use Session Insights
After complex sessions, review:
- Issue Timeline — obstacles encountered
- Actionable Feedback — prompt improvements
- Knowledge Usage — which items influenced behavior

### Best Use Cases for Devin
- Tasks with clear, verifiable requirements
- Work that would take a junior engineer 4-8 hours
- **Test writing** — Devin's strongest capability
- Repetitive, well-defined workflows
- Pattern-following tasks with existing templates

---

## 9. Knowledge + Playbook Synergy

Neither knowledge items nor playbooks are fully effective alone.

| Alone | Effect |
|-------|--------|
| Knowledge only | Devin knows facts but doesn't know what to do |
| Playbook only | Devin follows steps but lacks domain context |
| Both together | Devin understands context AND follows tested procedure |

Always pair: relevant knowledge items loaded + playbook attached to session.

---

## 10. Repository-Level Configuration

### .devin.md Files
Drop `.devin.md` files at repo root for automatic loading.
Use for playbooks that should always be active for a repo.

### .cursorrules / CLAUDE.md Analogy
Other AI coding tools use similar repo-level config files.
Devin's equivalent: Knowledge items + Playbooks + `.devin.md` files.

### CI/CD Integration
Have agents validate output before committing:
- Build checks
- Linters
- Test suites
- All should run in the session before artifacts are finalized
