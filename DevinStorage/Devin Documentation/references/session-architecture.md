# Session Architecture Reference

> Version: 2.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25
> Sources re-verified: 2026-03-25
> Source: INTENT.md (this repository)

---

## Session Flow Diagram

```
Work item arrives with devin-process tag
         |
         v
  +--------------+
  | Session 0    |  ACU <= 1
  | Pre-check    |
  | & Router     |
  +------+-------+
         |
    +----+----+----+----+
    |         |         |
 NO TAG   CLOSED/   INSUFFICIENT
 (exit)   RESOLVED  DESCRIPTION
          (exit)       |
                    Post clarification
                    comment, exit
                       |
                   (wait for update)
                       |
                    VALID
                       |
         +-------------+
         | (scope hint)
         v
  +--------------+
  | Session D    |  ACU <= 3 (found) / <= 5 (chain)
  | Triage &     |
  | Linking      |
  +------+-------+
         |
    +----+----+
    |         |
 FOUND    NOT FOUND
    |         |
    v         v
 Link tests   +---------------------------+
 Post comment |  Session A Decision Logic  |
 Done         +---------------------------+
                       |
              +--------+--------+--------+
              |                 |        |
         No analysis      File exists  File exists
         file exists      commit==HEAD commit!=HEAD
              |                 |        |
              v                 v        v
          FULL ANALYSIS      SKIP    SUPPLEMENT
          ACU <= 5          (hand    ACU <= 3
              |              off)       |
              |                |        |
              +--------+-------+--------+
                       |
        (if scope limits hit: post comment, exit)
                       |
                       v
              +--------------+
              | Session B    |  ACU <= 3
              | Documentation|
              +------+-------+
                     |
                     v
              +--------------+
              | Session C    |  ACU <= 5
              | Test         |
              | Coverage     |
              +------+-------+
                     |
                     v
              Back to Session D
              (re-match with new data)
```

---

## Session Details

### Session 0 — Pre-check & Router

| Attribute | Value |
|-----------|-------|
| Purpose | Gate. Read work item, validate, extract scope hint, route |
| Trigger | Work item arrives |
| ACU Target | <= 1 |
| PATs | `ADO_PAT_WORKITEMS` |
| Outputs | Scope hint passed to Session D |
| Exit: no tag | Silent exit, no action |
| Exit: closed/resolved | Silent exit, no action |
| Exit: insufficient description | Post clarification comment, exit |
| Exit: valid | Route to Session D |

### Session A — Code Analysis

| Attribute | Value |
|-----------|-------|
| Purpose | Analyze codebase, write structured JSON to DevinStorage |
| Trigger | Session D no match, or commit SHA changed |
| ACU Target | <= 5 (full), <= 3 (supplement) |
| PATs | `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE` |
| Outputs | `analyses/{product}/{slug}.json`, work item comment |
| Skip condition | File exists AND lastAnalyzedCommit == HEAD |
| Supplement condition | File exists BUT HEAD moved |
| Scope limits | 5 models, 10 entry points, one level deep |
| Overflow behavior | Post comment listing findings, ask for focus, exit |

### Session B — Functionality Documentation

| Attribute | Value |
|-----------|-------|
| Purpose | Create/update Wiki page and Functionality Index |
| Trigger | Session A completes or hands off |
| ACU Target | <= 3 |
| PATs | `ADO_PAT_WIKI`, `ADO_PAT_WORKITEMS` |
| Outputs | Wiki page, Index entry, work item comment |
| Skip condition | Page exists AND no new analysis |
| Critical rule | Always GET before PUT (ETag required) |
| Always | Triggers Session C |

### Session C — Test Coverage

| Attribute | Value |
|-----------|-------|
| Purpose | Find/create tests, link to work item, update Wiki |
| Trigger | Session B completes (always) |
| ACU Target | <= 5 |
| PATs | `ADO_PAT_TESTS`, `ADO_PAT_WIKI`, `ADO_PAT_WORKITEMS`, `ADO_PAT_CODE` |
| Outputs | Test cases, TestedBy links, Wiki update, work item comment |
| Skip condition | Tests linked AND no new analysis |
| Test type | Work items of type `$Test%20Case` (not test plan resources) |

### Session D — Triage & Linking

| Attribute | Value |
|-----------|-------|
| Purpose | Match work item to functionality, link tests, post findings |
| Trigger | Session 0 routes with scope hint |
| ACU Target | <= 3 (found), <= 5 (chain triggered) |
| PATs | `ADO_PAT_WORKITEMS`, `ADO_PAT_WIKI`, `ADO_PAT_TESTS` |
| Match criteria | 2+ keyword overlap required |
| Found path | Link tests, post comment, done |
| Not found path | Trigger A -> B -> C chain, then re-match |

---

## Decision Matrix

This table defines when each session runs, skips, or supplements based on system state.

| Session | Condition | Action | ACU | Next Step |
|---------|-----------|--------|-----|-----------|
| **0** | No `devin-process` tag | Exit silently | ~0 | None |
| **0** | Work item closed/resolved | Exit silently | ~0 | None |
| **0** | Description insufficient | Post clarification comment, exit | ~0.8 | Wait for update |
| **0** | Valid work item | Extract scope hint, route | ~0.3 | Session D |
| **D** | 2+ keyword match found | Link tests, post comment | <= 3 | Done |
| **D** | No match found | Trigger analysis chain | <= 5 | Session A |
| **A** | No analysis file exists | Full analysis | <= 5 | Session B |
| **A** | File exists, commit == HEAD | Skip (hand off) | ~0.2 | Session B (skip) |
| **A** | File exists, commit != HEAD | Supplement changed areas only | <= 3 | Session B (update) |
| **A** | Scope limits hit during analysis | Post comment, exit cleanly | varies | Wait for clarification |
| **B** | No Wiki page exists | Create page + index entry | <= 3 | Session C |
| **B** | Page exists, new analysis available | Update page + index entry | <= 3 | Session C |
| **B** | Page exists, no new analysis | Skip (hand off) | ~0.2 | Session C |
| **C** | No tests linked, analysis available | Create tests, link, update Wiki | <= 5 | Session D (re-match) |
| **C** | Tests linked, no new analysis | Skip | ~0.2 | Session D (re-match) |
| **C** | Tests linked, new analysis available | Update tests, re-link | <= 5 | Session D (re-match) |

---

## Artifact Handoff Map

| Source Session | Artifact | Destination Session | How Consumed |
|---------------|----------|-------------------|-------------|
| **0** | Scope hint (text) | **D** | Passed as input parameter to Session D prompt |
| **0** | Work item comment (audit) | — | Stored on ADO work item for human review |
| **D** | Match result + scope hint | **A** | Passed as input when no match found |
| **A** | `analyses/{product}/{slug}.json` | **B** | Read from DevinStorage to generate Wiki content |
| **A** | `analyses/{product}/{slug}.json` | **C** | Read from DevinStorage to identify test targets |
| **A** | Work item comment (audit) | — | Stored on ADO work item for human review |
| **B** | Wiki page `/Functionalities/{slug}` | **C** | Read to find existing test section, append results |
| **B** | Wiki page `/Functionalities/{slug}` | **D** | Read to find functionality details for linking |
| **B** | Functionality Index entry | **D** | Read to match work item keywords against index |
| **B** | Work item comment (audit) | — | Stored on ADO work item for human review |
| **C** | ADO Test Case work items | **D** | Queried via WIQL to link to original work item |
| **C** | TestedBy-Forward relations | **D** | Read to verify test coverage linkage |
| **C** | Wiki `/Functionalities/{slug}` (tests section) | **D** | Read to find linked tests for work item |
| **C** | Work item comment (audit) | — | Stored on ADO work item for human review |
| **D** | TestedBy-Forward relations | — | Final linkage stored on ADO work item |
| **D** | Wiki `/Functionalities/{slug}` (work items table) | — | Updated for traceability |
| **D** | `analyses/{product}/{slug}.json` (workItems array) | — | Updated for reverse lookup |
| **D** | Work item comment (audit) | — | Stored on ADO work item for human review |

---

## Error Recovery Paths

| Session | Failure Type | Retry Strategy | Fallback | Escalation |
|---------|-------------|---------------|----------|------------|
| **0** | 401 Unauthorized | No retry. PAT expired. | Exit silently. | Rotate `ADO_PAT_WORKITEMS`, re-trigger. |
| **0** | 400 Bad Request | No retry. Check work item ID format. | Exit with error comment. | Fix playbook prompt, re-trigger. |
| **0** | Work item not found | No retry. | Exit silently. | Verify work item exists in ADO. |
| **D** | 401 Unauthorized | No retry. | Exit with error comment. | Rotate affected PAT (`WORKITEMS`, `WIKI`, or `TESTS`). |
| **D** | WIQL parse error | No retry. Query syntax is wrong. | Exit with error comment. | Fix WIQL query in playbook/script. |
| **D** | No match after chain | No retry. Data is insufficient. | Post comment with partial findings. | Human reviews scope, adds detail to work item. |
| **A** | 401 on code read | No retry. | Exit with error comment. | Rotate `ADO_PAT_CODE`. |
| **A** | Scope overflow (>5 models) | No retry. | Post comment listing found models, request focus. | Human narrows scope in work item description. |
| **A** | Analysis JSON write fails | Retry once (transient git issue). | Exit with error comment. | Check DevinStorage repo permissions. |
| **B** | 409 Conflict (missing ETag) | Retry: GET page first, then PUT with ETag. | Exit with error comment. | Verify Wiki page state manually. |
| **B** | Wiki page create fails | Retry once. | Exit with error comment. | Check `ADO_PAT_WIKI` scope and Wiki ID. |
| **C** | Test case creation fails | Retry once per test case. | Post comment with tests that succeeded. | Check `ADO_PAT_TESTS` scope, verify test plan exists. |
| **C** | TestedBy link fails | Retry once. | Post comment noting unlinked tests. | Manually create links in ADO. |
| **Any** | ACU exceeds 2x budget | Immediate stop. | Post comment with progress so far. | Redesign session scope, check error-catalog.md. |
| **Any** | Same error 3+ times | Immediate stop. | Post comment with error details. | Check error-catalog.md, fix root cause. |
| **Any** | No artifacts produced | N/A — session completed without output. | Post comment noting missing deliverables. | Review playbook for missing steps. |

---

## Artifact Flow (Text Diagram)

```
Session A writes  -->  analyses/{product}/{slug}.json
Session B reads   <--  analyses/{product}/{slug}.json
Session B writes  -->  Wiki /Functionalities/{slug}
Session B writes  -->  Wiki /FunctionalityIndex (entry)
Session C reads   <--  analyses/{product}/{slug}.json
Session C reads   <--  Wiki /Functionalities/{slug}
Session C writes  -->  ADO Test Case work items
Session C writes  -->  TestedBy-Forward relations
Session C writes  -->  Wiki /Functionalities/{slug} (tests section)
Session D reads   <--  Wiki /FunctionalityIndex
Session D reads   <--  Wiki /Functionalities/{slug}
Session D writes  -->  TestedBy-Forward relations
Session D writes  -->  Wiki /Functionalities/{slug} (work items table)
Session D writes  -->  analyses/{product}/{slug}.json (workItems array)

Every session writes --> Work item comment (audit trail)
```

---

## The Only Trigger Tag

**`devin-process`** — the only tag in the entire system.

- No tag = Session 0 exits immediately
- No other tags needed for state tracking
- State is self-regulating via: commit SHA checks, Wiki page existence, test linkage
