# Error Recovery Guide

> Version: 1.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25

---

## Diagnosis Flowchart

Use this text-based flowchart to quickly categorize a failed session:

```
Session failed or produced unexpected results
         |
         v
  Is ACU high (> 2x budget)?
    |              |
   YES             NO
    |              |
    v              v
  Few messages?   Many messages?
    |    |          |    |
   YES   NO        YES   NO
    |    |          |    |
    v    v          v    v
  MISSING      BAD    LOW ACU
  CONTEXT     PROMPT  + FEW MSGS
    |          +      = IDEAL
    |        ERROR     (not a
    |        LOOPS     failure)
    |          |
    v          v
  Fix:       Fix:
  Add more   Fix script
  context    or API call
  to prompt  logic
         \     /
          \   /
           v v
  Check: Did session produce artifacts?
    |              |
   YES             NO
    |              |
    v              v
  Partial        MISSING
  success —      DELIVERABLES
  review         |
  outputs        v
                Fix: Playbook
                is missing
                required steps
```

---

## Common Failure Modes

| Failure Mode | Symptoms | Root Cause | Fix |
|-------------|----------|-----------|-----|
| **401 Unauthorized** | All API calls return 401. Other PATs work fine. Session exits early. | PAT expired or revoked in Azure DevOps. | Rotate the affected PAT. Generate new PAT with same scope. Update in Devin Secrets Manager. Verify with a simple GET request. |
| **400 Bad Request** | API call returns 400. Devin may retry with same bad payload. | Wrong `Content-Type` header (must be `application/json-patch+json` for work item updates), malformed JSON body, or invalid field values. | Check the script or playbook for correct Content-Type. Validate JSON payload structure. See `error-catalog.md` for specific 400 patterns. |
| **409 Conflict** | Wiki PUT returns 409. Devin may retry but keeps failing. | Missing or stale ETag. Wiki pages require GET-then-PUT pattern with current ETag in `If-Match` header. | Always GET the page first to retrieve the current ETag. Use that ETag in the PUT request. Never cache ETags across sessions. |
| **WIQL parse error** | WIQL query returns parse error. Session D cannot find matches. | Bad query syntax — common issues: unescaped brackets in area paths, wrong field names, missing `FROM WorkItems`. | Validate WIQL syntax. Use `[System.AreaPath]` with `UNDER` operator. Test query in ADO Query Editor first. Use pre-built query scripts. |
| **Scope overflow** | Session A finds more than 5 models or 10 entry points. Posts comment and exits without completing analysis. | Codebase is too large for a single analysis pass. Work item description is too broad. | Narrow the scope. Add specific model names or file paths to the work item description. Session A will re-run with focused scope. |
| **No match in triage** | Session D completes but finds no functionality match. Triggers A->B->C chain. | Functionality not yet analyzed, or keyword overlap is below the 2-keyword threshold. | Let the chain run (this is expected behavior for new work items). If chain completes and still no match, the work item description may need more specific terminology. |
| **Git clone/pull failure** | Session A fails to access the repository. Returns permission denied or timeout. | `ADO_PAT_CODE` lacks read scope, or repository URL is incorrect, or network timeout. | Verify `ADO_PAT_CODE` has Code: Read scope. Check repository URL in session configuration. Retry if transient network issue. |
| **Test case creation 403** | Session C gets 403 when creating test cases. | `ADO_PAT_TESTS` lacks Test Management: Read & Write scope, or the test plan does not exist. | Verify PAT scope. Ensure the target test plan exists in ADO. Check Area Path and Iteration Path are valid. |
| **JSON parse error** | Session reads analysis JSON but cannot parse it. | Previous Session A wrote malformed JSON (truncated output, encoding issues). | Delete the corrupted JSON file from DevinStorage. Re-run Session A with full analysis. |
| **Rate limiting (429)** | API calls return 429 Too Many Requests. Session slows dramatically. | Too many API calls in a short window. Typically happens in Session C when creating many test cases. | Add delays between API calls in scripts. Reduce batch size. Consider splitting work across sessions. |

---

## Recovery Patterns

### For Each Failure: Immediate Action and Prevention

**401 Unauthorized**
- Immediate: Rotate PAT in Azure DevOps. Update in Devin Secrets Manager. Re-trigger the session.
- Prevention: Set calendar reminders before PAT expiration. Run weekly health check script that tests each PAT.

**400 Bad Request**
- Immediate: Check the exact error message in the API response. Compare the request payload against ADO REST API docs. Fix the script or playbook.
- Prevention: Use pre-built scripts from `scripts/ado/` that have correct headers and payload formats. Never construct API calls ad-hoc.

**409 Conflict**
- Immediate: Re-run the session. The GET-then-PUT pattern in the playbook should handle this if implemented correctly.
- Prevention: Always use the `wiki-put.sh` script which enforces GET-before-PUT. Never cache ETags. Never PUT without a fresh GET.

**WIQL Parse Error**
- Immediate: Copy the WIQL query, test it in ADO Query Editor. Fix syntax. Update the script or playbook.
- Prevention: Use parameterized WIQL templates from `scripts/ado/`. Never construct WIQL strings by concatenation.

**Scope Overflow**
- Immediate: Read Session A's comment listing the found models. Ask the work item author to narrow the scope.
- Prevention: Write specific work item descriptions that name exact files, classes, or modules. Avoid broad terms like "the entire service."

**No Match in Triage**
- Immediate: This is not a failure — it triggers the analysis chain. Wait for the chain to complete.
- Prevention: Build up the Functionality Index over time. More analyzed functionalities means more matches.

---

## When to Escalate

Stop retrying and escalate to a human when:

| Condition | Why Stop | What to Do |
|-----------|----------|-----------|
| Same error occurs 3+ times in a row | Retrying will not fix a structural issue | Check `error-catalog.md`, fix root cause in playbook or script |
| ACU exceeds 2x the session budget | Session is spiraling, quality is degrading | Stop session immediately, redesign the approach |
| PAT rotation does not fix 401 | Issue is not PAT expiration — may be permissions, org policy, or IP restriction | Check ADO organization settings, verify PAT scope manually in ADO portal |
| Scope overflow happens repeatedly for the same work item | Work item is fundamentally too broad for automated analysis | Manually split the work item into smaller, focused items |
| Analysis JSON is corrupt after 2+ re-runs | Possible environment issue (disk, encoding, git) | Check DevinStorage repo health, verify disk space, check git status |
| Wiki page updates keep conflicting | Another process or user is editing the same page concurrently | Coordinate with the team, implement a locking strategy or schedule updates |
| No artifacts after a session that consumed >3 ACU | Session ran but produced nothing useful | Review session transcript in Session Insights, identify where it went off track, rewrite the playbook |
