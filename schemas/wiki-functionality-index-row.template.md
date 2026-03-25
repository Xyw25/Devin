# Wiki Functionality Index Row Template

> Wiki path: `/FunctionalityIndex`
> Produced by: Session B (Documentation)
> Updated by: Session C (Test Coverage)

---

## Table Format

The Functionality Index is a single Wiki page with a markdown table:

```markdown
# Functionality Index

| Functionality | Description | Product | Test Coverage | Last Updated |
|--------------|-------------|---------|---------------|-------------|
| [{name}](/Functionalities/{slug}) | {one-line description} | {product} | {status} | {YYYY-MM-DD} |
```

## Field Values

| Column | Content | Example |
|--------|---------|---------|
| Functionality | Link to dedicated page | `[User Login](/Functionalities/user-login)` |
| Description | One sentence, user-facing | "Authenticate users via credentials or SSO" |
| Product | Area/product name | "auth" |
| Test Coverage | Status indicator | "Adequate", "Gaps identified", "No tests" |
| Last Updated | ISO date of last page update | "2026-03-25" |

## Rules

- One row per functionality — no duplicates
- Rows are append-only (new functionalities) or update-in-place (existing)
- Test Coverage is updated by Session C after test evaluation
- Link format must use relative Wiki path: `[Name](/Functionalities/slug)`
