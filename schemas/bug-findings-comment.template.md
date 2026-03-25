# Bug Findings Comment Template

> Produced by: Session BT (Bug Deep Triage)
> Format: HTML

---

## Template

```html
<p><b>Devin Deep Bug Triage — Findings</b></p>

<p><b>1. Functionality Match</b></p>
<p><b>Matched:</b> <a href="{wiki_url}">{functionality_name}</a>
(confidence: {high|medium|low}, {keyword_count} keyword overlap)</p>
<p><b>Keywords:</b> {matched_keywords}</p>

<p><b>2. Likely Root Cause</b></p>
<p>{description of the suspected root cause — specific files, methods, and
recent changes that may have introduced the issue}</p>
<p><b>Suspect files:</b></p>
<ul>
  <li><code>{file_path}</code> — {reason this file is suspect}</li>
  <li><code>{file_path}</code> — {reason}</li>
</ul>
<p><b>Recent changes:</b></p>
<ul>
  <li><code>{short_sha}</code> by {author} on {date} — {commit message summary}</li>
</ul>

<p><b>3. Attachment Analysis</b></p>
<p><b>Attachments reviewed:</b> {count}</p>
<ul>
  <li><b>{filename}</b> — {what it shows: error dialog, stack trace, UI state, etc.}</li>
</ul>
{if no attachments}
<p>No attachments found on this work item.</p>
{/if}

<p><b>4. Test Coverage Gap</b></p>
<p><b>Existing tests:</b> {count} test cases linked</p>
<p><b>Would existing tests catch this?</b> {Yes/No} — {explanation}</p>
<p><b>Is this a regression?</b> {Yes/No/Unknown} — {explanation}</p>

<p><b>5. Suggested Fix Location</b></p>
<ul>
  <li><code>{file_path}:{method_name}</code> — {what to change}</li>
</ul>

<p><b>6. Suggested New Tests</b></p>
<ul>
  <li>{test case title} — {what it would verify}</li>
  <li>{test case title} — {what it would verify}</li>
</ul>
```

## Rules

- All 6 sections must be present, even if a section says "No data available"
- Root cause is a **hypothesis**, not a conclusion — use "likely", "suspected"
- Attachment analysis must note what each attachment shows, not just list filenames
- Test coverage gap must explicitly state whether this is a regression
- Suggested fix locations must be specific files and methods, not vague areas
