# ADO Test Management — Knowledge Item

## Key Concept

**Test cases are work items** of type `Test Case`, created via the work items API
(`$Test%20Case`), NOT via the test plans API. They are linked to test suites
separately after creation.

## API Endpoints

### Test Plans
```
GET /{org}/{project}/_apis/test/plans?api-version=7.1
```

### Test Suites in a Plan
```
GET /{org}/{project}/_apis/test/plans/{planId}/suites?api-version=7.1
```

### Test Cases in a Suite
```
GET /{org}/{project}/_apis/test/plans/{planId}/suites/{suiteId}/testcases?api-version=7.1
```

### Create a Test Case (Work Item)
```
POST /{org}/{project}/_apis/wit/workitems/$Test%20Case?api-version=7.1
Content-Type: application/json-patch+json
[
  {
    "op": "add",
    "path": "/fields/System.Title",
    "value": "Test case title"
  },
  {
    "op": "add",
    "path": "/fields/System.AreaPath",
    "value": "Project\\Area"
  },
  {
    "op": "add",
    "path": "/fields/Microsoft.VSTS.TCM.Steps",
    "value": "<steps><step id='1' type='ActionStep'><parameterizedString isformatted='true'>Step action</parameterizedString><parameterizedString isformatted='true'>Expected result</parameterizedString></step></steps>"
  }
]
```

## Linking Tests to Work Items

Use the `TestedBy-Forward` relation to link a test case to a work item:
```
PATCH /{org}/{project}/_apis/wit/workitems/{workItemId}?api-version=7.1
Content-Type: application/json-patch+json
[
  {
    "op": "add",
    "path": "/relations/-",
    "value": {
      "rel": "Microsoft.VSTS.Common.TestedBy-Forward",
      "url": "{org_url}/{project}/_apis/wit/workitems/{testCaseId}",
      "attributes": {
        "comment": "Linked by Devin automation"
      }
    }
  }
]
```

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

## Scripts

- `scripts/ado/tests/get-plans.sh` — GET test plans
- `scripts/ado/tests/get-cases.sh` — GET test cases in a suite
- `scripts/ado/tests/create-case.sh` — POST new test case work item
