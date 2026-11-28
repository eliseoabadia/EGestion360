namespace EG.Common;

/// <summary>
/// Separa mensajes de negocio que puede entender el usuario de detalles tecnicos
/// que solo deben conservarse en los registros de diagnostico.
/// </summary>
public static class UserFacingMessageSanitizer
{
    private static readonly string[] TechnicalIndicators =
    [
        "system.",
        "microsoft.",
        "exception",
        "stacktrace",
        "innerexception",
        "sqlstate",
        "sqlexception",
        "dbupdateexception",
        "npgsql",
        "mysql",
        "ora-",
        "object reference not set",
        "sequence contains no",
        "cannot access a disposed object",
        "connection string",
        "invalid column name",
        "incorrect syntax near",
        "statement conflicted with the",
        "string or binary data would be truncated",
        "the statement has been terminated",
        "linea:",
        "línea:",
        "foreign key constraint",
        " at eg.",
        ".cs:line ",
        " en eg."
    ];

    public static bool LooksTechnical(string? message)
    {
        if (string.IsNullOrWhiteSpace(message))
        {
            return false;
        }

        var normalized = message.Trim().ToLowerInvariant();
        return normalized.Length > 1000 ||
               TechnicalIndicators.Any(normalized.Contains);
    }

    public static string SafeOrFallback(string? message, string fallback)
    {
        return string.IsNullOrWhiteSpace(message) || LooksTechnical(message)
            ? fallback
            : message.Trim();
    }

    public static string FromStoredProcedure(string? message)
    {
        if (string.IsNullOrWhiteSpace(message))
            return UserFacingMessages.UnexpectedError;

        // Existing SQL procedures wrap business errors in application/line metadata.
        // Extract only that documented envelope; unknown technical content stays private.
        var envelope = System.Text.RegularExpressions.Regex.Match(message,
            @"\A(?:[^\r\n]*\r?\n)?Error:\s*(?<message>.*?)\s+L[ií]nea:\s*\d+\s*\z",
            System.Text.RegularExpressions.RegexOptions.Singleline |
            System.Text.RegularExpressions.RegexOptions.IgnoreCase,
            TimeSpan.FromMilliseconds(100));
        return SafeOrFallback(envelope.Success ? envelope.Groups["message"].Value : message,
            UserFacingMessages.UnexpectedError);
    }
}
