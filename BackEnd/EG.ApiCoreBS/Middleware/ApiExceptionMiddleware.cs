using System.Security.Claims;
using System.Text.Json;
using EG.Common;
using EG.Common.Enums;
using EG.Common.Util;

namespace EG.ApiCoreBS.Middleware;

public sealed class ApiExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly Logger.Log4NetLogger _logger = new(typeof(ApiExceptionMiddleware));

    public ApiExceptionMiddleware(RequestDelegate next)
    {
        _next = next;
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

            LogUnhandledException(context, userIpService, ex);

            context.Response.Clear();
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            context.Response.ContentType = "application/json";

            var response = new
            {
                success = false,
                message = UserFacingMessages.UnexpectedError,
                code = ApiResponseCode.Error.ToCode(),
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

        var clientIp = userIpService.GetUserIpAddress(context);
        var path = $"{context.Request.Method} {context.Request.Path}{context.Request.QueryString}";

        _logger.LogMessage(
            LogLevelGRP.Error,
            $"Excepcion no controlada. TraceId={context.TraceIdentifier}; Path={path}; Error={ex}",
            (byte)SystemLogTypes.Error,
            "ApiExceptionMiddleware",
            userId,
            clientIp);
    }
}
