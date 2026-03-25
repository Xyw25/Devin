# React Project Structure — Knowledge Item

## Trigger Description
React Vite project structure, directory conventions, package.json, build configuration

## Standard Vite/React Directories

| Directory | Purpose | Analysis Priority |
|-----------|---------|-------------------|
| `src/pages/` or `src/views/` | Route-level components | HIGH — start here |
| `src/components/` | Shared UI components | MEDIUM — check for business logic |
| `src/hooks/` | Custom hooks | MEDIUM — API integration lives here |
| `src/api/` or `src/services/` | Backend API calls | HIGH — maps to actions |
| `src/store/` or `src/redux/` | State management | HIGH — maps to models |
| `src/types/` or `src/interfaces/` | TypeScript definitions | HIGH — maps to models |
| `src/utils/` or `src/lib/` | Utility functions | LOW — skip unless referenced |
| `src/assets/` | Images, fonts, icons | SKIP |
| `public/` | Static assets served as-is | SKIP |

## Package.json Analysis

Key dependencies to check in `dependencies` and `devDependencies`:
- **Routing**: react-router-dom, @tanstack/react-router
- **State**: @reduxjs/toolkit, zustand, jotai, recoil, mobx
- **Data fetching**: @tanstack/react-query, swr, axios, graphql
- **Forms**: react-hook-form, formik, yup, zod
- **UI framework**: @mui/material, antd, chakra-ui, tailwindcss
- **Testing**: vitest, jest, @testing-library/react, cypress, playwright

The `name` field in `package.json` identifies the project.

## Vite Configuration

`vite.config.ts` reveals critical project details:
- `server.proxy` — backend API URLs the frontend talks to
- `resolve.alias` — import path aliases (e.g., `@/` maps to `src/`)
- `plugins` — framework integrations (e.g., `@vitejs/plugin-react`)
- `build.outDir` — where production build goes

## Dependency Tracing

The typical call chain in a Vite/React app:

```
Route Component (src/pages/)
  -> UI Component (src/components/)
    -> Custom Hook (src/hooks/)
      -> API Service (src/api/)
        -> Backend Endpoint
```

State flows through: Component -> dispatch/action -> store -> selector -> Component

## Product Determination

To identify what the project does:
- `package.json` `name` and `description` fields
- Top-level `src/pages/` directory listing shows the main features
- `README.md` if present
- Route definitions show the user-facing surface area

## Rules

- Always start analysis from `src/pages/` (route-level components), then trace inward
- Never analyze `node_modules/` — it contains third-party code only
- The `package.json` is the project's identity — read it first
- `vite.config.ts` proxy settings are the fastest way to find backend API URLs
- If `src/pages/` does not exist, check for `src/views/`, `src/routes/`, or `src/app/`

## Scripts

- `cat package.json | jq '.dependencies'` — list all runtime dependencies
- `ls src/pages/` or `ls src/views/` — discover route-level components
- `cat vite.config.ts` — read proxy and alias configuration
