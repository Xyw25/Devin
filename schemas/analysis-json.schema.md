# Analysis JSON Schema

> Output location: `analyses/{product}/{functionality-slug}.json`
> Produced by: Session A (Code Analysis)
> Consumed by: Session B (Documentation), Session C (Test Coverage), Session D (Triage)

---

## Full Structure

```json
{
  "functionality": "string — human-readable name (e.g., 'User Login')",
  "slug": "string — kebab-case identifier (e.g., 'user-login')",
  "product": "string — product or area name (e.g., 'auth')",
  "techStack": "string — 'react' | 'dotnet-modern' | 'dotnet-legacy'",
  "keywords": [
    "string — terms for triage matching",
    "feature area names, button labels, route names, error messages"
  ],
  "lastAnalyzedCommit": "string — full 40-char commit SHA",
  "lastAnalyzedDate": "string — ISO 8601 (e.g., '2026-03-25T14:30:00Z')",
  "repositoryUrl": "string — HTTPS URL of the analyzed repo",
  "entryPoints": [
    "string — file path + method name (e.g., 'src/auth/login.ts:handleLogin')"
  ],
  "models": [
    "string — model/entity names (e.g., 'User', 'Session', 'Token')"
  ],
  "dependencies": [
    "string — direct dependencies only, one level deep"
  ],
  "calledBy": [
    "string — what directly calls this functionality"
  ],
  "logic": "string — concise description of core logic (2-3 sentences max)",
  "userWorkflow": [
    "string — ordered steps from user perspective",
    "1. User navigates to /login",
    "2. User enters credentials",
    "3. System validates against auth service"
  ],
  "actions": [
    "string — actions triggered (e.g., 'POST /api/auth/login', 'emit LoginEvent')"
  ],
  "knownIssues": "string — notable fragility or complexity (empty string if none)",
  "workItems": [
    {
      "id": 12345,
      "type": "Bug",
      "title": "Login fails with SSO token missing email",
      "url": "https://dev.azure.com/org/project/_workitems/edit/12345"
    }
  ],
  "wikiPagePath": "/Functionalities/user-login",
  "partial": false,
  "scopeLimitHit": null,
  "analysisHistory": [
    {
      "date": "2026-03-25",
      "commit": "abc123...full SHA",
      "triggeredBy": 12345,
      "note": "Initial analysis from work item #12345"
    }
  ]
}
```

## Field Rules

| Field | Required | Max Items | Notes |
|-------|----------|-----------|-------|
| `functionality` | Yes | — | Human-readable, used in Wiki page title |
| `slug` | Yes | — | Kebab-case, used in file path and Wiki path |
| `product` | Yes | — | Used as subdirectory name in `analyses/` |
| `techStack` | Yes | — | `react`, `dotnet-modern`, or `dotnet-legacy`. Set by the stack-specific Session A playbook |
| `keywords` | Yes | 20 | Used by Session D for triage matching (min 2 overlap) |
| `lastAnalyzedCommit` | Yes | — | Full SHA, compared against HEAD for skip/supplement |
| `partial` | No | — | `true` if scope limits were hit before analysis completed. Default: `false` |
| `scopeLimitHit` | No | — | Reason string if partial (e.g., "5 models exceeded"). `null` if complete |
| `entryPoints` | Yes | 10 | Hard stop: if >10 found, post comment and ask for focus |
| `models` | Yes | 5 | Hard stop: if >5 found, post comment and ask for focus |
| `dependencies` | Yes | — | One level deep only |
| `workItems` | Yes | — | Append-only, never remove entries |
| `analysisHistory` | Yes | — | Append-only, one entry per analysis run |

---

## Worked Example 1: React — User Login Page

```json
{
  "functionality": "User Login",
  "slug": "user-login",
  "product": "auth",
  "techStack": "react",
  "keywords": ["login", "sign in", "authentication", "credentials", "SSO", "OAuth", "/login", "LoginForm", "useAuth", "token"],
  "lastAnalyzedCommit": "a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4e5f6a1b2",
  "lastAnalyzedDate": "2026-03-26T10:00:00Z",
  "repositoryUrl": "https://dev.azure.com/org/project/_git/frontend",
  "entryPoints": [
    "src/pages/LoginPage.tsx:LoginPage",
    "src/hooks/useAuth.ts:useLogin",
    "src/api/authService.ts:loginWithCredentials",
    "src/api/authService.ts:loginWithSSO"
  ],
  "models": [
    "LoginFormData (src/types/auth.ts)",
    "AuthToken (src/types/auth.ts)",
    "UserProfile (src/types/user.ts)"
  ],
  "dependencies": [
    "src/hooks/useAuth.ts — custom hook wrapping auth API calls",
    "src/api/authService.ts — axios calls to /api/auth/*",
    "src/store/authSlice.ts — Redux slice storing auth state"
  ],
  "calledBy": ["src/App.tsx (route: /login)", "src/components/Header.tsx (login button)"],
  "logic": "LoginPage renders a form that accepts email/password or SSO token. On submit, useLogin hook calls authService which POSTs to /api/auth/login. On success, JWT token is stored in Redux and localStorage, user is redirected to /dashboard.",
  "userWorkflow": [
    "1. User navigates to /login",
    "2. User enters email and password (or clicks 'Sign in with SSO')",
    "3. System validates credentials against backend API",
    "4. On success: redirect to /dashboard with auth token stored",
    "5. On failure: display error message below form"
  ],
  "actions": ["POST /api/auth/login", "POST /api/auth/sso", "Redux dispatch: setAuthToken"],
  "knownIssues": "SSO callback does not handle expired tokens gracefully — fails silently if token refresh takes >5s",
  "workItems": [],
  "wikiPagePath": "/Functionalities/user-login",
  "partial": false,
  "scopeLimitHit": null,
  "analysisHistory": []
}
```

## Worked Example 2: .NET 10 — Order Cancellation API

```json
{
  "functionality": "Order Cancellation",
  "slug": "order-cancellation",
  "product": "commerce",
  "techStack": "dotnet-modern",
  "keywords": ["cancel", "order", "refund", "cancellation", "OrderController", "CancelOrder", "/api/orders", "OrderStatus"],
  "lastAnalyzedCommit": "f6e5d4c3b2a1f6e5d4c3b2a1f6e5d4c3b2a1f6e5",
  "lastAnalyzedDate": "2026-03-26T10:00:00Z",
  "repositoryUrl": "https://dev.azure.com/org/project/_git/commerce-api",
  "entryPoints": [
    "Controllers/OrderController.cs:CancelOrder",
    "Controllers/OrderController.cs:GetCancellationStatus"
  ],
  "models": [
    "Order (Entities/Order.cs)",
    "CancellationRequest (Dtos/CancellationRequest.cs)",
    "RefundResult (Dtos/RefundResult.cs)"
  ],
  "dependencies": [
    "Services/OrderService.cs — business logic for cancellation rules",
    "Services/RefundService.cs — calculates and processes refund",
    "Data/CommerceDbContext.cs — EF Core data access"
  ],
  "calledBy": ["Frontend via POST /api/orders/{id}/cancel", "Admin panel via same endpoint"],
  "logic": "CancelOrder action validates the order is in a cancellable state (not already shipped), calls OrderService to update status, triggers RefundService to calculate and process refund amount, then returns the refund result.",
  "userWorkflow": [
    "1. User navigates to order details page",
    "2. User clicks 'Cancel Order' button",
    "3. System checks if order is cancellable (not shipped)",
    "4. System calculates refund amount based on cancellation policy",
    "5. System processes refund and updates order status to 'Cancelled'",
    "6. User sees confirmation with refund details"
  ],
  "actions": ["PATCH /api/orders/{id}/cancel", "RefundService.ProcessRefund()", "EmailService.SendCancellationConfirmation()"],
  "knownIssues": "Race condition: concurrent cancellation and shipment requests can both succeed if they hit different DB replicas within the replication lag window",
  "workItems": [],
  "wikiPagePath": "/Functionalities/order-cancellation",
  "partial": false,
  "scopeLimitHit": null,
  "analysisHistory": []
}
```

## Worked Example 3: .NET 4.8 — Employee Report Generator

```json
{
  "functionality": "Employee Report Generator",
  "slug": "employee-report",
  "product": "hr",
  "techStack": "dotnet-legacy",
  "keywords": ["report", "employee", "generate", "export", "PDF", "EmployeeReport", "rptEmployee", "DataSet"],
  "lastAnalyzedCommit": "1a2b3c4d5e6f1a2b3c4d5e6f1a2b3c4d5e6f1a2b",
  "lastAnalyzedDate": "2026-03-26T10:00:00Z",
  "repositoryUrl": "https://dev.azure.com/org/project/_git/hr-portal",
  "entryPoints": [
    "Reports/EmployeeReport.aspx.cs:Page_Load",
    "Reports/EmployeeReport.aspx.cs:btnGenerate_Click",
    "Reports/EmployeeReport.aspx.cs:btnExportPDF_Click"
  ],
  "models": [
    "Employee (DAL/EmployeeDataSet.xsd — typed DataSet)",
    "Department (DAL/EmployeeDataSet.xsd — related table)",
    "ReportParameters (Models/ReportParameters.cs)"
  ],
  "dependencies": [
    "DAL/EmployeeDAL.cs — ADO.NET data access using SqlConnection",
    "BLL/ReportGenerator.cs — builds report from DataSet",
    "Utilities/PdfExporter.cs — converts report to PDF"
  ],
  "calledBy": ["HR Portal navigation menu → Reports/EmployeeReport.aspx"],
  "logic": "Page_Load populates filter dropdowns (department, date range) from database. btnGenerate_Click calls EmployeeDAL to fill the typed DataSet using a stored procedure (sp_GetEmployeeReport), then binds results to a GridView. btnExportPDF_Click converts the GridView to PDF using PdfExporter.",
  "userWorkflow": [
    "1. User navigates to Reports > Employee Report",
    "2. User selects department and date range from dropdowns",
    "3. User clicks 'Generate Report' button",
    "4. System queries database via stored procedure sp_GetEmployeeReport",
    "5. Report displays in GridView on the page",
    "6. User optionally clicks 'Export to PDF'",
    "7. PDF file downloads to user's machine"
  ],
  "actions": ["SqlCommand: sp_GetEmployeeReport", "GridView.DataBind()", "Response.BinaryWrite(pdfBytes)"],
  "knownIssues": "Stored procedure sp_GetEmployeeReport has no pagination — returns ALL matching rows. For large departments (1000+ employees) this causes timeout. Also: inline SQL in EmployeeDAL.cs line 47 is vulnerable to SQL injection if department name contains special characters.",
  "workItems": [],
  "wikiPagePath": "/Functionalities/employee-report",
  "partial": false,
  "scopeLimitHit": null,
  "analysisHistory": []
}
