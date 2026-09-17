using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using EG.Contracts.Platform.Licensing;

namespace EG.ApiCoreBS.Services.Licensing;

internal static class LicenseTokenVerifier
{
    private const int MaximumTokenLength = 64 * 1024;
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNameCaseInsensitive = false
    };

    internal static LicenseVerificationResult Verify(string? signedLicense)
    {
        if (string.IsNullOrWhiteSpace(signedLicense))
            return LicenseVerificationResult.Failure("LIC_FILE_EMPTY", "El archivo de licencia está vacío.");

        var compactToken = signedLicense.Trim();
        if (compactToken.Length > MaximumTokenLength)
            return LicenseVerificationResult.Failure("LIC_FILE_TOO_LARGE", "El archivo de licencia excede el tamaño permitido.");

        var segments = compactToken.Split('.');
        if (segments.Length != 3 || segments.Any(string.IsNullOrWhiteSpace))
            return LicenseVerificationResult.Failure("LIC_FORMAT_INVALID", "El archivo de licencia no tiene el formato esperado.");

        try
        {
            var headerBytes = DecodeBase64Url(segments[0]);
            using var headerDocument = JsonDocument.Parse(headerBytes);
            var header = headerDocument.RootElement;

            if (!TryGetExactString(header, "alg", out var algorithm) || algorithm != "PS256")
                return LicenseVerificationResult.Failure("LIC_ALGORITHM_INVALID", "El algoritmo de la licencia no está permitido.");
            if (!TryGetExactString(header, "typ", out var type) || type != "GE360-LIC")
                return LicenseVerificationResult.Failure("LIC_TYPE_INVALID", "El tipo de licencia no es válido.");
            if (!TryGetExactString(header, "kid", out var keyId) || !TrustedLicenseKeys.TryGet(keyId, out var publicKeyPem))
                return LicenseVerificationResult.Failure("LIC_KEY_UNKNOWN", "La licencia fue emitida con una clave no reconocida.");

            var signature = DecodeBase64Url(segments[2]);
            var signingInput = Encoding.ASCII.GetBytes($"{segments[0]}.{segments[1]}");

            using var rsa = RSA.Create();
            rsa.ImportFromPem(publicKeyPem);
            if (!rsa.VerifyData(signingInput, signature, HashAlgorithmName.SHA256, RSASignaturePadding.Pss))
                return LicenseVerificationResult.Failure("LIC_SIGNATURE_INVALID", "La firma de la licencia no es válida.");

            var payloadBytes = DecodeBase64Url(segments[1]);
            var payload = JsonSerializer.Deserialize<LicenseTokenPayload>(payloadBytes, JsonOptions);
            if (payload is null)
                return LicenseVerificationResult.Failure("LIC_PAYLOAD_INVALID", "No fue posible interpretar la licencia.");

            return LicenseVerificationResult.Success(payload, keyId, compactToken);
        }
        catch (FormatException)
        {
            return LicenseVerificationResult.Failure("LIC_FORMAT_INVALID", "El archivo de licencia contiene datos dañados.");
        }
        catch (JsonException)
        {
            return LicenseVerificationResult.Failure("LIC_PAYLOAD_INVALID", "El contenido de la licencia no es válido.");
        }
        catch (CryptographicException)
        {
            return LicenseVerificationResult.Failure("LIC_SIGNATURE_INVALID", "No fue posible validar la firma de la licencia.");
        }
    }

    private static bool TryGetExactString(JsonElement element, string name, out string value)
    {
        value = string.Empty;
        if (!element.TryGetProperty(name, out var property) || property.ValueKind != JsonValueKind.String)
            return false;

        value = property.GetString() ?? string.Empty;
        return !string.IsNullOrWhiteSpace(value);
    }

    internal static byte[] DecodeBase64Url(string value)
    {
        var normalized = value.Replace('-', '+').Replace('_', '/');
        normalized += (normalized.Length % 4) switch
        {
            2 => "==",
            3 => "=",
            0 => string.Empty,
            _ => throw new FormatException("Base64url inválido.")
        };

        return Convert.FromBase64String(normalized);
    }
}

internal sealed record LicenseVerificationResult(
    bool Valid,
    string Code,
    string Message,
    LicenseTokenPayload? Payload,
    string? KeyId,
    string? CompactToken)
{
    internal static LicenseVerificationResult Success(
        LicenseTokenPayload payload,
        string keyId,
        string compactToken) =>
        new(true, "LIC_VALID", "Licencia válida.", payload, keyId, compactToken);

    internal static LicenseVerificationResult Failure(string code, string message) =>
        new(false, code, message, null, null, null);
}
