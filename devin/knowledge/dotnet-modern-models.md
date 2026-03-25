# .NET 10 Models & Entities — Knowledge Item

## Trigger Description
.NET 10 Entity Framework Core entities, DTOs, records, value objects, DbContext, migrations

## EF Core Entities

Classes mapped to database tables. Identified by `[Table]` attribute, `[Key]` on primary key property, or Fluent API configuration in `DbContext.OnModelCreating()`.

Navigation properties (`ICollection<T>`, references to other entities) define relationships.

## DbContext

Class inheriting `DbContext`. Each `DbSet<Entity>` property represents a mapped table and confirms that type is a model.

The `OnModelCreating(ModelBuilder)` override contains Fluent API configuration for relationships, indexes, and constraints.

Registered via `builder.Services.AddDbContext<AppDbContext>()` in `Program.cs`.

## DTOs (Data Transfer Objects)

Records or classes in `Models/`, `Dtos/`, or `Contracts/` folders. Used for API request/response serialization.

Common naming: `*Dto`, `*Request`, `*Response`, `*Command`, `*Query`.

DTOs cross API boundaries and should not contain business logic or navigation properties.

## Value Objects

Small immutable types (typically C# `record` types) representing domain concepts: `Money`, `Address`, `EmailAddress`, `DateRange`.

Value objects have no identity — equality is based on property values, not a key.

## Migrations

Located in `Migrations/` folder. Each migration file (e.g., `20250101_InitialCreate.cs`) shows schema evolution with `Up()` and `Down()` methods.

Run via `dotnet ef migrations add <Name>` and `dotnet ef database update`.

## Search Patterns

| What | Grep Pattern |
|---|---|
| EF Core entities | `grep -rn "\[Table\]\|\[Key\]\|DbSet<" **/*.cs` |
| DbContext | `grep -rn ": DbContext" **/*.cs` |
| DTOs | `grep -rn "record\|class.*Dto\|class.*Request\|class.*Response" Models/ Dtos/` |
| Migrations | `ls Migrations/*.cs` |

## What Counts as a Model

| Include | Exclude |
|---|---|
| EF Core entity with DbSet | Configuration classes (`IEntityTypeConfiguration`) |
| DTO with 3+ properties | Exception classes |
| Domain record / value object | Helper / utility classes |
| Enum representing business state | Generic wrapper types |

## Rules

- In .NET 10, models = EF Core entities (DbSet properties) + DTOs that cross API boundaries
- The DbContext is the authority — if it has a DbSet for it, it is a model
- Records are preferred over classes for DTOs and value objects (immutability by default)
- Check `Migrations/` to understand schema history and current table structure
- Enum types used in entity properties are part of the model surface

## Scripts

```bash
# Find all models in a .NET 10 project
grep -rn "DbSet<" --include="*.cs" .
grep -rn "\[Table(" --include="*.cs" .
grep -rn "record.*Dto\|record.*Request\|record.*Response" --include="*.cs" .
grep -rn ": DbContext" --include="*.cs" .
ls Migrations/*.cs 2>/dev/null
```
