# .NET 4.8 Entry Points — Knowledge Item

## Trigger Description
.NET 4.8 entry points, ASPX pages, code-behind, ASMX web services, WCF services, HTTP handlers

## Web Forms (ASPX) Pages

`.aspx` files with code-behind `.aspx.cs`. Entry points: `Page_Load`, `Page_Init`, `Page_PreRender`, button click handlers (`Button_Click`), grid events (`GridView_RowCommand`, `GridView_RowDataBound`), and any postback event handler.

A single ASPX page can have many entry points — one per server control event. The `IsPostBack` check in `Page_Load` separates initial load from postback handling.

## ASMX Web Services

`.asmx` files with code-behind. Methods decorated with `[WebMethod]` are exposed as SOAP endpoints. Each `[WebMethod]` is an entry point callable over HTTP.

## WCF Services

`.svc` files with interfaces marked `[ServiceContract]`. Methods decorated with `[OperationContract]` are entry points. Configuration lives in `web.config` under `<system.serviceModel>`.

## ASP.NET MVC (4.x)

Controllers inheriting `Controller` or `ApiController`. Action methods returning `ActionResult`, `JsonResult`, `ViewResult`, or `HttpResponseMessage` are entry points. Routes defined in `RouteConfig.cs` or via `[Route]` attributes.

## HTTP Handlers

`.ashx` files implementing `IHttpHandler`. The `ProcessRequest(HttpContext context)` method is the single entry point. Used for dynamic image generation, file downloads, and custom endpoints.

## Global.asax

Application lifecycle events: `Application_Start`, `Application_End`, `Session_Start`, `Session_End`, `Application_Error`, `Application_BeginRequest`. These are application-level entry points, not per-request endpoints.

## Search Patterns

| What | Grep Pattern | Files |
|---|---|---|
| ASPX pages | `find . -name "*.aspx.cs" -exec grep -l "Page_Load\|btn.*Click" {} \;` | Code-behind |
| Web Services | `grep -rn "\[WebMethod\]" --include="*.cs"` | Service files |
| WCF | `grep -rn "\[OperationContract\]\|\[ServiceContract\]" --include="*.cs"` | WCF services |
| MVC Controllers | `grep -rn ": Controller\|: ApiController" --include="*.cs"` | Controllers/ |
| HTTP Handlers | `find . -name "*.ashx" -o -name "*.ashx.cs"` | Handlers |

## Rules

- In .NET 4.8, entry points are MUCH more diverse than modern .NET. Check ALL the above patterns.
- ASPX postback model means a single page can have many entry points (one per button/event).
- WCF and ASMX are separate service models — a project may use both.
- Global.asax `Application_Start` is the equivalent of modern `Program.cs` — initialization happens there.
- MVC and Web Forms can coexist in the same project.

## Scripts

```bash
# Find all entry points in a .NET 4.8 project
find . -name "*.aspx.cs" -exec grep -l "Page_Load\|btn.*Click\|Page_Init" {} \;
grep -rn "\[WebMethod\]" --include="*.cs" .
grep -rn "\[OperationContract\]\|\[ServiceContract\]" --include="*.cs" .
grep -rn ": Controller\|: ApiController" --include="*.cs" .
find . -name "*.ashx" -o -name "*.ashx.cs"
grep -rn "Application_Start\|Application_Error" --include="*.asax" --include="*.asax.cs" .
```
