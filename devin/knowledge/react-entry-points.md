# React Entry Points — Knowledge Item

## Trigger Description
React Vite entry points, page components, route definitions, event handlers, API calls

## Page/Route Entry Points

Route-level components are the primary entry points users interact with:
- `export default function Page` pattern in `src/pages/` or `src/views/`
- React Router config: `<Route path=...>` or `createBrowserRouter` in a router file
- File-based routing (Next.js `pages/`, Remix `routes/`) uses the filesystem as the router

## Component Entry Points

Top-level interactive components that users trigger directly:
- Forms (`<form onSubmit=...>`)
- Buttons with `onClick` handlers that invoke business logic
- Modals triggered by user action (dialogs, drawers, popups)
- Navigation elements (tabs, menus, breadcrumbs)

## API Integration Points

Where the frontend communicates with the backend:
- Direct `fetch()` or `axios.get/post/put/delete` calls
- React Query / TanStack Query: `useQuery`, `useMutation` hooks
- API service files in `src/api/` or `src/services/` that wrap HTTP calls
- GraphQL queries and mutations via Apollo or urql

## Event Handlers

Functions bound to DOM events that trigger business logic:
- `onClick` — user-initiated actions (submit, navigate, toggle)
- `onSubmit` — form submissions
- `onChange` — input changes that trigger validation or state updates
- `onBlur` — field-level validation on focus loss

## Search Patterns

| What | Grep Pattern | Files |
|------|-------------|-------|
| Route definitions | `grep -rn "path=\|<Route\|createBrowserRouter" src/` | Router config |
| Page components | `grep -rn "export default function\|export default class" src/pages/` | Pages |
| API calls | `grep -rn "fetch(\|axios\.\|useQuery\|useMutation" src/` | Service/hook files |
| Event handlers | `grep -rn "onClick=\|onSubmit=\|onChange=" src/components/` | Components |
| Main entry | `grep -rn "createRoot\|ReactDOM.render" src/` | `main.tsx` or `index.tsx` |

## Rules

- Entry point = a component or function that the user triggers directly or that handles a route
- NOT utility functions, NOT custom hooks (unless they are the sole API call point)
- Always trace from route component inward: Page -> Component -> Hook -> API service
- The app root is `src/main.tsx` (Vite) which mounts the router and providers

## Scripts

- `grep -rn "path=" src/` — fastest way to find all route definitions
- `grep -rn "useQuery\|useMutation\|fetch(\|axios" src/` — find all API integration points
- Check `vite.config.ts` proxy settings to discover backend API base URLs
