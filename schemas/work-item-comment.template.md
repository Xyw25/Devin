# Work Item Comment Templates

> Produced by: All sessions
> Format: HTML (ADO comments use HTML, not markdown)

---

## Session 0 — Clarification Request

```html
<p><b>Devin Pre-check:</b> This work item needs a more detailed description
before processing can begin.</p>
<p>Current description is {word_count} words (minimum: 20 words).</p>
<p>Please add specific details about the expected behavior, steps to reproduce,
or requirements, then re-tag with <code>devin-process</code>.</p>
```

## Session A — Analysis Complete

```html
<p><b>Devin Code Analysis Complete</b></p>
<p><b>Functionality:</b> {functionality_name}</p>
<p><b>Analysis file:</b> <code>analyses/{product}/{slug}.json</code></p>
<p><b>Entry points found:</b> {count}</p>
<p><b>Models identified:</b> {model_list}</p>
<p><b>Commit analyzed:</b> <code>{short_sha}</code></p>
<p>Next: Documentation (Session B) will create/update the Wiki page.</p>
```

## Session A — Scope Limit Hit

```html
<p><b>Devin Code Analysis — Scope Limit Reached</b></p>
<p>Analysis found {count} {models|entry points}, exceeding the
{5 models|10 entry points} limit.</p>
<p><b>Found so far:</b></p>
<ul>
  <li>{item 1}</li>
  <li>{item 2}</li>
  <li>...</li>
</ul>
<p>Which aspect should I focus on? Please reply and I will re-run
with a narrower scope.</p>
```

## Session B — Documentation Complete

```html
<p><b>Devin Documentation Complete</b></p>
<p><b>Wiki page:</b> <a href="{wiki_url}">/Functionalities/{slug}</a></p>
<p><b>Index:</b> Updated entry in <a href="{index_url}">Functionality Index</a></p>
<p>Next: Test Coverage (Session C) will evaluate and create test cases.</p>
```

## Session C — Test Coverage Complete

```html
<p><b>Devin Test Coverage Assessment</b></p>
<p><b>Existing tests found:</b> {count}</p>
<p><b>New tests created:</b> {count}</p>
<p><b>Tests linked (TestedBy):</b> {total_count}</p>
<p><b>Coverage assessment:</b> {Adequate|Gaps identified}</p>
{if gaps}
<p><b>Gaps:</b></p>
<ul>
  <li>{gap description 1}</li>
  <li>{gap description 2}</li>
</ul>
{/if}
<p><b>Should existing tests have caught this?</b> {Yes/No — explanation}</p>
```

## Session D — Triage Complete (Match Found)

```html
<p><b>Devin Triage Complete</b></p>
<p><b>Matched functionality:</b> <a href="{wiki_url}">{functionality_name}</a>
({keyword_overlap_count} keyword overlap)</p>
<p><b>Tests linked:</b> {count} test cases via TestedBy</p>
<p><b>Coverage status:</b> {status from Wiki page}</p>
<p><b>Keywords matched:</b> {keyword1, keyword2, ...}</p>
```

## Session D — Triage (No Match)

```html
<p><b>Devin Triage — No Functionality Match</b></p>
<p>Could not match this work item to a known functionality
(minimum 2 keyword overlap required).</p>
<p><b>Closest partial matches:</b></p>
<ul>
  <li>{functionality_name} — {overlap_count} keyword(s): {keywords}</li>
</ul>
<p>Triggering full analysis chain (Sessions A → B → C) to build
documentation for this area.</p>
```

## Rules

- All comments use HTML, not markdown (ADO renders HTML in comments)
- Wrap all text in `<p>` tags
- Use `<code>` for file paths, SHAs, and technical identifiers
- Use `<a href>` for Wiki and work item links
- Use `<b>` for labels, not `<strong>`
- Use `<ul><li>` for lists
- Every session posts exactly one comment at the end
