# Azure DevOps Test Management API Guide

> Created: 2026-03-25
> API Version: 7.1
> Source: [Azure DevOps REST API — Test](https://learn.microsoft.com/en-us/rest/api/azure-devops/test)

---

## Key Concept

**Test cases are work items** of type `Test Case`, created via the **work items API**
(`$Test%20Case`), NOT via the test plans API. They are linked to test suites
separately after creation.

---

## Endpoints

### List Test Plans

```
GET /{org}/{project}/_apis/test/plans?api-version=7.1
```

Returns all test plans in the project.

**Script:** `scripts/ado/tests/get-plans.sh`

### List Test Suites in a Plan

```
GET /{org}/{project}/_apis/test/plans/{planId}/suites?api-version=7.1
```

### List Test Cases in a Suite

```
GET /{org}/{project}/_apis/test/plans/{planId}/suites/{suiteId}/testcases?api-version=7.1
```

**Script:** `scripts/ado/tests/get-cases.sh <plan-id> <suite-id>`

### Create Test Case (Work Item)

```
POST /{org}/{project}/_apis/wit/workitems/$Test%20Case?api-version=7.1
Content-Type: application/json-patch+json
```

**Body:**
```json
[
  {
    "op": "add",
    "path": "/fields/System.Title",
    "value": "Verify login with valid credentials"
  },
  {
    "op": "add",
    "path": "/fields/System.AreaPath",
    "value": "Project\\Team\\Area"
  },
  {
    "op": "add",
    "path": "/fields/Microsoft.VSTS.TCM.Steps",
    "value": "<steps>...</steps>"
  }
]
```

**Script:** `scripts/ado/tests/create-case.sh <title> <area-path> <steps-xml>`

See [test-case-creation.md](../operations/test-case-creation.md) for the full
XML steps format with examples.

### Link Test Case to Work Item (TestedBy)

```
PATCH /{org}/{project}/_apis/wit/workitems/{workItemId}?api-version=7.1
Content-Type: application/json-patch+json
```

**Body:**
```json
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

**Script:** `scripts/ado/work-items/link-relation.sh <source-id> "Microsoft.VSTS.Common.TestedBy-Forward" <test-case-id>`

---

## Test Case Fields

| Field | Reference Name | Description |
|-------|---------------|-------------|
| Title | `System.Title` | Test case name |
| Area Path | `System.AreaPath` | Uses backslash separator |
| Steps | `Microsoft.VSTS.TCM.Steps` | XML format (see operations guide) |
| Parameters | `Microsoft.VSTS.TCM.Parameters` | Test parameters XML |

## Test Case States

| State | Meaning |
|-------|---------|
| Design | Being authored |
| Ready | Ready for execution |
| Closed | No longer active |

---

## Relation Types for Testing

| Relation | Reference Name | Direction |
|----------|---------------|-----------|
| Tested By | `Microsoft.VSTS.Common.TestedBy-Forward` | Work Item -> Test Case |
| Tests | `Microsoft.VSTS.Common.TestedBy-Reverse` | Test Case -> Work Item |

---

## PAT Required

`ADO_PAT_TESTS` — Test Management: Read & Write
`ADO_PAT_WORKITEMS` — Work Items: Read & Write (for creating test case work items and linking)
