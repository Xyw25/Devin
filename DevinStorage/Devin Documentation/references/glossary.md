# Glossary

> Version: 1.0.0
> Created: 2026-03-25
> Last updated: 2026-03-25

---

Alphabetical glossary of all terms used in this system.

| Term | Definition | Where Used |
|------|-----------|-----------|
| **ACU** | Agent Compute Unit. A normalized measure of resources consumed by a Devin session, including VM time, model inference, and networking bandwidth. Lower ACU means more efficient. | acu-reference.md, session-architecture.md, session-sizing-guide.md |
| **ADO** | Azure DevOps. The Microsoft platform used for work items, Wiki, test management, code repositories, and pipelines. All API operations in this system target ADO. | All guides, all scripts, patterns-and-anti-patterns.md |
| **Analysis JSON** | The structured JSON file written by Session A to `analyses/{product}/{slug}.json`. Contains models, entry points, dependencies, and metadata about the analyzed code. | session-architecture.md, playbook-writing-guide.md |
| **Area Path** | An ADO field (`System.AreaPath`) that organizes work items into a hierarchical team/component structure (e.g., `Project\Team\Component`). Used in WIQL queries with the `UNDER` operator. | patterns-and-anti-patterns.md, error-recovery-guide.md |
| **Artifact** | Any output produced by a session: analysis JSON, Wiki pages, test cases, work item comments, or relations. Artifacts flow between sessions via DevinStorage and ADO. | session-architecture.md, session-sizing-guide.md |
| **DeepWiki** | An AI-powered code understanding tool that indexes repositories and provides contextual answers. Configured via `.devin/wiki.json` to control what gets indexed. | deepwiki-guide.md, security-guide.md |
| **DevinStorage** | The Git repository used to store persistent data across Devin sessions — analysis JSON files, playbooks, knowledge items, guides, and configuration. This repository. | session-architecture.md, all guides |
| **ETag** | An HTTP header returned by ADO Wiki API on GET requests. Must be sent back as `If-Match` header on PUT requests to prevent concurrent update conflicts. Missing ETag causes 409 errors. | patterns-and-anti-patterns.md, session-architecture.md, error-recovery-guide.md |
| **Functionality** | A logical unit of behavior in the codebase, identified during analysis. Each functionality gets a Wiki page, an index entry, and associated test cases. | session-architecture.md, playbook-writing-guide.md |
| **Functionality Index** | A Wiki page (`/FunctionalityIndex`) that lists all analyzed functionalities with keywords. Used by Session D to match work items to functionalities via keyword overlap. | session-architecture.md |
| **Iteration Path** | An ADO field (`System.IterationPath`) that assigns work items to a sprint or time-based iteration. Used when creating test case work items. | patterns-and-anti-patterns.md |
| **JSON Patch** | The format required by ADO REST API for work item updates. Uses `application/json-patch+json` content type with an array of `op`/`path`/`value` objects. | patterns-and-anti-patterns.md, error-recovery-guide.md |
| **Knowledge Item** | A pre-written context file attached to Devin sessions. Reduces inference overhead by providing information Devin would otherwise need to discover. Managed via Devin's Knowledge feature. | knowledge-writing-guide.md, acu-reference.md |
| **PAT** | Personal Access Token. An authentication credential for Azure DevOps REST API. This system uses four separate PATs with minimum scopes: `ADO_PAT_WORKITEMS`, `ADO_PAT_WIKI`, `ADO_PAT_CODE`, `ADO_PAT_TESTS`. | security-guide.md, secrets-management-guide.md, session-architecture.md |
| **Playbook** | A structured set of instructions for a Devin session. Defines the session's goal, steps, constraints, and expected outputs. Stored in `playbooks/` directory. | playbook-writing-guide.md, scheduling-guide.md |
| **repo_notes** | A field in the analysis JSON that captures repository-specific context: build commands, test frameworks, naming conventions. Helps future sessions understand the codebase. | session-architecture.md |
| **Scope Hint** | A text string extracted by Session 0 from the work item description. Passed to Session D to narrow the triage search. Contains keywords, file paths, or component names. | session-architecture.md |
| **Scope Limit** | Hard constraints on Session A analysis: maximum 5 models, 10 entry points, one level of dependency depth. Prevents unbounded analysis on large codebases. | session-architecture.md, acu-reference.md |
| **Secret** | Any credential, token, or sensitive value stored in Devin Secrets Manager. Accessed via environment variables at runtime. Never hardcoded or pasted in chat. | security-guide.md, secrets-management-guide.md |
| **Session** | A single Devin execution unit with a specific purpose, budget, and set of inputs/outputs. This system uses Sessions 0, A, B, C, and D in a defined chain. | session-architecture.md, acu-reference.md |
| **Session Chain** | The sequence of sessions triggered when Session D finds no match: D -> A -> B -> C -> D. Each session produces artifacts consumed by the next. | session-architecture.md |
| **Snapshot** | A point-in-time capture of system state, typically referring to the commit SHA recorded in analysis JSON (`lastAnalyzedCommit`). Used to determine if analysis needs to be re-run. | session-architecture.md |
| **Supplement** | A partial re-analysis performed by Session A when the analysis file exists but the commit SHA has changed. Only analyzes changed areas instead of the full codebase. Uses less ACU than a full analysis. | session-architecture.md, acu-reference.md |
| **TestedBy** | An ADO work item relation type (`Microsoft.VSTS.Common.TestedBy-Forward`) that links a work item to its test cases. Created by Session C and Session D. | session-architecture.md, patterns-and-anti-patterns.md |
| **Triage** | The process performed by Session D: matching an incoming work item to an existing functionality using keyword overlap against the Functionality Index. | session-architecture.md |
| **WIQL** | Work Item Query Language. SQL-like query language for Azure DevOps work items. Used by Session D to find matching work items and test cases. Requires specific syntax for area paths and field names. | patterns-and-anti-patterns.md, error-recovery-guide.md |
| **Wiki** | Azure DevOps Wiki, used to store functionality documentation pages and the Functionality Index. Accessed via the ADO Wiki REST API with ETag-based concurrency control. | session-architecture.md, security-guide.md |
| **Work Item** | An ADO entity (Bug, User Story, Task, Test Case, etc.) that represents a unit of work. The primary input to Session 0 and the target of all linking and commenting operations. | session-architecture.md, patterns-and-anti-patterns.md |
| **devin-process tag** | The single ADO tag used to trigger the entire session chain. Session 0 checks for this tag; if absent, the session exits silently. No other tags are used for state tracking. | session-architecture.md |
| **wiki.json** | The DeepWiki configuration file at `.devin/wiki.json`. Controls which files and directories are indexed by DeepWiki. Used to exclude secrets and implementation details. | deepwiki-guide.md, security-guide.md |
