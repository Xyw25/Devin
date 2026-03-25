# .NET 4.8 Data Models — Knowledge Item

## Trigger Description
.NET 4.8 data models, ADO.NET DataSets, Entity Framework 6, LINQ to SQL, SqlConnection, stored procedures

## ADO.NET DataSets / DataTables

`DataSet`, `DataTable`, `DataAdapter`, `SqlCommand` — raw data access without ORM. Data is accessed by column name strings: `row["ColumnName"]`. No compile-time type safety.

## Typed DataSets

`.xsd` files generate strongly-typed DataSet classes with named properties. The `.xsd` designer file maps database tables to typed DataTable classes with typed DataRow accessors.

## Entity Framework 6

`.edmx` files (visual designer) map the database schema to entity classes. `DbContext` subclass with `DbSet<Entity>` properties. Can be model-first (from `.edmx`), database-first (generated from DB), or code-first (classes define schema).

The `.edmx` file (if present) is the single most informative artifact — it maps the entire database schema.

## LINQ to SQL

`.dbml` files map tables to classes. `DataContext` is the unit of work. Older and simpler than EF6, but still found in legacy codebases.

## Raw SQL / SqlConnection

`SqlConnection`, `SqlCommand`, `SqlDataReader` — inline SQL or stored procedure calls. Parameters via `SqlParameter`. Connection strings in `web.config` under `<connectionStrings>`.

## Stored Procedures

Called via `SqlCommand` with `CommandType.StoredProcedure`. The stored procedure name IS part of the data model — it represents a data operation and its expected inputs/outputs.

## Search Patterns

| What | Grep Pattern |
|---|---|
| ADO.NET | `grep -rn "SqlConnection\|SqlCommand\|DataAdapter\|DataTable" --include="*.cs" .` |
| EF6 | `grep -rn ": DbContext\|DbSet<" --include="*.cs" .` or `find . -name "*.edmx"` |
| LINQ to SQL | `find . -name "*.dbml"` |
| Stored procs | `grep -rn "StoredProcedure\|CommandType\.StoredProcedure" --include="*.cs" .` |
| Typed DataSets | `find . -name "*.xsd"` |

## What Counts as a Model

| Include | Exclude |
|---|---|
| EF6 entity (from edmx or code-first) | DataRow (too granular) |
| Typed DataSet table | SqlParameter objects |
| Business object class with 3+ properties | Configuration helper classes |
| Stored procedure name (represents a data operation) | Connection string wrappers |

## Rules

- .NET 4.8 codebases often mix multiple data access patterns in the same project. Check for ALL of them.
- The `.edmx` file is the most informative single file — it maps the entire database schema visually.
- Stored procedure names are important — they represent data operations and are part of the model.
- Connection strings in `web.config` reveal database targets and can clarify which data layer is primary.
- Typed DataSets (`.xsd`) generate large designer files — read the `.xsd` schema, not the generated code.

## Scripts

```bash
# Find all data model artifacts in a .NET 4.8 project
find . -name "*.edmx" -o -name "*.dbml" -o -name "*.xsd"
grep -rn ": DbContext\|DbSet<" --include="*.cs" .
grep -rn "SqlConnection\|SqlCommand\|DataAdapter" --include="*.cs" .
grep -rn "CommandType\.StoredProcedure" --include="*.cs" .
grep -rn "class.*\(DataSet\|DataTable\)" --include="*.cs" .
```
