# Devin System Architecture Diagrams

> Generated: 2026-03-26
> Format: Mermaid (renders on GitHub)

---

## 1. Session Pipeline Flow

The core session chain showing how work items flow through the system.

```mermaid
flowchart TD
    WI["🏷️ Work Item<br/>tagged devin-process"] --> S0

    subgraph Gate
        S0["Session 0<br/>Pre-check & Router"]
    end

    S0 -->|"no tag / closed"| EXIT0["Silent Exit"]
    S0 -->|"description < 20 words"| CLARIFY["Post Clarification<br/>Comment & Exit"]
    S0 -->|"valid → scope hint"| SD

    subgraph Triage
        SD["Session D<br/>Triage & Linking"]
    end

    SD -->|"2+ keyword match"| FOUND["Match Found"]
    SD -->|"< 2 keywords<br/>(max 1 chain attempt)"| CHAIN

    FOUND --> LINK["Link Tests<br/>Update Wiki<br/>Post Comment"]
    LINK --> DONE["✅ Done"]

    subgraph CHAIN["Analysis Chain (triggered once)"]
        direction TB
        SA["Session A<br/>Code Analysis"] -->|"analysis JSON"| SB
        SB["Session B<br/>Documentation"] -->|"Wiki page"| SC
        SC["Session C<br/>Test Coverage"]
    end

    CHAIN -->|"re-match with<br/>new keywords"| SD

    SC --> DONE2["✅ Chain Complete"]

    style S0 fill:#4a9eff,color:#fff
    style SD fill:#ff9f43,color:#fff
    style SA fill:#ee5a24,color:#fff
    style SB fill:#6ab04c,color:#fff
    style SC fill:#9b59b6,color:#fff
    style DONE fill:#2ecc71,color:#fff
    style DONE2 fill:#2ecc71,color:#fff
    style EXIT0 fill:#95a5a6,color:#fff
    style CLARIFY fill:#f39c12,color:#fff
```

---

## 2. All Sessions Overview

Every session in the system with their relationships.

```mermaid
flowchart LR
    subgraph Core["Core Pipeline"]
        direction TB
        S0["0: Pre-check"] --> SD["D: Triage"]
        SD -.->|"no match"| SA["A: Analysis"]
        SA --> SB["B: Documentation"]
        SB --> SC["C: Test Coverage"]
    end

    subgraph OnDemand["On-Demand Sessions"]
        direction TB
        SPR["PR: PR Creation"]
        SBT["BT: Bug Deep Triage"]
        SATT["ATT: Attachment Handler"]
    end

    subgraph Scheduled["Scheduled"]
        SDM["Doc-Monitor<br/>Daily 9am UTC"]
    end

    WI["Work Item"] --> S0
    IMPL["Implementation Done"] --> SPR
    COMPLEX["Complex Bug"] --> SBT
    FILES["Attachment Ops"] --> SATT

    style Core fill:#f0f4ff,stroke:#4a9eff
    style OnDemand fill:#fff4f0,stroke:#ff9f43
    style Scheduled fill:#f0fff4,stroke:#6ab04c
```

---

## 3. Artifact Data Flow

How data moves between sessions through persistent artifacts.

```mermaid
flowchart TD
    subgraph Inputs["External Inputs"]
        WI["ADO Work Item"]
        REPO["Source Repository"]
    end

    subgraph SessionA["Session A"]
        A_READ["Read work item<br/>+ codebase"]
        A_WRITE["Write analysis JSON"]
    end

    subgraph SessionB["Session B"]
        B_READ["Read analysis JSON"]
        B_WRITE["Create/Update<br/>Wiki Page + Index"]
    end

    subgraph SessionC["Session C"]
        C_READ["Read analysis JSON<br/>+ Wiki page"]
        C_WRITE["Create test cases<br/>+ Link TestedBy<br/>+ Update Wiki Tests"]
    end

    subgraph SessionD["Session D"]
        D_READ["Read Wiki Index<br/>+ Analysis JSONs"]
        D_WRITE["Link tests<br/>+ Update Wiki<br/>+ Update JSON"]
    end

    subgraph Artifacts["Persistent Artifacts"]
        JSON["📄 analyses/{product}/{slug}.json"]
        WIKI_PAGE["📝 Wiki /Functionalities/{slug}"]
        WIKI_INDEX["📋 Wiki /FunctionalityIndex"]
        TESTS["🧪 ADO Test Cases"]
        COMMENTS["💬 Work Item Comments"]
    end

    WI --> A_READ
    REPO --> A_READ
    A_READ --> A_WRITE
    A_WRITE --> JSON

    JSON --> B_READ
    B_READ --> B_WRITE
    B_WRITE --> WIKI_PAGE
    B_WRITE --> WIKI_INDEX

    JSON --> C_READ
    WIKI_PAGE --> C_READ
    C_READ --> C_WRITE
    C_WRITE --> TESTS
    C_WRITE --> WIKI_PAGE
    C_WRITE --> WIKI_INDEX

    WIKI_INDEX --> D_READ
    JSON --> D_READ
    D_READ --> D_WRITE
    D_WRITE --> TESTS
    D_WRITE --> WIKI_PAGE
    D_WRITE --> JSON

    A_WRITE --> COMMENTS
    B_WRITE --> COMMENTS
    C_WRITE --> COMMENTS
    D_WRITE --> COMMENTS

    style JSON fill:#ffeaa7
    style WIKI_PAGE fill:#81ecec
    style WIKI_INDEX fill:#74b9ff
    style TESTS fill:#dfe6e9
    style COMMENTS fill:#fab1a0
```

---

## 4. Script Library Map

All 28 ADO scripts organized by domain.

```mermaid
flowchart TD
    AUTH["🔑 auth.sh<br/>PAT → Base64 Header"]

    subgraph WI["Work Items (11 scripts)"]
        direction LR
        WI_GET["get.sh"]
        WI_CREATE["create.sh"]
        WI_UPDATE["update.sh"]
        WI_COMMENT["comment.sh"]
        WI_LINK["link-relation.sh"]
        WI_BUG["create-bug.sh"]
        WI_ATTACH_LIST["get-attachments.sh"]
        WI_ATTACH_DL["download-attachment.sh"]
        WI_ATTACH_UP["add-attachment.sh"]
        WI_QUERY["query.sh"]
        WI_COMMENTS["get-comments.sh"]
    end

    subgraph WIKI["Wiki (3 scripts)"]
        direction LR
        WIKI_GET["get-page.sh<br/>+ ETag capture"]
        WIKI_CREATE["create-page.sh"]
        WIKI_UPDATE["update-page.sh<br/>+ ETag retry"]
    end

    subgraph PR["Pull Requests (6 scripts)"]
        direction LR
        PR_CREATE["create.sh"]
        PR_UPDATE["update.sh"]
        PR_REVIEWER["add-reviewer.sh"]
        PR_COMMENT["add-comment.sh"]
        PR_LINK_WI["link-work-item.sh"]
        PR_GET["get.sh"]
    end

    subgraph TEST["Tests (4 scripts)"]
        direction LR
        TEST_PLANS["get-plans.sh"]
        TEST_CASES["get-cases.sh"]
        TEST_CREATE["create-case.sh"]
        TEST_DETAIL["get-case-detail.sh"]
    end

    subgraph REPOS["Repos (3 scripts)"]
        direction LR
        REPO_LIST["list.sh"]
        REPO_GET["get.sh"]
        REPO_CLONE["clone.sh<br/>+ PAT sanitize"]
    end

    AUTH -->|"ADO_PAT_WORKITEMS"| WI
    AUTH -->|"ADO_PAT_WIKI"| WIKI
    AUTH -->|"ADO_PAT_CODE"| PR
    AUTH -->|"ADO_PAT_CODE"| REPOS
    AUTH -->|"ADO_PAT_TESTS"| TEST

    style AUTH fill:#e74c3c,color:#fff
    style WI fill:#3498db,color:#fff
    style WIKI fill:#2ecc71,color:#fff
    style PR fill:#9b59b6,color:#fff
    style TEST fill:#f39c12,color:#fff
    style REPOS fill:#1abc9c,color:#fff
```

---

## 5. Session → Script Usage Matrix

Which sessions use which script domains.

```mermaid
flowchart LR
    subgraph Sessions
        S0["0: Pre-check"]
        SA["A: Analysis"]
        SB["B: Documentation"]
        SC["C: Test Coverage"]
        SD["D: Triage"]
        SPR["PR: Creation"]
        SBT["BT: Bug Triage"]
        SATT["ATT: Attachments"]
    end

    subgraph Scripts
        WI["Work Items"]
        WIKI["Wiki"]
        PR["Pull Requests"]
        TEST["Tests"]
        REPO["Repos"]
    end

    S0 --> WI
    SA --> WI
    SB --> WI
    SB --> WIKI
    SC --> WI
    SC --> WIKI
    SC --> TEST
    SD --> WI
    SD --> WIKI
    SD --> TEST
    SPR --> WI
    SPR --> WIKI
    SPR --> PR
    SPR --> REPO
    SBT --> WI
    SBT --> WIKI
    SBT --> TEST
    SATT --> WI

    style WI fill:#3498db,color:#fff
    style WIKI fill:#2ecc71,color:#fff
    style PR fill:#9b59b6,color:#fff
    style TEST fill:#f39c12,color:#fff
    style REPO fill:#1abc9c,color:#fff
```

---

## 6. Knowledge Items & Trigger Map

How knowledge items map to script domains and sessions.

```mermaid
flowchart TD
    subgraph Knowledge["Knowledge Items (12)"]
        K_AUTH["ado-auth<br/><i>PAT, Base64, scopes</i>"]
        K_WI["ado-work-items<br/><i>Fields, JSON Patch, relations</i>"]
        K_WIKI["ado-wiki<br/><i>ETag, page CRUD</i>"]
        K_PR["ado-pull-requests<br/><i>Create, reviewers, merge</i>"]
        K_TEST["ado-tests<br/><i>Cases as work items, XML</i>"]
        K_ERR["ado-error-handling<br/><i>HTTP status, recovery</i>"]
        K_ATTACH["ado-attachments<br/><i>2-step upload</i>"]
        K_QUERY["ado-queries<br/><i>WIQL syntax</i>"]
        K_REPO["ado-repos<br/><i>ID lookup, clone URL</i>"]
        K_PRC["ado-pr-comments<br/><i>Thread model, inline</i>"]
        K_ENV["environment<br/><i>Org URL, PAT scopes</i>"]
        K_KW["keyword-extraction<br/><i>Triage algorithm</i>"]
    end

    subgraph Domains["Script Domains"]
        D_WI["work-items/ (11)"]
        D_WIKI["wiki/ (3)"]
        D_PR["pull-requests/ (6)"]
        D_TEST["tests/ (4)"]
        D_REPO["repos/ (3)"]
    end

    K_AUTH --> D_WI & D_WIKI & D_PR & D_TEST & D_REPO
    K_WI --> D_WI
    K_WIKI --> D_WIKI
    K_PR --> D_PR
    K_TEST --> D_TEST
    K_ATTACH --> D_WI
    K_QUERY --> D_WI
    K_REPO --> D_REPO
    K_PRC --> D_PR
    K_ERR -.->|"all domains"| D_WI & D_WIKI & D_PR & D_TEST & D_REPO
    K_ENV -.->|"all domains"| D_WI & D_WIKI & D_PR & D_TEST & D_REPO

    style Knowledge fill:#fff3e0
    style Domains fill:#e3f2fd
```

---

## 7. Output Schema Flow

Which sessions produce which artifacts using which schema definitions.

```mermaid
flowchart LR
    subgraph Schemas["schemas/"]
        SCH_JSON["analysis-json<br/>.schema.md"]
        SCH_WIKI["wiki-functionality-page<br/>.template.md"]
        SCH_INDEX["wiki-functionality-index-row<br/>.template.md"]
        SCH_COMMENT["work-item-comment<br/>.template.md"]
        SCH_BUG["bug-findings-comment<br/>.template.md"]
        SCH_PR["pr-description<br/>.template.md"]
    end

    subgraph Producers["Producing Sessions"]
        SA["Session A"]
        SB["Session B"]
        ALL["All Sessions"]
        SBT["Session BT"]
        SPR["Session PR"]
    end

    subgraph Artifacts["Output Artifacts"]
        A_JSON["analyses/*.json"]
        A_WIKI["Wiki Pages"]
        A_INDEX["Wiki Index Row"]
        A_COMMENT["WI Comments"]
        A_BUG["Bug Findings"]
        A_PR["PR Description"]
    end

    SA -->|"produces"| A_JSON
    SB -->|"produces"| A_WIKI
    SB -->|"produces"| A_INDEX
    ALL -->|"produces"| A_COMMENT
    SBT -->|"produces"| A_BUG
    SPR -->|"produces"| A_PR

    SCH_JSON -.->|"defines format"| A_JSON
    SCH_WIKI -.->|"defines format"| A_WIKI
    SCH_INDEX -.->|"defines format"| A_INDEX
    SCH_COMMENT -.->|"defines format"| A_COMMENT
    SCH_BUG -.->|"defines format"| A_BUG
    SCH_PR -.->|"defines format"| A_PR

    style Schemas fill:#fdf2e9
    style Producers fill:#eaf2f8
    style Artifacts fill:#e8f8f5
```

---

## 8. PAT Security Model

How credentials are compartmentalized across operations.

```mermaid
flowchart TD
    SM["Devin Secrets Manager"]

    SM --> PAT_WI["ADO_PAT_WORKITEMS<br/>Work Items: R&W"]
    SM --> PAT_WIKI["ADO_PAT_WIKI<br/>Wiki: R&W"]
    SM --> PAT_CODE["ADO_PAT_CODE<br/>Code: Read"]
    SM --> PAT_TEST["ADO_PAT_TESTS<br/>Test Mgmt: R&W"]

    PAT_WI --> WI_OPS["Work Item CRUD<br/>Comments<br/>Relations<br/>Attachments<br/>WIQL Queries"]
    PAT_WIKI --> WIKI_OPS["Wiki Page CRUD<br/>ETag Workflow"]
    PAT_CODE --> CODE_OPS["PR Create/Update<br/>Add Reviewer<br/>PR Comments<br/>Repo List/Get/Clone"]
    PAT_TEST --> TEST_OPS["Test Plans<br/>Test Suites<br/>Test Cases (read)"]

    subgraph Sessions Using
        S_ALL["0, A, B, C, D, PR, BT, ATT"]
        S_WIKI["B, C, D, BT"]
        S_CODE["A, PR, BT"]
        S_TEST["C, D, BT"]
    end

    WI_OPS --> S_ALL
    WIKI_OPS --> S_WIKI
    CODE_OPS --> S_CODE
    TEST_OPS --> S_TEST

    style SM fill:#e74c3c,color:#fff
    style PAT_WI fill:#3498db,color:#fff
    style PAT_WIKI fill:#2ecc71,color:#fff
    style PAT_CODE fill:#9b59b6,color:#fff
    style PAT_TEST fill:#f39c12,color:#fff
```

---

## 9. Documentation Structure

The complete repository file organization.

```mermaid
flowchart TD
    ROOT["📁 Devin Repo"]

    ROOT --> DEVIN["📁 devin/"]
    ROOT --> SCRIPTS["📁 scripts/ado/"]
    ROOT --> STORAGE["📁 DevinStorage/"]
    ROOT --> SCHEMAS["📁 schemas/"]
    ROOT --> DOCS["📁 docs/"]

    DEVIN --> K["📁 knowledge/ (12 items)"]
    DEVIN --> P["📁 playbooks/ (9 sessions)"]
    DEVIN --> SEC["📁 secrets/"]

    SCRIPTS --> S_WI["📁 work-items/ (11)"]
    SCRIPTS --> S_WIKI["📁 wiki/ (3)"]
    SCRIPTS --> S_PR["📁 pull-requests/ (6)"]
    SCRIPTS --> S_TEST["📁 tests/ (4)"]
    SCRIPTS --> S_REPO["📁 repos/ (3)"]
    SCRIPTS --> S_AUTH["🔑 auth.sh"]

    STORAGE --> DD["📁 Devin Documentation/<br/>15 files: best practices,<br/>guides, references"]
    STORAGE --> AD["📁 AzureDevOps Documentation/<br/>18 files: API guides,<br/>operations, references"]
    STORAGE --> SCHED["📁 schedules/<br/>doc-monitor-state.json"]

    SCHEMAS --> S1["analysis-json.schema.md"]
    SCHEMAS --> S2["wiki-*.template.md (2)"]
    SCHEMAS --> S3["*-comment.template.md (2)"]
    SCHEMAS --> S4["pr-description.template.md"]

    DOCS --> D1["ado-api-reference.md"]
    DOCS --> D2["ado-operation-reference.md"]
    DOCS --> D3["error-catalog.md"]
    DOCS --> D4["field-reference.md"]
    DOCS --> D5["changelog.md"]

    style ROOT fill:#2c3e50,color:#fff
    style DEVIN fill:#3498db,color:#fff
    style SCRIPTS fill:#e74c3c,color:#fff
    style STORAGE fill:#2ecc71,color:#fff
    style SCHEMAS fill:#f39c12,color:#fff
    style DOCS fill:#9b59b6,color:#fff
```

---

## 10. ETag Workflow (Wiki Updates)

The critical ETag concurrency pattern used by Sessions B, C, and D.

```mermaid
sequenceDiagram
    participant S as Session (B/C/D)
    participant SCRIPT as wiki/update-page.sh
    participant ADO as ADO Wiki API

    S->>SCRIPT: get-page.sh "/Functionalities/{slug}"
    SCRIPT->>ADO: GET /pages?path={slug}
    ADO-->>SCRIPT: 200 + Body + ETag: "v1"
    SCRIPT-->>S: Page content + ETag "v1"

    S->>S: Modify content

    S->>SCRIPT: update-page.sh "{slug}" "{content}" "v1"
    SCRIPT->>ADO: PUT /pages?path={slug}<br/>If-Match: "v1"

    alt Success
        ADO-->>SCRIPT: 200 Updated
        SCRIPT-->>S: Success
    else Conflict (409/412)
        ADO-->>SCRIPT: 409 Conflict
        SCRIPT->>ADO: GET /pages?path={slug}
        ADO-->>SCRIPT: 200 + ETag: "v2"
        SCRIPT->>ADO: PUT /pages?path={slug}<br/>If-Match: "v2"
        ADO-->>SCRIPT: 200 Updated
        SCRIPT-->>S: Success (retry worked)
    end
```

---

## 11. Attachment Upload (2-Step Process)

The commonly misunderstood attachment upload workflow.

```mermaid
sequenceDiagram
    participant S as Session (BT/ATT)
    participant SCRIPT as add-attachment.sh
    participant ADO_BLOB as ADO Attachments API
    participant ADO_WI as ADO Work Items API

    S->>SCRIPT: add-attachment.sh {workItemId} {filePath}

    Note over SCRIPT: Step 1: Upload Blob
    SCRIPT->>ADO_BLOB: POST /attachments?fileName={name}<br/>Content-Type: application/octet-stream<br/>Body: raw file bytes
    ADO_BLOB-->>SCRIPT: 201 {url: "blob-url"}

    SCRIPT->>SCRIPT: Validate blob URL is not null

    Note over SCRIPT: Step 2: Link to Work Item
    SCRIPT->>ADO_WI: PATCH /workitems/{id}<br/>Content-Type: application/json-patch+json<br/>Body: [{op:add, rel:AttachedFile, url:"blob-url"}]
    ADO_WI-->>SCRIPT: 200 Updated

    SCRIPT-->>S: Success
```

---

## 12. Session D Decision Logic

The triage matching algorithm with loop guard.

```mermaid
flowchart TD
    START["Session D Starts<br/>Input: Work Item ID + Scope Hint"] --> READ_WI["Read Work Item<br/>Extract keywords"]
    READ_WI --> READ_INDEX["Read Functionality Index<br/>+ Analysis JSONs from DevinStorage"]
    READ_INDEX --> MATCH{"Keyword Match<br/>≥ 2 overlap?"}

    MATCH -->|"Yes"| FOUND["Match Found"]
    MATCH -->|"No"| CHECK_CHAIN{"Chain already<br/>attempted?"}

    FOUND --> LINK["Link test cases<br/>via TestedBy"]
    LINK --> CHECK_WIKI{"Wiki page<br/>exists? (GET)"}
    CHECK_WIKI -->|"200"| UPDATE_WIKI["Update Wiki<br/>work items table"]
    CHECK_WIKI -->|"404"| SKIP_WIKI["Skip Wiki update<br/>Note in comment"]
    UPDATE_WIKI --> DEDUP["Check workItems<br/>array for dupes"]
    SKIP_WIKI --> DEDUP
    DEDUP --> COMMENT_FOUND["Post triage<br/>complete comment"]
    COMMENT_FOUND --> DONE["✅ Exit"]

    CHECK_CHAIN -->|"No (first time)"| TRIGGER["Trigger A → B → C<br/>chain"]
    CHECK_CHAIN -->|"Yes (already tried)"| PARTIAL["Post partial matches<br/>comment & exit"]

    TRIGGER --> REMATCH["Re-run keyword<br/>matching"]
    REMATCH --> MATCH

    PARTIAL --> DONE

    style DONE fill:#2ecc71,color:#fff
    style TRIGGER fill:#e74c3c,color:#fff
    style PARTIAL fill:#f39c12,color:#fff
```
