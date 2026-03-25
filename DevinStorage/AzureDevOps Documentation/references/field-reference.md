# ADO Work Item Field Reference

> Created: 2026-03-25
> API Version: 7.1

---

## System Fields (Case-Sensitive)

| Display Name | Reference Name | Type | Notes |
|---|---|---|---|
| Title | `System.Title` | String | Required on creation |
| Description | `System.Description` | HTML | Wrap plain text in `<p>` tags |
| State | `System.State` | String | Values depend on work item type |
| Reason | `System.Reason` | String | Paired with State transitions |
| Area Path | `System.AreaPath` | TreePath | Backslash separator: `Project\Area` |
| Iteration Path | `System.IterationPath` | TreePath | Backslash separator: `Project\Sprint` |
| Work Item Type | `System.WorkItemType` | String | Bug, User Story, Task, Test Case |
| Tags | `System.Tags` | String | Semicolon-separated: `tag1; tag2` |
| Assigned To | `System.AssignedTo` | Identity | Display name or email |
| Created By | `System.CreatedBy` | Identity | Read-only |
| Created Date | `System.CreatedDate` | DateTime | Read-only |
| Changed By | `System.ChangedBy` | Identity | Read-only |
| Changed Date | `System.ChangedDate` | DateTime | Read-only |
| History | `System.History` | HTML | Discussion/comment thread |

---

## Test Case Fields

| Display Name | Reference Name | Type | Notes |
|---|---|---|---|
| Steps | `Microsoft.VSTS.TCM.Steps` | HTML/XML | XML step format |
| Parameters | `Microsoft.VSTS.TCM.Parameters` | HTML | Test parameters XML |
| Automated Test Name | `Microsoft.VSTS.TCM.AutomatedTestName` | String | Linked automation |
| Automated Test Storage | `Microsoft.VSTS.TCM.AutomatedTestStorage` | String | Assembly/file |

---

## Common Custom Fields

| Display Name | Reference Name | Type |
|---|---|---|
| Priority | `Microsoft.VSTS.Common.Priority` | Integer (1-4) |
| Severity | `Microsoft.VSTS.Common.Severity` | String |
| Story Points | `Microsoft.VSTS.Scheduling.StoryPoints` | Double |
| Original Estimate | `Microsoft.VSTS.Scheduling.OriginalEstimate` | Double |
| Remaining Work | `Microsoft.VSTS.Scheduling.RemainingWork` | Double |

---

## Relation Types

| Name | Reference Name | Direction | Use Case |
|---|---|---|---|
| Tested By | `Microsoft.VSTS.Common.TestedBy-Forward` | Source -> Test Case | Link work item to its test cases |
| Tests | `Microsoft.VSTS.Common.TestedBy-Reverse` | Test Case -> Source | Reverse of TestedBy |
| Parent | `System.LinkTypes.Hierarchy-Reverse` | Child -> Parent | Parent-child hierarchy |
| Child | `System.LinkTypes.Hierarchy-Forward` | Parent -> Child | Parent-child hierarchy |
| Related | `System.LinkTypes.Related` | Bidirectional | General relationship |
| Duplicate | `System.LinkTypes.Duplicate-Forward` | Original -> Duplicate | Duplicate tracking |
| Successor | `System.LinkTypes.Dependency-Forward` | Predecessor -> Successor | Dependencies |
| Predecessor | `System.LinkTypes.Dependency-Reverse` | Successor -> Predecessor | Dependencies |

---

## State Values by Work Item Type

### Bug
| State | Allowed Transitions From |
|-------|------------------------|
| New | (initial) |
| Active | New |
| Resolved | Active |
| Closed | Resolved |

### User Story
| State | Allowed Transitions From |
|-------|------------------------|
| New | (initial) |
| Active | New |
| Resolved | Active |
| Closed | Resolved |

### Task
| State | Allowed Transitions From |
|-------|------------------------|
| New | (initial) |
| Active | New |
| Closed | Active |

### Test Case
| State | Allowed Transitions From |
|-------|------------------------|
| Design | (initial) |
| Ready | Design |
| Closed | Ready, Design |

---

## JSON Patch Operations

| Operation | Description | Example |
|-----------|-------------|---------|
| `add` | Set a field value (works for new and existing) | `{"op":"add","path":"/fields/System.Title","value":"New Title"}` |
| `replace` | Update existing field value | `{"op":"replace","path":"/fields/System.State","value":"Active"}` |
| `remove` | Clear a field value | `{"op":"remove","path":"/fields/System.AssignedTo"}` |
| `test` | Verify a field value before modifying | `{"op":"test","path":"/fields/System.State","value":"New"}` |

---

## Path Separator Rules

| Path Type | Separator | Example |
|-----------|-----------|---------|
| Area Path | Backslash `\` | `Project\Team\Area` |
| Iteration Path | Backslash `\` | `Project\Sprint 1` |
| Wiki Page Path | Forward slash `/` | `/Functionalities/user-login` |
| JSON Patch Path | Forward slash `/` | `/fields/System.Title` |
| Git Branch Ref | Forward slash `/` | `refs/heads/main` |
