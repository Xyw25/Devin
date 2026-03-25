# Patterns and Anti-Patterns — Detailed Reference

> Version: 2.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> Sources accessed: 2026-03-25
> Sources:
> - Internal repo analysis (this repository's conventions and architecture)
> - [Devin Docs — Good vs Bad Instructions](https://docs.devin.ai/essential-guidelines/good-vs-bad-instructions)
> - [Coding Agents 101](https://devin.ai/agents101)
> - [AI Coding Anti-Patterns](https://docs.bswen.com/blog/2026-03-25-ai-coding-anti-patterns/)

---

## Patterns (What Works)

### P1: Scoped Analysis with Hard Stops

**What:** Define maximum scope limits that trigger a clean exit with a
clarification request rather than unbounded exploration.

**Example in this repo:** Session A limits — max 5 models, 10 entry points,
one level deep only. When hit, post a comment listing findings and ask
which aspect to focus on.

**Why it works:** Prevents ACU burn on open-ended exploration. Devin exits
gracefully instead of spiraling into transitive dependency chains.

---

### P2: Machine-Readable Storage + Human-Readable Wiki

**What:** Store the same information in two formats — JSON for Devin,
markdown Wiki for humans.

**Example in this repo:** `analyses/{product}/{slug}.json` (machine) paired
with ADO Wiki `/Functionalities/{slug}` pages (human).

**Why it works:** Devin reads JSON efficiently without parsing markdown.
Humans browse Wiki pages without reading JSON. Both stay in sync through
the session pipeline.

---

### P3: Script Library over Raw API Calls

**What:** Provide a library of tested, parameterized scripts instead of
letting Devin compose raw API calls from scratch.

**Example in this repo:** `scripts/ado/` contains 14 scripts covering all
ADO operations. Playbooks reference scripts, never raw curl.

**Why it works:** Scripts are tested once and reused everywhere. Error
handling is consistent. Content-Type, auth headers, and URL encoding
are handled correctly every time.

---

### P4: ETag-First Wiki Updates

**What:** Always GET a resource before PUT-updating it, capturing the
freshness token (ETag) for the update request.

**Example in this repo:** Every Wiki update follows GET -> capture ETag ->
PUT with `If-Match: {ETag}`. The script `update-page.sh` requires ETag
as a mandatory parameter.

**Why it works:** Prevents 409 Conflict errors. Enforces freshness. The
script-level enforcement (`${3:?...}`) makes it impossible to skip.

---

### P5: Keyword-Based Triage with Threshold

**What:** Match work items to known functionalities using keyword overlap
with a minimum threshold.

**Example in this repo:** Session D extracts keywords from work item title
and description, matches against `keywords` arrays. Minimum 2 overlapping
keywords for a confirmed match.

**Why it works:** Avoids false positives (single keyword matches are too
loose). Gracefully falls back to full analysis chain when confidence is low.

---

### P6: Session Chaining with Clear Handoff

**What:** Each session has one job and produces artifacts for the next
session in the chain.

**Example in this repo:** 0 (gate) -> D (triage) -> A (analyze) -> B (document)
-> C (test). Each session is independently re-runnable.

**Why it works:** ACU stays bounded per session. If one session fails, only
that session needs to be re-run. Artifacts serve as checkpoints.

---

### P7: Error Catalog as First Resort

**What:** Maintain a growing catalog of encountered errors and their
resolutions. Check it before any other recovery action.

**Example in this repo:** `docs/error-catalog.md` is the first thing to
check when any ADO call fails. Knowledge items reinforce this rule.

**Why it works:** Prevents online searching (which burns ACUs). Builds
institutional memory over time. New errors are added after resolution.

---

### P8: Knowledge + Playbook Combination

**What:** Pair knowledge items (facts/context) with playbooks (procedures)
for maximum effectiveness.

**Example in this repo:** `devin/knowledge/ado-wiki.md` provides ETag facts;
`devin/playbooks/session-b-documentation.md` provides the step-by-step
procedure that uses those facts.

**Why it works:** Neither is effective alone. Knowledge without playbooks
leaves Devin knowing facts but not what to do. Playbooks without knowledge
leave Devin following steps without understanding why.

---

### P9: Commit SHA as State Tracker

**What:** Use git commit SHAs as version markers to detect changes without
external state services.

**Example in this repo:** `lastAnalyzedCommit` in analysis JSON files.
Session A compares this against current HEAD to decide skip/supplement/full.

**Why it works:** No external state service needed. Git-native. Deterministic.
If the SHA matches, the analysis is current — period.

---

### P10: Minimum-Scope PATs

**What:** Issue separate credentials for each operation category, each with
the minimum required scope.

**Example in this repo:** 4 PATs — WORKITEMS, WIKI, CODE, TESTS. Each has
only the scope needed for its operations.

**Why it works:** Blast radius containment. If one PAT leaks, only that
operation category is compromised. Easier to rotate individually.

---

### P11: Investigation-First for Unknown Territory

**What:** Run a cheap, time-boxed investigation session before committing
to a full implementation session when entering unfamiliar code areas.

**Example in this repo:** Before Session A runs full analysis on a new
product area, a lightweight investigation session lists files, reads
README files, and identifies the tech stack. The output is a short
summary that informs whether Session A should proceed or request
human guidance on scope.

**Why it works:** Prevents wasted ACUs on wrong assumptions. A 5-minute
investigation that reveals a monorepo structure or unexpected framework
saves an entire failed implementation session. The investigation artifact
also becomes reusable context for future sessions targeting the same area.

---

### P12: Attachment-Aware Bug Triage

**What:** Always check work item attachments (screenshots, logs, crash
dumps) before analyzing a bug report. Download and review them as the
first triage step.

**Example in this repo:** Session D's triage playbook includes an explicit
step: call `scripts/ado/get-work-item.sh` with `$expand=attachments`,
then download each attachment URL. Screenshots are described in the
triage comment; log files are scanned for error patterns before any
code investigation begins.

**Why it works:** Attachments often contain the actual reproduction
evidence — stack traces, screenshots of the broken state, network logs
showing the failing request. Skipping them means Devin guesses at the
problem instead of reading the evidence directly.

---

### P13: WIQL for Bulk Operations

**What:** Use WIQL (Work Item Query Language) queries to find related
work items in batch rather than fetching them one-by-one by ID.

**Example in this repo:** Session D uses a WIQL query like
`SELECT [System.Id] FROM WorkItems WHERE [System.Tags] CONTAINS 'auth'
AND [System.State] = 'Active'` to find all related items in a single
API call. The results feed into batch processing logic instead of
looping individual GET requests.

**Why it works:** Reduces API calls and ACU burn. A single WIQL query
replaces N individual work item fetches. Rate limiting becomes less of
a concern, and the session completes faster with fewer failure points.

---

### P14: PR Description from Wiki Context

**What:** When creating pull requests, pull context from the relevant
functionality Wiki page to enrich the PR description with domain
background and design decisions.

**Example in this repo:** Session C's test PR playbook reads the Wiki
page for the target functionality (via `scripts/ado/get-page.sh`),
extracts the "Overview" and "Key Behaviors" sections, and includes
them in the PR description under a "Context" heading. Reviewers see
the full picture without leaving the PR.

**Why it works:** Reviewers get full context without searching through
Wiki pages, Slack threads, or work items. The PR becomes a self-contained
document. This also creates a natural audit trail linking code changes
back to documented functionality.

---

### P15: Idempotent Session Design

**What:** Design sessions so they are safe to re-run without duplicating
artifacts. Always check for existing resources before creating new ones.

**Example in this repo:** Session B checks whether a Wiki page already
exists (via GET) before calling create. If the page exists, it updates
instead. Session C checks for existing test suites by name before
creating a new one. Analysis JSON files are overwritten in place, not
appended.

**Why it works:** Prevents duplicate Wiki pages, duplicate test cases,
and duplicate work item comments. Re-running a failed session becomes
a safe recovery action instead of a source of data pollution. This is
especially critical when sessions are triggered automatically by
pipelines.

---

## Anti-Patterns (What Fails)

### A1: Vague Requests Without Success Criteria

**Bad:** "Make the dashboard better"
**Good:** "Add pagination to /dashboard with 20 items per page, test with 100+ records"

**Why it fails:** Devin cannot infer subjective quality criteria. Without
measurable success conditions, the session either loops indefinitely or
produces something that doesn't match expectations.

---

### A2: Missing File Paths and References

**Bad:** "Fix the login bug"
**Good:** "Fix null check in `src/auth/login.ts` line 42 — user.email is
undefined when SSO token lacks email claim"

**Why it fails:** Devin spends ACUs searching for the relevant code.
Providing specific paths eliminates exploration overhead.

---

### A3: No Validation Criteria

**Bad:** "Deploy the fix"
**Good:** "Deploy and verify 200 response from `/api/health`, then check
that login flow completes without errors on staging"

**Why it fails:** Without validation criteria, Devin doesn't know how to
verify its own work. The session produces output but no confidence.

---

### A4: Subjective Language

**Bad:** "Make it user-friendly"
**Good:** "Add error messages for all form validation failures, show loading
states for API calls, and add aria-labels to all interactive elements"

**Why it fails:** "User-friendly" is interpretive. Devin makes different
assumptions than you would. Measurable requirements eliminate ambiguity.

---

### A5: Task Dumping (Multiple Unrelated Objectives)

**Bad:** "Fix the login bug, update the docs, add tests, and deploy"
**Good:** Four separate sessions, each with one objective

**Why it fails:** Requirements and implementation pollute each other.
Devin context-switches between unrelated concerns, quality drops on all of them.

---

### A6: Overly Broad Knowledge Items

**Bad:** "This is how our entire API works" (2000 lines)
**Good:** "ADO Wiki page updates require ETag from prior GET" (80 lines)

**Why it fails:** Broad items match too many triggers, diluting relevance.
They consume context window without providing targeted value. Split into
focused items by domain.

---

### A7: Playbooks Without Deliverables

**Bad:** Steps that analyze and investigate but never produce output
**Good:** "Write JSON to `analyses/`, post comment on work item, update Wiki"

**Why it fails:** A session that produces no artifact is a session that
accomplished nothing verifiable. Every playbook must specify at least one
tangible output.

---

### A8: Neglecting Knowledge Updates

**Bad:** Knowledge items written once and never updated as the system evolves
**Good:** Update knowledge items whenever APIs, conventions, or scripts change

**Why it fails:** Stale knowledge causes Devin to follow outdated patterns.
This is worse than no knowledge — it creates false confidence.

---

### A9: Skipping Plan Review

**Bad:** Letting Devin execute immediately without reviewing its proposed approach
**Good:** Ask Devin for an implementation proposal first, review, then approve

**Why it fails:** Devin may misunderstand the objective or choose a suboptimal
approach. Reviewing the plan costs almost nothing. Re-doing work costs ACUs.

---

### A10: Over-Investing in Failing Sessions

**Bad:** Sending 20 messages trying to fix a struggling session
**Good:** Stop at 3-5 correction attempts, redesign the approach or manually intervene

**Why it fails:** More messages to a struggling agent rarely improves quality.
The root cause is usually missing context, broken tools, or scope too broad —
none of which more messages can fix. Discontinue and redesign.

---

### A11: Raw curl Instead of Scripts

**Bad:** Composing API calls from scratch with inline curl commands —
manually setting `Content-Type`, constructing auth headers, and encoding
URL parameters in each session.
**Good:** Use `scripts/ado/` for all ADO operations. Add new scripts when
a new endpoint is needed rather than writing one-off curl commands.

**Why it fails:** Content-Type errors (forgetting `application/json` vs
`application/json-patch+json`), auth mistakes (wrong PAT variable, missing
base64 encoding), and URL encoding bugs (spaces in Wiki page paths, special
characters in query parameters). Each of these wastes an entire retry cycle.
Scripts encode these details once and eliminate the class of errors entirely.

---

### A12: Ignoring Attachments

**Bad:** Processing a bug work item by reading only the title and description,
then jumping straight into code investigation without checking attachments.
**Good:** First call the work item API with `$expand=attachments`, download
each attachment, review screenshots and logs before forming any hypothesis.

**Why it fails:** Missing critical evidence. A screenshot showing the exact
UI state, a log file with the stack trace, or a HAR file capturing the
failing network request — all of these shortcut the investigation. Without
them, Devin guesses at symptoms instead of reading the diagnosis, leading
to wasted ACUs on wrong hypotheses.

---

### A13: Single PAT for Everything

**Bad:** Using one Personal Access Token with Full Access scope for all
Devin sessions and all operations (code, wiki, work items, test plans).
**Good:** Issue separate PATs per operation category with minimum required
scopes, as described in P10.

**Why it fails:** Blast radius is the entire system if the PAT leaks or
is logged accidentally. A single PAT with Full Access means a compromised
session can read code, delete Wiki pages, modify work items, and push to
repos. Separate minimum-scope PATs ensure a leak in one category cannot
affect others. Additionally, audit logs become useless when every operation
uses the same credential.

---

### A14: Hardcoded Org/Project Values

**Bad:** Embedding the organization URL (`https://dev.azure.com/myorg`) or
project name (`MyProject`) directly in scripts and playbooks as string
literals.
**Good:** Use environment variables (`$ADO_ORG`, `$ADO_PROJECT`) that are
set once in the session environment and referenced everywhere.

**Why it fails:** Breaks portability. When the organization changes, every
script with hardcoded values must be edited individually. Copy-pasting
scripts to a new project requires find-and-replace across dozens of files.
Environment variables centralize the configuration, and scripts work
across any org/project combination without modification.

---

### A15: No Exit Conditions

**Bad:** Sessions with open-ended instructions like "keep investigating
until you find the root cause" or "fix all the bugs" with no defined
stopping point.
**Good:** "Investigate for max 10 files or 3 call chains. If root cause
is not found, post findings and exit. Success: root cause identified
and documented. Failure: exit with summary after hitting limits."

**Why it fails:** Sessions run indefinitely, burning ACUs with diminishing
returns. Without explicit success and failure exit conditions, Devin has
no signal to stop. It continues exploring, re-reading the same files, or
trying variations of the same approach. Defined exits turn an unbounded
cost into a predictable one.
