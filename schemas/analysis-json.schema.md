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
| `keywords` | Yes | 20 | Used by Session D for triage matching (min 2 overlap) |
| `lastAnalyzedCommit` | Yes | — | Full SHA, compared against HEAD for skip/supplement |
| `entryPoints` | Yes | 10 | Hard stop: if >10 found, post comment and ask for focus |
| `models` | Yes | 5 | Hard stop: if >5 found, post comment and ask for focus |
| `dependencies` | Yes | — | One level deep only |
| `workItems` | Yes | — | Append-only, never remove entries |
| `analysisHistory` | Yes | — | Append-only, one entry per analysis run |
