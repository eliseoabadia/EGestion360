using EG.Common;
using EG.Common.Enums;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using System.Reflection;
using System.Text.Json;

namespace EG.ApiCoreBS.Filters;

/// <summary>
/// Registra todas las respuestas HTTP fallidas y evita que un error 5xx exponga
/// excepciones, SQL, rutas internas u otros detalles tecnicos al cliente.
/// </summary>
public sealed class ApiResultSanitizationFilter(ILogger<ApiResultSanitizationFilter> logger) : IAsyncResultFilter
{
    private readonly ILogger<ApiResultSanitizationFilter> _logger = logger;

    public async Task OnResultExecutionAsync(ResultExecutingContext context, ResultExecutionDelegate next)
    {
        var statusCode = GetStatusCode(context);

        if (statusCode >= StatusCodes.Status400BadRequest)
        {
            LogFailedResult(context, statusCode);

            if (statusCode >= StatusCodes.Status500InternalServerError)
            {
                context.Result = BuildErrorResult(
                    statusCode,
                    UserFacingMessages.UnexpectedError,
                    ApiResponseCode.Error.ToCode(),
                    context.HttpContext.TraceIdentifier);
            }
            else if (HasNoUserResponse(context.Result) || HasUnsafeUserResponse(context.Result))
            {
                var (message, code) = GetClientError(statusCode);
                context.Result = BuildErrorResult(
                    statusCode,
                    message,
                    code,
                    context.HttpContext.TraceIdentifier);
            }
        }

        await next();
    }

    private void LogFailedResult(ResultExecutingContext context, int statusCode)
    {
        var request = context.HttpContext.Request;
        var resultType = context.Result.GetType().Name;
        var responseDetail = DescribeResult(context.Result);

        if (statusCode >= StatusCodes.Status500InternalServerError)
        {
            _logger.LogError(
                "Respuesta API fallida sanitizada. Status={StatusCode}; Method={Method}; Path={Path}; TraceId={TraceId}; ResultType={ResultType}; Response={Response}",
                statusCode,
                request.Method,
                request.Path,
                context.HttpContext.TraceIdentifier,
                resultType,
                responseDetail);
            return;
        }

        _logger.LogWarning(
            "Respuesta API rechazada. Status={StatusCode}; Method={Method}; Path={Path}; TraceId={TraceId}; ResultType={ResultType}; Response={Response}",
            statusCode,
            request.Method,
            request.Path,
            context.HttpContext.TraceIdentifier,
            resultType,
            responseDetail);
    }

    private static int GetStatusCode(ResultExecutingContext context)
    {
        return (context.Result as IStatusCodeActionResult)?.StatusCode
            ?? context.HttpContext.Response.StatusCode;
    }

    private static bool HasNoUserResponse(IActionResult result) => result switch
    {
        ObjectResult objectResult => objectResult.Value is null,
        StatusCodeResult => true,
        EmptyResult => true,
        _ => false
    };

    private static bool HasUnsafeUserResponse(IActionResult result)
    {
        if (result is not ObjectResult { Value: not null } objectResult)
        {
            return false;
        }

        var message = objectResult.Value as string ?? GetMessageProperty(objectResult.Value);
        return UserFacingMessageSanitizer.LooksTechnical(message);
    }

    private static string? GetMessageProperty(object value)
    {
        var property = value.GetType().GetProperty(
            "Message",
            BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);

        return property?.GetValue(value)?.ToString();
    }

    private static string DescribeResult(IActionResult result)
    {
        try
        {
            var value = result is ObjectResult objectResult
                ? objectResult.Value
                : result.GetType().Name;
            var serialized = JsonSerializer.Serialize(value);
            const int maxLength = 2000;
            return serialized.Length <= maxLength
                ? serialized
                : $"{serialized[..maxLength]}...";
        }
        catch (Exception ex)
        {
            return $"No se pudo serializar {result.GetType().Name}: {ex.GetType().Name}";
        }
    }

    private static ObjectResult BuildErrorResult(int statusCode, string message, string code, string traceId)
    {
        return new ObjectResult(new
        {
            Success = false,
            Message = message,
            Code = code,
            TraceId = traceId
        })
        {
            StatusCode = statusCode
        };
    }

    private static (string Message, string Code) GetClientError(int statusCode) => statusCode switch
    {
        StatusCodes.Status400BadRequest =>
            ("La informacion enviada no es valida. Revisa los datos e intenta nuevamente.", ApiResponseCode.InvalidData.ToCode()),
        StatusCodes.Status401Unauthorized =>
            ("Tu sesion ya no esta disponible. Inicia sesion nuevamente.", ApiResponseCode.Unauthorized.ToCode()),
        StatusCodes.Status403Forbidden =>
            ("No tienes permisos para realizar esta operacion.", ApiResponseCode.Forbidden.ToCode()),
        StatusCodes.Status404NotFound =>
            ("La informacion solicitada ya no existe o no esta disponible.", ApiResponseCode.NotFound.ToCode()),
        StatusCodes.Status409Conflict =>
            ("La operacion no puede completarse por el estado actual de la informacion.", "BUSINESS_RULE"),
        StatusCodes.Status429TooManyRequests =>
            ("Hay demasiadas solicitudes en curso. Espera un momento e intenta nuevamente.", ApiResponseCode.Error.ToCode()),
        _ =>
            (UserFacingMessages.OperationFailed("completar la solicitud"), ApiResponseCode.Error.ToCode())
    };
}
