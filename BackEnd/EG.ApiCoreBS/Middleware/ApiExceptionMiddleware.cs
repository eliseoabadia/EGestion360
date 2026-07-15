using System.Security.Claims;
using System.Text.Json;
using EG.Common;
using EG.Common.Enums;
using EG.Common.Util;

namespace EG.ApiCoreBS.Middleware;

public sealed class ApiExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ApiExceptionMiddleware> _logger;

    public ApiExceptionMiddleware(RequestDelegate next, ILogger<ApiExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context, IUserIpService userIpService)
    {
        try
        {
            await _next(context);
        }
        catch (Exception ex)
        {
            if (context.Response.HasStarted)
            {
                LogUnhandledException(context, userIpService, ex);
                throw;
            }

            var isBusinessRule = ex is InvalidOperationException;
            var isInvalidRequest = ex is ArgumentException;

            if (isBusinessRule || isInvalidRequest)
            {
                LogControlledException(context, userIpService, ex);
            }
            else
            {
                LogUnhandledException(context, userIpService, ex);
            }

            context.Response.Clear();
            context.Response.StatusCode = isInvalidRequest
                ? StatusCodes.Status400BadRequest
                : isBusinessRule
                    ? StatusCodes.Status409Conflict
                    : StatusCodes.Status500InternalServerError;
            context.Response.ContentType = "application/json";

            var response = new
            {
                success = false,
                message = isInvalidRequest
                    ? "La informacion enviada no es valida. Revisa los datos e intenta nuevamente."
                    : isBusinessRule
                        ? UserFacingMessageSanitizer.SafeOrFallback(
                            ex.Message,
                            "La operacion no puede completarse por el estado actual de la informacion.")
                        : UserFacingMessages.UnexpectedError,
                code = isInvalidRequest
                    ? ApiResponseCode.InvalidData.ToCode()
                    : isBusinessRule
                        ? "BUSINESS_RULE"
                        : ApiResponseCode.Error.ToCode(),
                traceId = context.TraceIdentifier
            };

            await JsonSerializer.SerializeAsync(context.Response.Body, response);
        }
    }

    private void LogUnhandledException(HttpContext context, IUserIpService userIpService, Exception ex)
    {
        var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? context.User.FindFirstValue("Id")
            ?? context.User.FindFirstValue("id")
            ?? "0";

        _logger.LogError(
            ex,
            "Excepcion no controlada. TraceId={TraceId}; Method={Method}; Path={Path}; UserId={UserId}; ClientIp={ClientIp}",
            context.TraceIdentifier,
            context.Request.Method,
            $"{context.Request.Path}{context.Request.QueryString}",
            userId,
            userIpService.GetUserIpAddress(context));
    }

    private void LogControlledException(HttpContext context, IUserIpService userIpService, Exception ex)
    {
        var userId = context.User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? context.User.FindFirstValue("Id")
            ?? context.User.FindFirstValue("id")
            ?? "0";

        _logger.LogWarning(
            ex,
            "Validacion controlada. TraceId={TraceId}; Method={Method}; Path={Path}; UserId={UserId}; ClientIp={ClientIp}; Message={Message}",
            context.TraceIdentifier,
            context.Request.Method,
            $"{context.Request.Path}{context.Request.QueryString}",
            userId,
            userIpService.GetUserIpAddress(context),
            ex.Message);
    }
}
