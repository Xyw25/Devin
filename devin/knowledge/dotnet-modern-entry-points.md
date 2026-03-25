# .NET 10 Entry Points — Knowledge Item

## Trigger Description
.NET 10 entry points, API controllers, minimal APIs, Razor Pages, SignalR hubs, background services

## API Controllers

Classes decorated with `[ApiController]` and route attributes. Each public method with an HTTP verb attribute is an entry point.

Key attributes: `[HttpGet]`, `[HttpPost]`, `[HttpPut]`, `[HttpDelete]`, `[Route("api/[controller]")]`

Controller actions accept parameters from route, query string, headers, or request body via `[FromRoute]`, `[FromQuery]`, `[FromHeader]`, `[FromBody]`.

## Minimal APIs

Defined directly in `Program.cs` or via extension methods in endpoint configuration files.

Patterns: `app.MapGet()`, `app.MapPost()`, `app.MapPut()`, `app.MapDelete()`, `app.MapGroup()` for route grouping.

Minimal APIs use delegate handlers instead of controller classes. Each `Map*` call is one entry point.

## Razor Pages

Files with `@page` directive in `.cshtml` files under `Pages/`. Each page has a code-behind `.cshtml.cs` with a `PageModel` class.

Handler methods: `OnGet()`, `OnGetAsync()`, `OnPost()`, `OnPostAsync()`, and named handlers like `OnPostDelete()`.

## SignalR Hubs

Classes inheriting `Hub` or `Hub<T>`. Every public method on a hub class is invocable by connected clients.

Hubs are registered via `app.MapHub<ChatHub>("/chathub")` in the middleware pipeline.

## Background Services

Classes implementing `IHostedService` or inheriting `BackgroundService`. The `ExecuteAsync(CancellationToken)` method is the entry point.

Registered via `builder.Services.AddHostedService<MyWorker>()` in `Program.cs`.

## Search Patterns

| What | Grep Pattern | Files |
|---|---|---|
| Controllers | `grep -rn "\[ApiController\]\|\[HttpGet\]\|\[HttpPost\]" **/*.cs` | `Controllers/` |
| Minimal APIs | `grep -rn "app\.Map\(Get\|Post\|Put\|Delete\)" Program.cs` | `Program.cs` |
| Razor Pages | `grep -rn "@page\|OnGet\|OnPost" **/*.cshtml **/*.cshtml.cs` | `Pages/` |
| SignalR | `grep -rn ": Hub\|: Hub<" **/*.cs` | `Hubs/` |
| Background | `grep -rn "BackgroundService\|IHostedService" **/*.cs` | `Services/` |

## Rules

- Entry point = anything that receives external input (HTTP request, SignalR message, timer tick)
- Controller actions are the primary entry points in most .NET 10 APIs
- Minimal API endpoints are equivalent to controller actions but defined inline
- Background services receive input from timers or message queues, not HTTP
- Always check `Program.cs` for endpoint registrations — it is the routing authority

## Scripts

```bash
# Find all entry points in a .NET 10 project
grep -rn "\[ApiController\]" --include="*.cs" .
grep -rn "app\.MapGet\|app\.MapPost\|app\.MapPut\|app\.MapDelete" --include="*.cs" .
grep -rn ": Hub\b\|: Hub<" --include="*.cs" .
grep -rn ": BackgroundService\|IHostedService" --include="*.cs" .
grep -rn "@page" --include="*.cshtml" .
```
