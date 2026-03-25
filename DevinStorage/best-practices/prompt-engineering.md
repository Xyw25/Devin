# Prompt Engineering for Devin

> Created: 2026-03-25
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
