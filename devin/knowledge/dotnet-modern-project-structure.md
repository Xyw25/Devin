# .NET 10 Project Structure — Knowledge Item

## Trigger Description
.NET 10 project structure, csproj, solution, dependency injection, middleware, appsettings

## Project File (.csproj)

XML file defining the project. Key elements:
- `<TargetFramework>net10.0</TargetFramework>` (or `net9.0`) confirms modern .NET
- `<PackageReference Include="..." Version="..." />` lists NuGet dependencies
- `<RootNamespace>` and `<AssemblyName>` identify the product name
- `<ProjectReference>` shows inter-project dependencies

## Solution Structure

The `.sln` file lists all projects. Common Clean Architecture layout:

- `src/Api/` or `src/Web/` — HTTP layer (controllers, Program.cs)
- `src/Domain/` — entities, value objects, interfaces
- `src/Application/` — business logic, CQRS handlers
- `src/Infrastructure/` — EF Core, external services
- `tests/` — unit and integration tests

## Standard Directories

| Directory | Purpose | Analysis Priority |
|---|---|---|
| `Controllers/` | API endpoints | HIGH — entry points |
| `Models/` or `Entities/` | Domain entities | HIGH — models |
| `Services/` | Business logic | HIGH — dependencies |
| `Data/` or `Infrastructure/` | EF Core DbContext, repos | HIGH — data access |
| `Migrations/` | Database schema history | MEDIUM |
| `Middleware/` | Request pipeline | LOW unless security-related |
| `wwwroot/` | Static files | SKIP |

## Dependency Injection (DI)

All service registrations live in `Program.cs` (or `Startup.cs` in older style).

`builder.Services.AddScoped<IService, Service>()` — one registration = one dependency edge.

Lifetime options: `AddTransient` (per-call), `AddScoped` (per-request), `AddSingleton` (app lifetime).

The DI container registration IS the dependency graph of the application.

## Middleware Pipeline

Defined in `Program.cs` after `var app = builder.Build()`. Order matters.

Typical order: `UseExceptionHandler` > `UseHttpsRedirection` > `UseAuthentication` > `UseAuthorization` > `MapControllers`.

## Configuration (appsettings.json)

- `ConnectionStrings` — database connection strings
- Custom sections bound via `builder.Configuration.GetSection("MyConfig").Bind(options)`
- Environment overrides: `appsettings.Development.json`, `appsettings.Production.json`

## Rules

- The DI container registration in Program.cs IS the dependency graph — read it to understand what depends on what
- Always check `.csproj` for `<TargetFramework>` to confirm .NET 10/9 (not .NET Framework 4.8)
- Product name = `<RootNamespace>` in `.csproj` or the solution folder name
- If `Startup.cs` exists alongside `Program.cs`, the project uses the older hosting model
- `appsettings.json` may contain connection strings and external service URLs relevant to architecture

## Scripts

```bash
# Identify .NET version and dependencies
grep -rn "TargetFramework\|PackageReference" --include="*.csproj" .
# Map the DI dependency graph
grep -rn "AddScoped\|AddTransient\|AddSingleton" --include="*.cs" Program.cs Startup.cs
# Find the solution file and list projects
find . -name "*.sln" -exec cat {} \;
# Check middleware pipeline order
grep -rn "app\.Use\|app\.Map" --include="*.cs" Program.cs
```
