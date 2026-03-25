# Prompt Engineering for Devin

> Version: 2.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> Sources accessed: 2026-03-25
> Sources:
> - [Devin Docs — Good vs Bad Instructions](https://docs.devin.ai/essential-guidelines/good-vs-bad-instructions)
> - [Coding Agents 101](https://devin.ai/agents101)
> - [Cognition Blog — How Cognition Uses Devin](https://cognition.ai/blog/how-cognition-uses-devin-to-build-devin)

---

## Core Principle

**Frontload everything.** Provide all context, requirements, file paths,
and success criteria in the first message. Mid-session corrections cost
more ACUs and produce worse results than upfront clarity.

---

## Anatomy of an Effective Prompt

```
[1. What to do — clear, specific objective]
[2. Where to do it — file paths, components, modules]
[3. How to verify — success criteria, test commands]
[4. What to reference — existing patterns, docs, templates]
[5. What NOT to do — constraints, forbidden approaches]
```

---

## Good vs Bad Examples

### Example 1: Bug Fix

**Bad:**
> Fix the login bug

**Good:**
> Fix the null reference in `src/auth/login.ts` line 42.
> `user.email` is undefined when the SSO token doesn't include an email claim.
> Add a null check and fall back to `user.upn` when email is missing.
> Test: run `npm test -- --grep "login"` and verify all pass.
> Don't change the SSO token parsing logic — only add the fallback.

---

### Example 2: Feature Addition

**Bad:**
> Add a user stats endpoint

**Good:**
> Add a GET `/api/users/{id}/stats` endpoint in `src/routes/users.ts`.
> Return: `{ totalOrders: number, lastLoginDate: string, accountAge: number }`.
> Follow the pattern in `src/routes/users.ts:getProfile` for auth and error handling.
> Add tests in `tests/routes/users.test.ts` covering: valid user, non-existent user, unauthorized access.
> Stats should be calculated from existing `orders` and `users` tables — no new tables.

---

### Example 3: Documentation

**Bad:**
> Make the landing page look better

**Good:**
> Update the Wiki page at `/Functionalities/user-login` to include:
> 1. The new SSO fallback flow added in PR #234
> 2. Updated user workflow steps reflecting the email -> UPN fallback
> 3. Add work item #5678 to the Associated Work Items table
> Use `scripts/ado/wiki/get-page.sh` to fetch the current page and ETag first.

---

### Example 4: Test Writing

**Bad:**
> Add more tests

**Good:**
> Create test cases for the order-cancellation functionality.
> Reference: `analyses/commerce/order-cancellation.json` for entry points and models.
> Cover: successful cancellation, cancellation of already-shipped order (should fail),
> cancellation with partial refund, concurrent cancellation attempts.
> Use `scripts/ado/tests/create-case.sh` to create each test case in ADO.
> Link all new test cases to work item #4567 via TestedBy-Forward.

---

## What to Include in Every Prompt

| Element | Why | Example |
|---------|-----|---------|
| Specific file paths | Eliminates search overhead | `src/auth/login.ts:42` |
| Success criteria | Defines "done" | "All tests pass, no lint errors" |
| Existing patterns | Prevents reinvention | "Follow pattern in `getProfile`" |
| Constraints | Prevents wrong approaches | "Don't modify the token parser" |
| Test expectations | Ensures quality | "Cover valid, invalid, and edge cases" |
| Output location | Specifies deliverable | "Write to `analyses/commerce/`" |

---

## What to Avoid in Prompts

| Avoid | Why | Instead |
|-------|-----|---------|
| "Make it better" | Subjective, unmeasurable | Specify exactly what to change |
| "User-friendly" | Interpretive | List specific UX requirements |
| "Clean up the code" | Unbounded scope | Specify which files and what changes |
| "Fix all the bugs" | Too broad | Fix one specific bug per session |
| Multiple objectives | Context switching degrades quality | One session, one objective |
| Assumed knowledge | Devin may not know your conventions | Reference docs and patterns explicitly |
| Outdated library patterns | Model knowledge cutoff | Point to current documentation |

---

## Prompt Templates

### Bug Investigation
```
Investigate the [error/behavior] in [file path].
Repro: [steps to reproduce].
Expected: [expected behavior].
Actual: [actual behavior].
Check: [relevant logs, error messages, related files].
Don't: [constraints].
Output: Post findings as a comment on work item #[ID].
```

### Code Analysis (Session A Pattern)
```
Analyze the [functionality name] functionality.
Start from: [entry point file paths].
Scope: trace calls one level deep only, max 5 models, max 10 entry points.
Write analysis to: analyses/[product]/[slug].json
Follow the JSON schema in INTENT.md.
If scope limits are hit, post a comment listing findings and ask for focus area.
```

### Documentation (Session B Pattern)
```
Create/update the Wiki page for [functionality name].
Read analysis from: analyses/[product]/[slug].json
Wiki path: /Functionalities/[slug]
Sections: Overview, User Workflow, Actions, Models, Work Items, Tests.
Always GET the page first for ETag before any PUT update.
Post a comment on work item #[ID] with the Wiki link when done.
```

---

## The Investigation-First Pattern

For complex or unfamiliar tasks, use two sessions:

**Session 1: Investigation (low ACU)**
> Investigate [the problem/area]. Read [these files]. Report findings.
> Don't make any changes — just analyze and report.

**Session 2: Implementation (higher ACU)**
> Based on the investigation in [Session 1 findings], implement [specific changes].
> [Include all specific details from the investigation].

This prevents wasted ACUs on implementation attempts based on wrong assumptions.

---

## ACU-Aware Prompting

### Signals of Wasteful Prompts
- High ACU, few messages: Devin struggled autonomously — missing context
- Many messages, low ACU: Too many corrections — improve initial prompt
- ACU exceeds 2x budget: Scope was too broad or requirements unclear

### Cost-Reducing Techniques
- Provide all context upfront (don't make Devin search for it)
- Reference specific files instead of describing them
- Set explicit ACU limits in the session
- Use playbooks for recurring tasks (tested paths are cheaper)
- Attach relevant knowledge items (reduces inference overhead)

---

## Cost-Per-Prompt Style Table

Prompt quality directly impacts how many ACUs Devin consumes. The more
context and specificity you provide, the less work Devin spends searching,
guessing, and recovering from wrong assumptions.

| Prompt Quality | Description | Estimated ACU Impact | Example |
|----------------|-------------|----------------------|---------|
| **Excellent** | All context provided: file paths, success criteria, constraints, patterns to follow, test commands | **1x budget** (baseline) | "Fix null ref in `src/auth/login.ts:42`. `user.email` is undefined when SSO token lacks email claim. Add null check, fall back to `user.upn`. Test: `npm test -- --grep login`. Don't change token parser." |
| **Good** | Most context provided, minor gaps Devin can infer from nearby code | **1.2x budget** | "Fix the null reference in `src/auth/login.ts` around the SSO handling. `user.email` can be undefined. Add a fallback. Run the login tests to verify." |
| **Adequate** | Some gaps — missing file paths or constraints, but objective is clear | **1.5x budget** | "There's a null reference error in the login flow when SSO tokens don't have email. Fix it and make sure tests pass." |
| **Poor** | Vague objective, no file paths, no constraints, no verification steps | **2-3x budget** | "Fix the login bug that happens sometimes with SSO users." |
| **Terrible** | Task dump with no context — Devin must discover everything on its own | **3-5x+ budget** | "Fix the login bug." |

**Key takeaway:** Moving from a Poor prompt to an Excellent prompt can save 50-80% of ACU
spend on a task. The 2-3 minutes spent writing a detailed prompt pays for itself immediately.

---

## Before/After Examples with ACU Measurements

### Example 1: ADO Wiki Update

**Before (Poor prompt):**
> Update the wiki page for user login.

- Devin searches for which wiki page, guesses the path, fetches wrong page first,
  doesn't know what content to add, makes multiple round trips.
- **Estimated cost: ~3.5 ACU**

**After (Excellent prompt):**
> Update the Wiki page at `/Functionalities/user-login`.
> Use `scripts/ado/wiki/get-page.sh "Functionalities/user-login"` to fetch the current page and ETag.
> Add a new row to the Associated Work Items table: `| #5678 | SSO email fallback | Bug | Resolved |`.
> Update the User Workflow section step 3 to mention the email -> UPN fallback.
> Use `scripts/ado/wiki/update-page.sh` with the ETag to push the update.

- Devin follows the exact steps, no searching required.
- **Estimated cost: ~1.2 ACU**
- **Savings: ~65%**

**What changed:** Added the exact wiki path, specified which scripts to use, described the
precise content changes, and included the ETag workflow to avoid update conflicts.

---

### Example 2: Bug Investigation

**Before (Poor prompt):**
> Figure out why orders are failing.

- Devin searches the entire codebase for "order" and "fail," reads dozens of files,
  investigates irrelevant error paths, eventually asks clarifying questions.
- **Estimated cost: ~5 ACU**

**After (Excellent prompt):**
> Investigate why orders with `status: "pending"` in the `orders` table are not
> transitioning to `"confirmed"` after payment webhook arrives.
> Start from: `src/webhooks/payment.ts` and `src/services/order-state-machine.ts`.
> Check the logs for `PaymentConfirmed` events in the last 24 hours.
> Expected: webhook triggers `confirmOrder()` which updates status.
> Don't modify any code — report findings as a comment on work item #8901.

- Devin goes directly to the right files, checks the specific code path, reports findings.
- **Estimated cost: ~1.5 ACU**
- **Savings: ~70%**

**What changed:** Named the exact symptom, provided entry-point file paths, described the
expected behavior, scoped the investigation to read-only, and specified the output location.

---

### Example 3: Test Case Creation

**Before (Poor prompt):**
> Add tests for the refund feature.

- Devin searches for refund-related code, guesses which scenarios to cover,
  writes tests in the wrong location or with the wrong testing pattern, misses edge cases.
- **Estimated cost: ~4 ACU**

**After (Excellent prompt):**
> Create test cases for the partial-refund functionality in ADO.
> Reference: `analyses/commerce/partial-refund.json` for entry points, models, and edge cases.
> Create these 4 test cases using `scripts/ado/tests/create-case.sh`:
> 1. Successful partial refund (amount < order total)
> 2. Partial refund exceeding order total (should fail with validation error)
> 3. Partial refund on already-fully-refunded order (should fail)
> 4. Concurrent partial refund requests (should handle race condition)
> Link all test cases to work item #4567 via TestedBy-Forward relation.

- Devin reads the analysis file, creates exactly 4 test cases with the right script, links them.
- **Estimated cost: ~1.5 ACU**
- **Savings: ~62%**

**What changed:** Referenced the analysis JSON for context, listed the exact test scenarios,
specified the creation script, and included the work item linkage requirement.

---

### Example 4: PR Creation

**Before (Poor prompt):**
> Create a PR for the changes.

- Devin guesses the branch name, writes a generic PR title and description,
  doesn't know which work items to link, misses required reviewers.
- **Estimated cost: ~2 ACU**

**After (Excellent prompt):**
> Create a PR from branch `feature/sso-email-fallback` to `main`.
> Title: "Add UPN fallback when SSO email claim is missing"
> Description should include:
> - Summary: Added null check in `src/auth/login.ts` to fall back to `user.upn`
> - Testing: All existing login tests pass, added 2 new test cases for UPN fallback
> - Work item: Link to #5678 with "Fixes AB#5678" in the description
> Add reviewers: @team-auth
> Set to auto-complete with squash merge.

- Devin creates the PR exactly as specified in one pass.
- **Estimated cost: ~0.8 ACU**
- **Savings: ~60%**

**What changed:** Provided the branch name, title, structured description content, work item
linkage syntax, reviewer list, and merge strategy.

---

## Prompt Complexity Tiers

Use these tiers to estimate ACU cost before starting a session, and to decide
whether a task should be split into smaller sessions.

### Tier 1: XS (<1 ACU)

**Single-step, single-API operations.**

These are the simplest tasks — one action, one output, no decisions.

Examples:
- Fetch a wiki page and report its contents
- Create a single work item with provided fields
- Run a specific test suite and report results
- Read a file and summarize its structure

Prompt pattern:
```
Do [one thing] at [exact location]. Output: [where to put result].
```

---

### Tier 2: S-M (1-3 ACU)

**Multi-step operations within one domain.**

These involve several sequential steps but stay within a single system or codebase area.

Examples:
- Fix a bug in one file and run its tests
- Create 3-5 test cases in ADO linked to a work item
- Update a wiki page with content from an analysis file
- Analyze one functionality and write the JSON output

Prompt pattern:
```
Do [objective] in [domain/system].
Steps: [ordered list of actions].
Reference: [files, patterns, scripts].
Verify: [success criteria].
```

---

### Tier 3: M-L (3-5 ACU)

**Cross-domain operations with handoffs between systems.**

These touch multiple systems (e.g., codebase + ADO + wiki) and require
coordinating outputs between them.

Examples:
- Analyze code, create ADO test cases, and update wiki page
- Investigate a bug across multiple services and post findings to ADO
- Create a PR, link work items, and update documentation

Prompt pattern:
```
Do [objective] across [system A] and [system B].
Step 1: [action in system A] -> produces [artifact].
Step 2: Use [artifact] to [action in system B].
Step 3: [verification across both systems].
Reference: [scripts, patterns, schemas for each system].
```

**Tip:** If the task naturally splits into independent phases, run them as
separate Tier 2 sessions instead. The investigation-first pattern is a
good example of this split.

---

### Tier 4: L+ (5+ ACU)

**Full analysis chains — these should almost always be split.**

Tasks at this tier involve deep analysis, multiple systems, and complex
decision-making. Running them as a single session risks context loss,
wrong assumptions compounding, and high ACU waste on recovery.

Examples:
- Full functionality analysis + wiki creation + test case creation + PR
- End-to-end feature implementation across multiple services
- Large-scale refactoring with test updates and documentation

**Split strategy:**
```
Session A (Tier 2): Analyze and produce artifacts
  -> Output: analyses/[product]/[slug].json

Session B (Tier 2): Create documentation from artifacts
  -> Input: analyses/[product]/[slug].json
  -> Output: Wiki page at /Functionalities/[slug]

Session C (Tier 2): Create test cases from artifacts
  -> Input: analyses/[product]/[slug].json
  -> Output: ADO test cases linked to work item

Session D (Tier 1): Create PR linking everything together
```

**Rule of thumb:** If you estimate a task at Tier 4, spend 5 minutes
planning the split before launching any sessions. The planning time
pays for itself in ACU savings and result quality.

---

## Context Loading Patterns

One of the most effective ways to reduce ACU cost is to point Devin at
existing artifacts instead of asking it to discover or recreate context.
These patterns show how to reference different types of stored knowledge.

### Reference DevinStorage JSON Files

Analysis files in `DevinStorage/analyses/` contain pre-computed context
about functionalities, entry points, models, and relationships.

```
Reference: Read `DevinStorage/analyses/commerce/order-cancellation.json`
for the list of entry points, models, and API routes related to order
cancellation. Use this as your starting context instead of searching
the codebase.
```

**When to use:** Any task that builds on a previously analyzed functionality.
The JSON file eliminates the need for Devin to re-analyze the codebase.

### Reference Wiki Pages

Wiki pages contain human-verified documentation. Point Devin to specific
pages to load context about workflows, architecture, or business rules.

```
Reference: Fetch the wiki page at `/Functionalities/user-login` using
`scripts/ado/wiki/get-page.sh "Functionalities/user-login"` to understand
the current login workflow before making changes.
```

**When to use:** Before modifying a feature that has existing documentation.
The wiki page gives Devin the "current state" without re-discovery.

### Reference Scripts by Path

DevinStorage scripts are tested, reliable automation. Always reference them
by exact path rather than describing what they do.

```
Use `scripts/ado/wiki/update-page.sh` to push the wiki update.
Use `scripts/ado/tests/create-case.sh` to create each test case.
Use `scripts/ado/workitems/add-comment.sh` to post the findings.
```

**When to use:** Any task that interacts with ADO. The scripts handle
authentication, error handling, and API formatting — Devin should use
them rather than making raw API calls.

### Reference Error Catalog Entries

The error catalog maps known errors to their root causes and fixes.
Point Devin to specific entries to skip redundant investigation.

```
Reference: Check `DevinStorage/error-catalog/ado-wiki-412.md` for the
known fix when wiki updates return HTTP 412 (ETag mismatch). Follow the
retry pattern described there instead of investigating from scratch.
```

**When to use:** When a task involves an area where errors have been
previously cataloged. This prevents Devin from spending ACUs rediscovering
known issues and their solutions.

### Combined Context Loading

For complex tasks, load multiple context sources in the prompt:

```
Context loading:
1. Read `analyses/commerce/partial-refund.json` for functionality map
2. Fetch wiki page `/Functionalities/partial-refund` for current docs
3. Check `error-catalog/payment-webhook-timeout.md` for known issues

Task: [your actual objective using all the loaded context]
```

**Key principle:** Every artifact you reference in the prompt is context
Devin does not need to discover on its own. Discovery is the most expensive
part of any session — eliminate it wherever possible.
