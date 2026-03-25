# Session Architecture Reference

> Created: 2026-03-25
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
  Done    +--------------+
          | Session A    |  ACU <= 5 (full) / <= 3 (supplement)
          | Code         |
          | Analysis     |
          +------+-------+
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

## Skip / Supplement / Full Decision Matrix

| Condition | Session A Action | Triggers |
|-----------|-----------------|----------|
| No analysis file exists | Full analysis | -> B -> C |
| File exists, commit matches HEAD | Skip (hand off) | -> B (skip) -> C |
| File exists, commit differs from HEAD | Supplement changed areas | -> B (update) -> C |
| Scope limits hit during analysis | Post comment, exit cleanly | Nothing (wait for clarification) |

---

## Artifact Flow

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
