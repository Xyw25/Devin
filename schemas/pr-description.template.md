# PR Description Template

> Produced by: Session PR (PR Creation)
> Format: Markdown (ADO PR descriptions render markdown)

---

## Template

```markdown
## Summary

{2-3 sentence description of what this PR does and why.}

## Work Item

Resolves #{work_item_id} — {work_item_title}

## Functionality Context

**Area:** [{functionality_name}]({wiki_page_url})
**User Workflow Impact:** {which step(s) in the user workflow are affected}

## Changes

- {file_path} — {what was changed and why}
- {file_path} — {what was changed and why}

## Test Coverage

**Existing tests:** {count} test cases linked to this functionality
**Coverage status:** {from analysis JSON or Wiki page}
**New tests needed:** {Yes/No — brief explanation}

## Verification

- [ ] {How to verify this change works}
- [ ] {Edge case to check}
```

## Rules

- Summary must explain the "why", not just the "what"
- Work Item link uses `#ID` format which ADO auto-links
- Functionality Context pulled from Wiki page (Session B output)
- Test Coverage pulled from analysis JSON (Session C output)
- Keep PR descriptions under 4000 characters (ADO truncation limit)
- Never include credentials, PATs, or secret values
