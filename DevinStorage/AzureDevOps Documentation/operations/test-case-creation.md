# Test Case Creation — Operations Guide

> Created: 2026-03-25
> API Version: 7.1

---

## Key Concept

Test cases in Azure DevOps are **work items** of type `Test Case`.
They are created via the **work items API**, not the test plans API.

```
POST /{org}/{project}/_apis/wit/workitems/$Test%20Case?api-version=7.1
Content-Type: application/json-patch+json
```

---

## Test Steps XML Format

The `Microsoft.VSTS.TCM.Steps` field uses a specific XML format:

```xml
<steps>
  <step id="1" type="ActionStep">
    <parameterizedString isformatted="true">Navigate to the login page</parameterizedString>
    <parameterizedString isformatted="true">Login page loads with username and password fields</parameterizedString>
  </step>
  <step id="2" type="ActionStep">
    <parameterizedString isformatted="true">Enter valid username and password</parameterizedString>
    <parameterizedString isformatted="true">Credentials are accepted</parameterizedString>
  </step>
  <step id="3" type="ActionStep">
    <parameterizedString isformatted="true">Click the Sign In button</parameterizedString>
    <parameterizedString isformatted="true">User is redirected to the dashboard</parameterizedString>
  </step>
</steps>
```

### XML Structure

- `<steps>` — root element
- `<step>` — one per test step
  - `id` — sequential integer starting at 1
  - `type` — always `"ActionStep"` for standard steps
- First `<parameterizedString>` — the **action** (what to do)
- Second `<parameterizedString>` — the **expected result** (what should happen)
- `isformatted="true"` — always include this attribute

---

## Complete Example: Creating a Test Case

### Request

```bash
source scripts/ado/auth.sh "$ADO_PAT_TESTS"

TITLE="Verify order cancellation within 24 hours"
AREA_PATH="Project\\Commerce\\Orders"
STEPS='<steps><step id="1" type="ActionStep"><parameterizedString isformatted="true">Navigate to order #1234 details page</parameterizedString><parameterizedString isformatted="true">Order details page displays with Cancel button visible</parameterizedString></step><step id="2" type="ActionStep"><parameterizedString isformatted="true">Click Cancel Order button</parameterizedString><parameterizedString isformatted="true">Confirmation dialog appears asking for cancellation reason</parameterizedString></step><step id="3" type="ActionStep"><parameterizedString isformatted="true">Select reason and confirm cancellation</parameterizedString><parameterizedString isformatted="true">Order status changes to Cancelled, refund is initiated</parameterizedString></step></steps>'

bash scripts/ado/tests/create-case.sh "$TITLE" "$AREA_PATH" "$STEPS"
```

### Using the Script

```bash
bash scripts/ado/tests/create-case.sh \
  "Verify login with valid SSO credentials" \
  "Project\\Auth\\Login" \
  "<steps><step id=\"1\" type=\"ActionStep\"><parameterizedString isformatted=\"true\">Open the application URL</parameterizedString><parameterizedString isformatted=\"true\">SSO redirect occurs</parameterizedString></step><step id=\"2\" type=\"ActionStep\"><parameterizedString isformatted=\"true\">Complete SSO authentication</parameterizedString><parameterizedString isformatted=\"true\">User is logged in and sees dashboard</parameterizedString></step></steps>"
```

---

## Linking Test Cases to Work Items

After creating a test case, link it to the originating work item:

```bash
source scripts/ado/auth.sh "$ADO_PAT_WORKITEMS"

# Link test case (ID returned from create) to work item
bash scripts/ado/work-items/link-relation.sh \
  "$WORK_ITEM_ID" \
  "Microsoft.VSTS.Common.TestedBy-Forward" \
  "$TEST_CASE_ID"
```

This creates a `TestedBy` relationship visible on both work items.

---

## Test Case Writing Guidelines

### What Makes a Good Test Case

| Aspect | Guidance |
|--------|----------|
| Title | Specific: "Verify [action] when [condition]" |
| Steps | 3-8 steps, each with clear action and expected result |
| Coverage | One scenario per test case, not multiple scenarios |
| Area Path | Match the functionality's area in ADO |

### Step Writing Rules

- **Action:** Start with a verb (Navigate, Click, Enter, Select, Verify)
- **Expected Result:** Describe the observable outcome, not implementation details
- **Sequence:** Steps should be in chronological order of user actions
- **Independence:** Each step should be verifiable on its own

### Common Test Scenarios to Cover

| Category | Examples |
|----------|---------|
| Happy path | Valid input, expected flow, successful outcome |
| Invalid input | Empty fields, wrong format, boundary values |
| Authorization | Unauthorized access, expired session, wrong role |
| Edge cases | Concurrent operations, large data sets, timeout scenarios |
| Error handling | Network failure, service unavailable, malformed response |

---

## PATs Required

- `ADO_PAT_TESTS` — for reading test plans/suites
- `ADO_PAT_WORKITEMS` — for creating test case work items and linking relations
