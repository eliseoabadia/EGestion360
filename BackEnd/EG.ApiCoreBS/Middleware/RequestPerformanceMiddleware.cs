using System.Diagnostics;
using System.Security.Claims;

namespace EG.ApiCoreBS.Middleware;

/// <summary>
/// Registra solicitudes lentas para identificar cuellos de botella durante pruebas
/// y produccion sin capturar cuerpos, tokens ni informacion sensible.
/// </summary>
public sealed class RequestPerformanceMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestPerformanceMiddleware> _logger;
    private readonly long _slowRequestMilliseconds;

    public RequestPerformanceMiddleware(
        RequestDelegate next,
        ILogger<RequestPerformanceMiddleware> logger,
        IConfiguration configuration)
    {
        _next = next;
        _logger = logger;
        _slowRequestMilliseconds = Math.Max(
            100,
            configuration.GetValue<long?>("Performance:SlowRequestMilliseconds") ?? 1_000);
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var stopwatch = Stopwatch.StartNew();
        try
        {
            await _next(context);
        }
        finally
        {
            stopwatch.Stop();
            if (stopwatch.ElapsedMilliseconds >= _slowRequestMilliseconds)
            {
                var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier)
                    ?? context.User.FindFirstValue("Id")
                    ?? context.User.FindFirstValue("id")
                    ?? "0";

                _logger.LogWarning(
                    "Solicitud lenta. TraceId={TraceId}; Method={Method}; Path={Path}; StatusCode={StatusCode}; ElapsedMs={ElapsedMs}; UserId={UserId}",
                    context.TraceIdentifier,
                    context.Request.Method,
                    context.Request.Path,
                    context.Response.StatusCode,
                    stopwatch.ElapsedMilliseconds,
                    userId);
            }
        }
    }
}
