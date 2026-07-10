using EG.Common;
using Microsoft.Extensions.Logging;

namespace EG.Web.Helpers;

/// <summary>
/// Punto unico para convertir una excepcion capturada por la interfaz en un
/// mensaje seguro, conservando siempre la excepcion completa en ILogger.
/// </summary>
public static class UserFacingExceptionMessages
{
    public static string ForDisplay(
        ILoggerFactory loggerFactory,
        Exception exception,
        string? fallback = null)
    {
        ArgumentNullException.ThrowIfNull(loggerFactory);
        ArgumentNullException.ThrowIfNull(exception);

        loggerFactory
            .CreateLogger("UserFacingFlow")
            .LogError(exception, "Una operacion de interfaz fallo y su mensaje fue sanitizado para el usuario.");

        return UserFacingMessageSanitizer.SafeOrFallback(
            exception.Message,
            fallback ?? UserFacingMessages.UnexpectedError);
    }
}
