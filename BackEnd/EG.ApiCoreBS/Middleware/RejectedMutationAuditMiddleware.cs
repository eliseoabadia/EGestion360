using System.Diagnostics;
using System.Security.Claims;

namespace EG.ApiCoreBS.Middleware;

/// <summary>
/// Registra intentos de mutacion rechazados sin almacenar el cuerpo de la
/// solicitud. Esto permite auditar validaciones operativas sin exponer datos
/// sensibles, documentos, contrasenas ni tokens.
/// </summary>
public sealed class RejectedMutationAuditMiddleware
{
    private static readonly HashSet<string> MutationMethods =
        new(StringComparer.OrdinalIgnoreCase) { "POST", "PUT", "PATCH", "DELETE" };

    private readonly RequestDelegate _next;
    private readonly ILogger<RejectedMutationAuditMiddleware> _logger;

    public RejectedMutationAuditMiddleware(
        RequestDelegate next,
        ILogger<RejectedMutationAuditMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        await _next(context);

        if (!MutationMethods.Contains(context.Request.Method) ||
            context.Response.StatusCode < StatusCodes.Status400BadRequest ||
            context.Request.Path.StartsWithSegments("/api/Auth", StringComparison.OrdinalIgnoreCase))
        {
            return;
        }

        var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? context.User.FindFirstValue("UserId")
            ?? "anonimo";
        var employee = context.User.FindFirstValue(ClaimTypes.Name)
            ?? context.User.FindFirstValue("PayrollId")
            ?? "no-identificado";
        var elapsed = Activity.Current?.Duration.TotalMilliseconds;

        _logger.LogWarning(
            "Validacion operativa rechazada. Metodo={Method}; Ruta={Path}; Estado={StatusCode}; " +
            "UsuarioId={UserId}; Usuario={Employee}; TraceId={TraceId}; DuracionMs={ElapsedMs}",
            context.Request.Method,
            context.Request.Path.Value ?? string.Empty,
            context.Response.StatusCode,
            userId,
            employee,
            context.TraceIdentifier,
            elapsed.HasValue ? Math.Round(elapsed.Value, 2) : null);
    }
}
