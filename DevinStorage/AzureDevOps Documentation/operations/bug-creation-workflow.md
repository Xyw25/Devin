# Bug Creation with Reproduction Steps

> Created: 2026-03-25

## Overview

Creating a Bug work item with well-formatted reproduction steps requires using HTML in the `Microsoft.VSTS.TCM.ReproSteps` field. Plain text will render without structure in the Azure DevOps UI.

## Create a Bug Work Item

**PATCH** `{ADO_ORG_URL}/{ADO_PROJECT}/_apis/wit/workitems/$Bug?api-version=7.1`

```bash
curl -s -X PATCH \
  -u ":${ADO_PAT_CODE}" \
  -H "Content-Type: application/json-patch+json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/\$Bug?api-version=7.1" \
  -d "[
    {
      \"op\": \"add\",
      \"path\": \"/fields/System.Title\",
      \"value\": \"${BUG_TITLE}\"
    },
    {
      \"op\": \"add\",
      \"path\": \"/fields/Microsoft.VSTS.TCM.ReproSteps\",
      \"value\": \"${REPRO_STEPS_HTML}\"
    },
    {
      \"op\": \"add\",
      \"path\": \"/fields/Microsoft.VSTS.Common.Severity\",
      \"value\": \"${SEVERITY}\"
    },
    {
      \"op\": \"add\",
      \"path\": \"/fields/Microsoft.VSTS.Common.Priority\",
      \"value\": ${PRIORITY}
    },
    {
      \"op\": \"add\",
      \"path\": \"/fields/System.AreaPath\",
      \"value\": \"${AREA_PATH}\"
    },
    {
      \"op\": \"add\",
      \"path\": \"/fields/System.IterationPath\",
      \"value\": \"${ITERATION_PATH}\"
    }
  ]"
```

## HTML Formatting for ReproSteps

The `ReproSteps` field expects HTML content. Use structured HTML for readability.

### Numbered Steps with Expected/Actual Results

```html
<h3>Steps to Reproduce</h3>
<ol>
  <li>Navigate to the login page at <code>/auth/login</code></li>
  <li>Enter a valid email address in the username field</li>
  <li>Enter an incorrect password</li>
  <li>Click the <b>Sign In</b> button</li>
</ol>

<h3>Expected Result</h3>
<p>An error message is displayed: "Invalid credentials. Please try again."</p>

<h3>Actual Result</h3>
<p>The page returns a 500 Internal Server Error with a stack trace visible to the user.</p>

<h3>Screenshots</h3>
<p>See attached screenshot <i>error-500-login.png</i> showing the stack trace.</p>
```

### Referencing Attached Screenshots

After uploading screenshots using the attachments API (see `attachment-workflow.md`), reference them in the HTML:

```html
<p>See attached: <a href="${ATTACHMENT_URL}">error-screenshot.png</a></p>
```

## Setting Severity and Priority

### Severity

Severity describes the impact of the bug. Valid values (strings):
- `1 - Critical` — System down, data loss, no workaround
- `2 - High` — Major feature broken, workaround exists
- `3 - Medium` — Minor feature broken, easy workaround
- `4 - Low` — Cosmetic issue, minimal impact

### Priority

Priority is a numeric value indicating urgency:
- `1` — Fix immediately
- `2` — Fix soon
- `3` — Fix if time permits
- `4` — Low priority

Note: Priority is an **integer**, not a string. Do not wrap it in quotes in the JSON Patch payload.

## Setting Area Path and Iteration

Area Path and Iteration Path organize work items within the project hierarchy.

```json
{
  "op": "add",
  "path": "/fields/System.AreaPath",
  "value": "MyProject\\Team Alpha\\Backend"
}
```

Use double backslashes (`\\`) in JSON to represent the path separator.

## Linking Related Work Items

Add a link to a related work item (e.g., a User Story this bug affects):

```bash
curl -s -X PATCH \
  -u ":${ADO_PAT_CODE}" \
  -H "Content-Type: application/json-patch+json" \
  "${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${BUG_ID}?api-version=7.1" \
  -d "[
    {
      \"op\": \"add\",
      \"path\": \"/relations/-\",
      \"value\": {
        \"rel\": \"System.LinkTypes.Related\",
        \"url\": \"${ADO_ORG_URL}/${ADO_PROJECT}/_apis/wit/workitems/${RELATED_ID}\",
        \"attributes\": {
          \"comment\": \"Related user story\"
        }
      }
    }
  ]"
```

Common relation types:
- `System.LinkTypes.Related` — Related work item
- `System.LinkTypes.Hierarchy-Forward` — Child link
- `System.LinkTypes.Hierarchy-Reverse` — Parent link
- `System.LinkTypes.Duplicate-Forward` — Duplicate of

## Common Mistakes

1. **Plain text in ReproSteps.** The `Microsoft.VSTS.TCM.ReproSteps` field must contain HTML. Plain text renders as a single unformatted block without line breaks or structure.
2. **Wrong severity format.** Severity must be the full string including the number prefix, e.g. `"2 - High"`, not just `"High"` or `2`.
3. **Priority as a string.** Priority is an integer field. Using `"1"` (string) instead of `1` (number) will cause a 400 error.
4. **Single backslash in Area/Iteration paths.** JSON requires double backslashes for the path separator. `"MyProject\\Team"` is correct; `"MyProject\Team"` is not.
5. **Forgetting to escape HTML in shell variables.** When building `REPRO_STEPS_HTML` in bash, ensure angle brackets and quotes are properly escaped for the JSON payload.
6. **Using `$Bug` without escaping.** In bash, the `$` in `$Bug` will be interpreted as a variable. Use `\$Bug` or single-quote the URL.
