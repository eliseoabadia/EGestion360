using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Text.Json;
using EG.Contracts.Platform.Licensing;

return await LicenseGeneratorProgram.RunAsync(args);

internal static class LicenseGeneratorProgram
{
    private const string DefaultKeyId = "2026-01";
    private static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web)
    {
        WriteIndented = true,
        PropertyNameCaseInsensitive = true
    };

    internal static async Task<int> RunAsync(string[] args)
    {
        try
        {
            if (args.Length == 0)
            {
                PrintUsage();
                return 1;
            }

            return args[0].ToLowerInvariant() switch
            {
                "init-key" => InitializeKey(GetOption(args, "--kid") ?? DefaultKeyId),
                "show-public" => ShowPublicKey(),
                "issue" => await IssueAsync(args),
                _ => UnknownCommand(args[0])
            };
        }
        catch (Exception ex)
        {
            Console.Error.WriteLine($"ERROR: {ex.Message}");
            return 2;
        }
    }

    private static int InitializeKey(string keyId)
    {
        ValidateKeyId(keyId);

        RemovePreviouslyConfiguredCertificate();

        using var rsa = RSA.Create(3072);
        var request = new CertificateRequest(
            $"CN=GE360 Licensing {keyId}",
            rsa,
            HashAlgorithmName.SHA256,
            RSASignaturePadding.Pss);
        request.CertificateExtensions.Add(new X509BasicConstraintsExtension(false, false, 0, true));
        request.CertificateExtensions.Add(new X509KeyUsageExtension(X509KeyUsageFlags.DigitalSignature, true));
        request.CertificateExtensions.Add(new X509SubjectKeyIdentifierExtension(request.PublicKey, false));

        using var temporaryCertificate = request.CreateSelfSigned(
            DateTimeOffset.UtcNow.AddDays(-1),
            DateTimeOffset.UtcNow.AddYears(10));
        var transportPassword = Convert.ToHexString(RandomNumberGenerator.GetBytes(32));
        var pfx = temporaryCertificate.Export(X509ContentType.Pkcs12, transportPassword);
        using var certificate = X509CertificateLoader.LoadPkcs12(
            pfx,
            transportPassword,
            X509KeyStorageFlags.UserKeySet | X509KeyStorageFlags.PersistKeySet);
        CryptographicOperations.ZeroMemory(pfx);

        using var store = new X509Store(StoreName.My, StoreLocation.CurrentUser);
        store.Open(OpenFlags.ReadWrite);
        store.Add(certificate);

        var settings = new SignerSettings
        {
            KeyId = keyId,
            CertificateThumbprint = certificate.Thumbprint
        };
        var settingsPath = GetSettingsPath();
        Directory.CreateDirectory(Path.GetDirectoryName(settingsPath)!);
        File.WriteAllText(settingsPath, JsonSerializer.Serialize(settings, JsonOptions), Encoding.UTF8);

        Console.WriteLine($"KeyId: {keyId}");
        Console.WriteLine($"Thumbprint: {certificate.Thumbprint}");
        Console.WriteLine("PublicKeyPem:");
        Console.WriteLine(certificate.GetRSAPublicKey()!.ExportSubjectPublicKeyInfoPem());
        Console.WriteLine($"Configuración interna: {settingsPath}");
        Console.WriteLine("La clave privada quedó en el almacén de certificados del usuario actual y no se exportó.");
        return 0;
    }

    private static void RemovePreviouslyConfiguredCertificate()
    {
        var settingsPath = GetSettingsPath();
        if (!File.Exists(settingsPath))
            return;

        var previous = JsonSerializer.Deserialize<SignerSettings>(File.ReadAllText(settingsPath), JsonOptions);
        if (string.IsNullOrWhiteSpace(previous?.CertificateThumbprint))
            return;

        using var store = new X509Store(StoreName.My, StoreLocation.CurrentUser);
        store.Open(OpenFlags.ReadWrite);
        var certificates = store.Certificates.Find(
            X509FindType.FindByThumbprint,
            previous.CertificateThumbprint,
            validOnly: false);
        foreach (var certificate in certificates)
            store.Remove(certificate);
    }

    private static int ShowPublicKey()
    {
        var (settings, certificate) = LoadSigner();
        using (certificate)
        using (var rsa = certificate.GetRSAPublicKey())
        {
            Console.WriteLine($"KeyId: {settings.KeyId}");
            Console.WriteLine(rsa!.ExportSubjectPublicKeyInfoPem());
        }

        return 0;
    }

    private static async Task<int> IssueAsync(string[] args)
    {
        var requestPath = RequireOption(args, "--request");
        var contractPath = RequireOption(args, "--contract");
        var outputPath = RequireOption(args, "--out");

        var installation = JsonSerializer.Deserialize<LicenseInstallationRequestResponse>(
            await File.ReadAllTextAsync(requestPath),
            JsonOptions) ?? throw new InvalidOperationException("La solicitud de instalación no es válida.");
        var contract = JsonSerializer.Deserialize<LicenseIssueContract>(
            await File.ReadAllTextAsync(contractPath),
            JsonOptions) ?? throw new InvalidOperationException("El contrato de emisión no es válido.");

        ValidateInstallation(installation);
        ValidateContract(contract);
        var (settings, certificate) = LoadSigner();

        using (certificate)
        using (var privateKey = certificate.GetRSAPrivateKey())
        {
            if (privateKey is null)
                throw new InvalidOperationException("El certificado configurado no contiene la clave privada.");

            var payload = new LicenseTokenPayload
            {
                Product = installation.Product,
                FormatVersion = installation.FormatVersion,
                LicenseId = contract.LicenseId == Guid.Empty ? Guid.NewGuid() : contract.LicenseId,
                InstallationId = installation.InstallationId,
                InstallationFingerprint = installation.InstallationFingerprint,
                Serial = contract.Serial,
                IssuedAtUtc = contract.IssuedAtUtc ?? DateTimeOffset.UtcNow,
                Modules = contract.Modules.Select(module => new LicenseTokenModule
                {
                    Code = LicenseModuleCodes.Find(module.Code)!.Code,
                    StartsAtUtc = module.StartsAtUtc,
                    EndsAtUtc = module.EndsAtUtc
                }).ToList()
            };

            var headerBytes = JsonSerializer.SerializeToUtf8Bytes(new
            {
                alg = "PS256",
                typ = "GE360-LIC",
                kid = settings.KeyId
            });
            var payloadBytes = JsonSerializer.SerializeToUtf8Bytes(payload, JsonOptions);
            var encodedHeader = Base64UrlEncode(headerBytes);
            var encodedPayload = Base64UrlEncode(payloadBytes);
            var signingInput = Encoding.ASCII.GetBytes($"{encodedHeader}.{encodedPayload}");
            var signature = privateKey.SignData(
                signingInput,
                HashAlgorithmName.SHA256,
                RSASignaturePadding.Pss);
            var token = $"{encodedHeader}.{encodedPayload}.{Base64UrlEncode(signature)}";

            var fullOutputPath = Path.GetFullPath(outputPath);
            Directory.CreateDirectory(Path.GetDirectoryName(fullOutputPath)!);
            await File.WriteAllTextAsync(fullOutputPath, token, new UTF8Encoding(false));

            Console.WriteLine($"Licencia emitida: {fullOutputPath}");
            Console.WriteLine($"LicenseId: {payload.LicenseId}");
            Console.WriteLine($"Serial: {payload.Serial}");
            Console.WriteLine($"Módulos: {string.Join(", ", payload.Modules.Select(module => module.Code))}");
        }

        return 0;
    }

    private static (SignerSettings Settings, X509Certificate2 Certificate) LoadSigner()
    {
        var settingsPath = GetSettingsPath();
        if (!File.Exists(settingsPath))
            throw new InvalidOperationException("No existe una clave configurada. Ejecute init-key primero.");

        var settings = JsonSerializer.Deserialize<SignerSettings>(File.ReadAllText(settingsPath), JsonOptions)
            ?? throw new InvalidOperationException("La configuración del firmante está dañada.");
        using var store = new X509Store(StoreName.My, StoreLocation.CurrentUser);
        store.Open(OpenFlags.ReadOnly);
        var certificate = store.Certificates
            .Find(X509FindType.FindByThumbprint, settings.CertificateThumbprint, validOnly: false)
            .OfType<X509Certificate2>()
            .FirstOrDefault(certificate => certificate.HasPrivateKey)
            ?? throw new InvalidOperationException("No se encontró el certificado privado configurado.");

        return (settings, certificate);
    }

    private static void ValidateInstallation(LicenseInstallationRequestResponse installation)
    {
        if (installation.Product != "GE360" || installation.FormatVersion != 1)
            throw new InvalidOperationException("La solicitud corresponde a otro producto o formato.");
        if (installation.InstallationId == Guid.Empty)
            throw new InvalidOperationException("La solicitud no contiene un identificador de instalación.");
        if (installation.InstallationFingerprint.Length != 64 ||
            !installation.InstallationFingerprint.All(Uri.IsHexDigit))
            throw new InvalidOperationException("La huella de instalación no es válida.");
    }

    private static void ValidateContract(LicenseIssueContract contract)
    {
        if (contract.Serial <= 0)
            throw new InvalidOperationException("El serial debe ser mayor que cero.");
        if (contract.Modules.Count > LicenseModuleCodes.All.Count)
            throw new InvalidOperationException("El contrato contiene demasiados módulos.");

        var codes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var module in contract.Modules)
        {
            var definition = LicenseModuleCodes.Find(module.Code)
                ?? throw new InvalidOperationException($"El módulo '{module.Code}' no existe.");
            if (!codes.Add(definition.Code))
                throw new InvalidOperationException($"El módulo '{definition.Code}' está repetido.");
            if (module.StartsAtUtc == default ||
                (module.EndsAtUtc.HasValue && module.EndsAtUtc.Value <= module.StartsAtUtc))
                throw new InvalidOperationException($"Las fechas de '{definition.Code}' no son válidas.");
        }
    }

    private static string GetSettingsPath() => Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
        "GE360",
        "Licensing",
        "signer.json");

    private static string RequireOption(string[] args, string name) =>
        GetOption(args, name) ?? throw new ArgumentException($"Falta el parámetro {name}.");

    private static string? GetOption(string[] args, string name)
    {
        for (var index = 1; index < args.Length - 1; index++)
        {
            if (string.Equals(args[index], name, StringComparison.OrdinalIgnoreCase))
                return args[index + 1];
        }

        return null;
    }

    private static void ValidateKeyId(string keyId)
    {
        if (keyId.Length is < 3 or > 32 || !keyId.All(character => char.IsLetterOrDigit(character) || character is '-' or '_'))
            throw new ArgumentException("El keyId sólo puede contener letras, números, guion y guion bajo.");
    }

    private static string Base64UrlEncode(byte[] value) =>
        Convert.ToBase64String(value).TrimEnd('=').Replace('+', '-').Replace('/', '_');

    private static int UnknownCommand(string command)
    {
        Console.Error.WriteLine($"Comando desconocido: {command}");
        PrintUsage();
        return 1;
    }

    private static void PrintUsage()
    {
        Console.WriteLine("GE360.Licensing.Generator");
        Console.WriteLine("  init-key [--kid 2026-01]");
        Console.WriteLine("  show-public");
        Console.WriteLine("  issue --request solicitud.json --contract contrato.json --out cliente.lic");
    }

    private sealed class SignerSettings
    {
        public string KeyId { get; set; } = string.Empty;
        public string CertificateThumbprint { get; set; } = string.Empty;
    }
}
