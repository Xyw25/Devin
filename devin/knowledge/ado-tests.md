# ADO Test Management — Knowledge Item

## Trigger Description
ADO test cases as work items, test plans, suites, step XML format

## Key Concept

**Test cases are work items** of type `Test Case`, created via the work items API
(`$Test%20Case`), NOT via the test plans API. They are linked to test suites
separately after creation.

> **Note:** `$Test%20Case` is URL encoding for the "Test Case" work item type.
> The `$` prefix is how ADO identifies work item types in the URL path, and
> `%20` encodes the space character.

## API Endpoints

- **Test Plans:** `GET /_apis/test/plans?api-version=7.1`
- **Test Suites in a Plan:** `GET /_apis/test/plans/{planId}/suites?api-version=7.1`
- **Test Cases in a Suite:** `GET /_apis/test/plans/{planId}/suites/{suiteId}/testcases?api-version=7.1`
- **Create a Test Case:** See `scripts/ado/tests/create-case.sh` for the full payload format.

## Linking Tests to Work Items

Use the `TestedBy-Forward` relation to link a test case to a work item.
See `scripts/ado/work-items/link-relation.sh` for the relation payload format.

## Test Steps Format

The `Microsoft.VSTS.TCM.Steps` field uses XML:
```xml
<steps>
  <step id="1" type="ActionStep">
    <parameterizedString isformatted="true">Action description</parameterizedString>
    <parameterizedString isformatted="true">Expected result</parameterizedString>
  </step>
  <step id="2" type="ActionStep">
    <parameterizedString isformatted="true">Next action</parameterizedString>
    <parameterizedString isformatted="true">Expected result</parameterizedString>
  </step>
</steps>
```

## Rules

- Test cases are created as work items, not through the test plans API
- Use `Content-Type: application/json-patch+json` when creating test case work items
- Steps XML must use `parameterizedString` elements with `isformatted="true"`
- Each step needs a unique sequential `id` attribute
- Link test cases to parent work items using `TestedBy-Forward` relation

## Example Create Payload

The minimum JSON Patch body to create a test case:
```json
[
  {"op": "add", "path": "/fields/System.Title", "value": "Verify login succeeds with valid credentials"},
  {"op": "add", "path": "/fields/System.AreaPath", "value": "Project\\Team\\Area"},
  {"op": "add", "path": "/fields/Microsoft.VSTS.TCM.Steps", "value": "<steps><step id=\"1\" type=\"ActionStep\"><parameterizedString isformatted=\"true\">Enter valid credentials and click Login</parameterizedString><parameterizedString isformatted=\"true\">User is redirected to dashboard</parameterizedString></step></steps>"}
]
```

## Scripts

- `scripts/ado/tests/get-plans.sh` — GET all test plans in the project
- `scripts/ado/tests/get-cases.sh` — GET test cases in a specific suite
- `scripts/ado/tests/create-case.sh` — POST new test case work item
- `scripts/ado/tests/get-case-detail.sh` — GET full test case details including steps XML
