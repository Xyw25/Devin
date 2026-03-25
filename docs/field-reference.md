# Work Item Field Reference

## System Fields (Case-Sensitive)

| Display Name | Reference Name | Type | Notes |
|---|---|---|---|
| Title | `System.Title` | String | Required on creation |
| Description | `System.Description` | HTML | Wrap plain text in `<p>` tags |
| State | `System.State` | String | Values depend on work item type |
| Area Path | `System.AreaPath` | TreePath | Backslash separator: `Project\Area` |
| Iteration Path | `System.IterationPath` | TreePath | Backslash separator: `Project\Sprint` |
| Work Item Type | `System.WorkItemType` | String | Bug, User Story, Task, Test Case, etc. |
| Tags | `System.Tags` | String | Semicolon-separated: `tag1; tag2` |
| Assigned To | `System.AssignedTo` | Identity | Display name or email |
| Created By | `System.CreatedBy` | Identity | Read-only |
| Created Date | `System.CreatedDate` | DateTime | Read-only |
| Changed Date | `System.ChangedDate` | DateTime | Read-only |
| Reason | `System.Reason` | String | Paired with State transitions |

## Test Case Fields

| Display Name | Reference Name | Type | Notes |
|---|---|---|---|
| Steps | `Microsoft.VSTS.TCM.Steps` | HTML/XML | Uses XML step format |
| Parameters | `Microsoft.VSTS.TCM.Parameters` | HTML | Test parameters XML |

## Relation Types

| Name | Reference Name | Direction |
|---|---|---|
| Tested By | `Microsoft.VSTS.Common.TestedBy-Forward` | Source -> Test Case |
| Tests | `Microsoft.VSTS.Common.TestedBy-Reverse` | Test Case -> Source |
| Parent | `System.LinkTypes.Hierarchy-Reverse` | Child -> Parent |
| Child | `System.LinkTypes.Hierarchy-Forward` | Parent -> Child |
| Related | `System.LinkTypes.Related` | Bidirectional |

## Common State Values

### Bug
New, Active, Resolved, Closed

### User Story
New, Active, Resolved, Closed

### Test Case
Design, Ready, Closed
