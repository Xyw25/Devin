# React Models & State — Knowledge Item

## Trigger Description
React state management, TypeScript interfaces, Redux slices, data models, API response types

## TypeScript Interfaces/Types

Data shape definitions that represent business entities:
- API response shapes (DTOs) in `src/types/` or `src/interfaces/`
- Form data shapes used by form libraries (Formik, React Hook Form)
- Entity definitions: any interface with an `id` field representing something the user sees or edits

## Redux/Zustand State

State management stores ARE the models in React applications:
- Redux: `createSlice` defines state shape, reducers, and actions in one object
- Zustand: `create()` stores with typed state and actions
- Slices map directly to domain entities (e.g., `userSlice`, `orderSlice`)

## React Query Cache

Cached server data functions as the read model:
- Query keys map to data shapes (e.g., `['users', userId]` returns a `User`)
- The cache is the source of truth for server-derived data
- Mutations define write operations against the backend

## Context Providers

Context value shapes are models when they hold domain data:
- Auth context: current user, permissions, tokens
- Theme/config context: application settings (not a business model)
- Domain contexts: shopping cart, notification state

## What Counts as a Model

| Include | Exclude |
|---------|---------|
| TypeScript interface with 3+ business fields | Utility types (Pick, Partial, Record) |
| Redux slice state shape | Component prop types |
| API response DTO | React ref types |
| Form data shape | Style/theme types |
| Entity with an `id` field | Generic wrapper types |

## Search Patterns

| What | Grep Pattern |
|------|-------------|
| TypeScript types | `grep -rn "^export interface\|^export type\|^type " src/types/ src/models/` |
| Redux slices | `grep -rn "createSlice\|createStore" src/store/ src/redux/` |
| Zustand stores | `grep -rn "create(\|zustand" src/store/` |
| API types | `grep -rn "interface.*Response\|interface.*Request\|type.*DTO" src/` |
| Form schemas | `grep -rn "yup.object\|z.object\|zodSchema" src/` |

## Rules

- In React, "models" = data shapes that represent business entities
- If it has an `id` field and represents something the user sees or edits, it is a model
- Redux slice state shapes are models even if not in a `types/` directory
- Component prop interfaces are NOT models (they describe component API, not domain data)
- Prefer looking in `src/types/`, `src/models/`, `src/interfaces/` first, then check inline definitions

## Scripts

- `grep -rn "^export interface\|^export type" src/` — find all exported type definitions
- `grep -rn "createSlice\|create(" src/store/` — find all state management stores
- Check `package.json` dependencies for redux, zustand, jotai, recoil to determine state library
