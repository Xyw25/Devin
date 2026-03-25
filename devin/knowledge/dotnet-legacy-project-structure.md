# .NET 4.8 Project Structure — Knowledge Item

## Trigger Description
.NET 4.8 project structure, web.config, Global.asax, App_Code, solution, packages.config

## Project File (.csproj)

`<TargetFrameworkVersion>v4.8</TargetFrameworkVersion>` (or v4.7.2, v4.6.x). Uses MSBuild XML format with explicit file includes — every `.cs` file is listed in the `.csproj`. Solution file (`.sln`) groups multiple projects.

## web.config

THE configuration file for .NET 4.8 web apps. Contains: connection strings (`<connectionStrings>`), app settings (`<appSettings>`), authentication mode (`<authentication>`), custom HTTP modules (`<httpModules>`), WCF config (`<system.serviceModel>`), compilation settings, and custom error pages.

Read `web.config` first — it reveals the entire application architecture.

## Global.asax

Application lifecycle handler. `Application_Start` is the "Program.cs" of .NET 4.8 — route registration, dependency setup, and initialization happen here. Other events: `Application_Error` (global error handling), `Session_Start`, `Application_BeginRequest`.

## Standard Directories

| Directory | Purpose | Analysis Priority |
|---|---|---|
| Root (`.aspx` files) | Web Forms pages | HIGH — entry points |
| `App_Code/` | Shared code (Web Site projects) | HIGH |
| `Models/` | Data entities (if MVC pattern) | HIGH |
| `Controllers/` | MVC controllers (if MVC pattern) | HIGH |
| `Services/` or `BLL/` | Business logic layer | HIGH |
| `DAL/` or `DataAccess/` | Data access layer | HIGH |
| `App_Data/` | Local databases, XML files | MEDIUM |
| `Content/` or `Assets/` | CSS, images | LOW |
| `Scripts/` | JavaScript files | LOW |
| `bin/` | Compiled assemblies | SKIP |
| `obj/` | Build artifacts | SKIP |

## NuGet Packages

Check `packages.config` (old format, per-project XML file) or `<PackageReference>` in `.csproj` (newer format). The `packages/` folder at solution root contains downloaded packages.

## Dependency Injection

No DI container by default. Services are typically instantiated with `new ServiceName()` or use the Service Locator pattern. Dependencies are harder to trace — search for `new ClassName()` rather than constructor injection. Some projects add Unity, Autofac, or Ninject manually.

## Common Legacy Patterns

ViewState (persists page state across postbacks), Session state (`Session["key"]`), `IsPostBack` checks, UpdatePanel (partial-page AJAX), Master Pages (layout templates, `.master` files), User Controls (`.ascx` reusable components).

## Product Determination

Use the project name from `.csproj`, the `<title>` in `web.config`, or the IIS application name. The assembly name in `.csproj` (`<AssemblyName>`) is the definitive product identifier.

## Rules

- .NET 4.8 projects have NO DI container by default. Trace dependencies by searching for `new ClassName()` and static method calls.
- `web.config` is the most important file — read it first.
- If `App_Code/` exists, this is a Web Site project (not Web Application) — compilation model is different.
- `packages.config` reveals all third-party dependencies and their exact versions.
- Multiple project types (Web Forms, MVC, WCF) can coexist in a single solution.

## Scripts

```bash
# Analyze .NET 4.8 project structure
find . -name "*.csproj" -exec grep -l "v4\.[5-8]\|v4\.7" {} \;
find . -name "web.config" -not -path "*/bin/*" -not -path "*/obj/*"
find . -name "Global.asax" -o -name "Global.asax.cs"
find . -name "packages.config"
find . -type d -name "App_Code" -o -name "Controllers" -o -name "Models" -o -name "DAL"
```
