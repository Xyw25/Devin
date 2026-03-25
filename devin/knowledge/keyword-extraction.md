# Keyword Extraction — Knowledge Item

## Trigger Description
Keyword extraction algorithm for triage matching, work item keyword analysis, functionality matching

## Algorithm

Used by Session D (Triage) and Session PR-Creation to match work items to known functionalities.

### Step 1: Extract raw tokens

From the work item **title** and **description**, extract all individual words:
- Split on whitespace, punctuation, and camelCase boundaries
- Lowercase all tokens
- Strip leading/trailing punctuation

### Step 2: Remove stopwords

Remove these common words that carry no matching value:

```
the, a, an, is, was, are, were, be, been, being, have, has, had,
do, does, did, will, would, shall, should, can, could, may, might,
not, no, nor, but, or, and, if, then, else, when, while, for, from,
to, in, on, at, by, with, about, between, through, during, before,
after, above, below, up, down, out, off, over, under, again, further,
it, its, this, that, these, those, i, me, my, we, our, you, your,
he, she, they, them, their, who, which, what, where, how, why,
bug, fix, issue, error, problem, broken, fails, failing, failed,
please, need, want, should, must, update, change, add, remove, new
```

### Step 3: Keep meaningful tokens

Keep tokens that are:
- **Route paths** — `/api/auth/login`, `/dashboard`, `/settings`
- **Function/method names** — `handleLogin`, `validateToken`, `getUserProfile`
- **Component names** — `LoginForm`, `DashboardWidget`, `OrderTable`
- **Technical terms** — `SSO`, `OAuth`, `CORS`, `pagination`, `timeout`
- **Entity/model names** — `User`, `Order`, `Invoice`, `Session`
- **UI element labels** — `submit button`, `search bar`, `dropdown`
- **Error messages** — specific error text (not generic "error occurred")

### Step 4: Compare against functionality keywords

For each analysis JSON in `analyses/*/`:
1. Read the `keywords` array
2. Count how many extracted tokens appear in the array (case-insensitive substring match)
3. **Match threshold: 2 or more overlapping keywords**

If multiple functionalities match:
- Pick the one with the **highest overlap count**
- If tied, list all matches in the comment and ask the user

## Edge Cases

| Scenario | Handling |
|----------|---------|
| Single-word title (e.g., "Login") | Extract that word; likely only 1 match — below threshold, trigger Session A |
| Abbreviations (e.g., "auth" vs "authentication") | Treat as different tokens. To improve matching, include both forms in the functionality's `keywords` array |
| Multi-word phrases (e.g., "order cancellation") | Split into separate tokens: "order", "cancellation" — each matches independently |
| Non-English content | Extract tokens as-is; matching depends on what's in the `keywords` array |
| Very common technical terms (e.g., "API", "database") | Keep them — they're meaningful when combined with other terms. The 2-keyword threshold prevents false positives from a single common term |
| CamelCase (e.g., "getUserProfile") | Split into: "get", "user", "profile" — increases matching surface |

## Example

**Work item title:** "User unable to sign in with SSO token"
**Description:** "When clicking the login button, SSO authentication fails with 401 error on /api/auth/sso endpoint"

**Extracted tokens after stopwords removal:**
`user, unable, sign, sso, token, clicking, login, button, authentication, 401, api, auth, endpoint`

**Functionality "User Authentication" keywords:**
`["login", "SSO", "OAuth", "authenticate", "token", "/api/auth", "LoginForm", "session"]`

**Overlap:** `login`, `sso`, `token`, `auth` → **4 matches** → confirmed match

## Rules

- Always lowercase tokens before comparison
- Always use substring matching (not exact match) — "auth" matches "authentication"
- The `keywords` array in analysis JSON is the authoritative list — Session A must populate it well
- If zero functionalities match at 2+ threshold, trigger Session A to create a new analysis
- Never modify the `keywords` array during triage — only Session A writes keywords

## Scripts

- `scripts/ado/work-items/query.sh` — can be used to batch-fetch work items for keyword analysis
- Keyword comparison is performed in the playbook logic, not in a dedicated script
