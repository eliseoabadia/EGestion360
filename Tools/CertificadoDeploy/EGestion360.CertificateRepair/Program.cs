using System.Diagnostics;
using System.Net;
using System.Net.Mail;
using System.Net.NetworkInformation;
using System.Net.Security;
using System.Net.Sockets;
using System.Security.Authentication;
using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Security.Principal;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Reflection;

namespace EGestion360.CertificateRepair;

internal static class Program
{
    private const string DefaultIpAddress = "74.208.88.178";
    private const string DefaultCertbotPath = @"C:\Program Files\Certbot\bin\certbot.exe";
    private const string ScheduledTaskName = "EGestion360 Renovar Certificado IP";
    private const string AppId = "{00112233-4455-6677-8899-AABBCCDDEEFF}";
    private const string LegoResourceName = "EGestion360.CertificateRepair.lego.exe";
    private const string LegoExecutableSha256 = "15AE53CE4290AAC98CB1D22CF13C49F17173C6A421DF6C83C3D3F6B6841C0330";
    private static readonly TimeSpan ProcessTimeout = TimeSpan.FromMinutes(30);
    private static readonly string DataRoot = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData),
        "EGestion360",
        "CertificateRepair");
    private static readonly string LegoDataPath = Path.Combine(DataRoot, "acme");
    private static readonly string LegoExecutablePath = Path.Combine(DataRoot, "bin", "lego.exe");
    private static readonly string SettingsPath = Path.Combine(DataRoot, "settings.json");

    private static async Task<int> Main(string[] args)
    {
        Console.OutputEncoding = Encoding.UTF8;
        Console.Title = "EGestion360 - Reparación de certificado";

        Options options;
        try
        {
            options = Options.Parse(args);
        }
        catch (ArgumentException ex)
        {
            Console.Error.WriteLine($"Argumentos inválidos: {ex.Message}");
            ShowHelp();
            return 2;
        }

        if (options.ShowHelp)
        {
            ShowHelp();
            return 0;
        }

        Log.Initialize();
        Log.Info("EGestion360 - Reparación de certificado HTTPS");

        try
        {
            if (!OperatingSystem.IsWindows())
            {
                throw new PlatformNotSupportedException("Este ejecutable sólo funciona en Windows Server.");
            }

            if (!IsAdministrator())
            {
                if (options.ElevationAttempted || options.Scheduled)
                {
                    throw new InvalidOperationException("No fue posible obtener privilegios de administrador.");
                }

                Log.Info("Solicitando permisos de administrador...");
                return RelaunchElevated(args);
            }

            if (options.Scheduled)
            {
                options.Apply(LoadSettings());
                Log.Info($"Configuración cargada para {options.IpAddress}.");
            }
            else
            {
                options.Email = ResolveEmail(options);
            }

            ValidateIpAddress(options.IpAddress);
            ValidatePorts(options.Ports);

            var legoPath = ExtractEmbeddedLego();
            Log.Info("Cliente ACME integrado: lego 5.3.1.");

            EnsurePort80IsAvailable();
            await ObtainCertificateWithLegoAsync(legoPath, options);

            var certificate = InstallLegoCertificate(options.IpAddress);
            var endpoints = await UpdateSslBindingsAsync(certificate, options.Ports);
            await VerifyBindingsAsync(certificate, options.IpAddress, options.Ports, endpoints);

            if (!options.Scheduled)
            {
                SaveSettings(options);
                await RegisterScheduledTaskAsync(options);
            }

            Log.Success(
                $"Certificado vigente hasta {certificate.NotAfter.ToUniversalTime():yyyy-MM-dd HH:mm:ss} UTC " +
                $"y aplicado a los puertos {string.Join(", ", options.Ports)}.");
            return 0;
        }
        catch (Exception ex)
        {
            Log.Error(ex.Message);
            Log.Debug(ex.ToString());
            return 1;
        }
        finally
        {
            if (!options.NoPause && !options.Scheduled && !Console.IsInputRedirected)
            {
                Console.WriteLine();
                Console.WriteLine("Presiona una tecla para cerrar...");
                try
                {
                    Console.ReadKey(intercept: true);
                }
                catch
                {
                    // La pausa es sólo una comodidad cuando se abre con doble clic.
                }
            }
        }
    }

    private static string? ResolveEmail(Options options)
    {
        if (options.Scheduled)
        {
            return null;
        }

        var email = options.Email;
        while (string.IsNullOrWhiteSpace(email))
        {
            if (Console.IsInputRedirected)
            {
                throw new ArgumentException("Especifica el correo con --email.");
            }

            Console.Write("Correo para Let's Encrypt: ");
            email = Console.ReadLine()?.Trim();
        }

        try
        {
            var parsed = new MailAddress(email);
            if (!string.Equals(parsed.Address, email, StringComparison.OrdinalIgnoreCase))
            {
                throw new FormatException();
            }
        }
        catch (FormatException)
        {
            throw new ArgumentException("El correo indicado no tiene un formato válido.");
        }

        return email;
    }

    private static bool IsAdministrator()
    {
        using var identity = WindowsIdentity.GetCurrent();
        return new WindowsPrincipal(identity).IsInRole(WindowsBuiltInRole.Administrator);
    }

    private static int RelaunchElevated(string[] originalArgs)
    {
        var executable = Environment.ProcessPath
            ?? throw new InvalidOperationException("No fue posible localizar el ejecutable actual.");
        var startInfo = new ProcessStartInfo
        {
            FileName = executable,
            UseShellExecute = true,
            Verb = "runas"
        };

        foreach (var argument in originalArgs.Where(arg =>
                     !string.Equals(arg, "--elevated", StringComparison.OrdinalIgnoreCase)))
        {
            startInfo.ArgumentList.Add(argument);
        }

        startInfo.ArgumentList.Add("--elevated");

        try
        {
            Process.Start(startInfo);
            return 0;
        }
        catch (System.ComponentModel.Win32Exception ex) when (ex.NativeErrorCode == 1223)
        {
            Log.Error("La solicitud de permisos de administrador fue cancelada.");
            return 1;
        }
    }

    private static string ResolveCertbotPath(string? configuredPath)
    {
        var candidates = new[]
        {
            configuredPath,
            DefaultCertbotPath,
            FindOnPath("certbot.exe")
        };

        var path = candidates.FirstOrDefault(candidate =>
            !string.IsNullOrWhiteSpace(candidate) && File.Exists(candidate));

        return path
            ?? throw new FileNotFoundException(
                "No se encontró Certbot. Instala Certbot 5.4 o superior o usa --certbot con su ruta.");
    }

    private static string? FindOnPath(string executable)
    {
        var pathValue = Environment.GetEnvironmentVariable("PATH");
        if (string.IsNullOrWhiteSpace(pathValue))
        {
            return null;
        }

        return pathValue
            .Split(Path.PathSeparator, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
            .Select(directory => Path.Combine(directory.Trim('"'), executable))
            .FirstOrDefault(File.Exists);
    }

    private static string ExtractEmbeddedLego()
    {
        Directory.CreateDirectory(Path.GetDirectoryName(LegoExecutablePath)!);
        if (File.Exists(LegoExecutablePath) &&
            string.Equals(
                Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(LegoExecutablePath))),
                LegoExecutableSha256,
                StringComparison.OrdinalIgnoreCase))
        {
            return LegoExecutablePath;
        }

        Log.Step("Preparando el cliente HTTPS integrado...");
        using var resource = Assembly.GetExecutingAssembly().GetManifestResourceStream(LegoResourceName)
            ?? throw new InvalidOperationException("El ejecutable no contiene el cliente ACME integrado.");

        var temporaryPath = LegoExecutablePath + ".tmp";
        try
        {
            using (var output = new FileStream(temporaryPath, FileMode.Create, FileAccess.Write, FileShare.None))
            {
                resource.CopyTo(output);
            }

            var actualHash = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(temporaryPath)));
            if (!string.Equals(actualHash, LegoExecutableSha256, StringComparison.OrdinalIgnoreCase))
            {
                throw new InvalidDataException(
                    $"La validación interna del cliente ACME falló. Esperado={LegoExecutableSha256}; Actual={actualHash}.");
            }

            File.Move(temporaryPath, LegoExecutablePath, overwrite: true);
            Log.Success("Cliente HTTPS integrado verificado.");
            return LegoExecutablePath;
        }
        finally
        {
            if (File.Exists(temporaryPath))
            {
                File.Delete(temporaryPath);
            }
        }
    }

    private static SavedSettings LoadSettings()
    {
        if (!File.Exists(SettingsPath))
        {
            throw new FileNotFoundException(
                "No existe la configuración de renovación. Ejecuta primero el EXE manualmente.");
        }

        var settings = JsonSerializer.Deserialize<SavedSettings>(File.ReadAllText(SettingsPath));
        return settings
            ?? throw new InvalidDataException("La configuración de renovación está vacía o dañada.");
    }

    private static void SaveSettings(Options options)
    {
        Directory.CreateDirectory(DataRoot);
        var settings = new SavedSettings(options.Email!, options.IpAddress, options.Ports);
        File.WriteAllText(
            SettingsPath,
            JsonSerializer.Serialize(settings, new JsonSerializerOptions { WriteIndented = true }),
            new UTF8Encoding(encoderShouldEmitUTF8Identifier: false));
        Log.Success($"Configuración de renovación guardada en {SettingsPath}.");
    }

    private static void ValidateIpAddress(string value)
    {
        if (!IPAddress.TryParse(value, out _))
        {
            throw new ArgumentException($"La dirección IP no es válida: {value}");
        }
    }

    private static void ValidatePorts(IReadOnlyCollection<int> ports)
    {
        if (ports.Count == 0 || ports.Any(port => port is < 1 or > 65535))
        {
            throw new ArgumentException("Los puertos deben estar entre 1 y 65535.");
        }
    }

    private static void EnsurePort80IsAvailable()
    {
        var listeners = IPGlobalProperties.GetIPGlobalProperties()
            .GetActiveTcpListeners()
            .Where(endpoint => endpoint.Port == 80)
            .ToArray();

        if (listeners.Length > 0)
        {
            throw new InvalidOperationException(
                "El puerto 80 está ocupado. Libera temporalmente el binding o servicio que lo usa " +
                "para que Let's Encrypt pueda validar la IP.");
        }

        Log.Success("Puerto 80 disponible para la validación de Let's Encrypt.");
    }

    private static async Task ObtainCertificateWithLegoAsync(string legoPath, Options options)
    {
        Log.Step(options.Scheduled
            ? "Comprobando la renovación programada..."
            : "Solicitando un certificado nuevo a Let's Encrypt...");

        Directory.CreateDirectory(LegoDataPath);
        IReadOnlyList<string> arguments =
        [
            "run",
            "--accept-tos",
            "--domains", options.IpAddress,
            "--email", options.Email!,
            "--server", "letsencrypt",
            "--profile", "shortlived",
            "--http",
            "--http.address", ":80",
            "--path", LegoDataPath,
            "--cert.name", options.IpAddress,
            "--key-type", "RSA2048",
            "--log.format", "text",
            "--user-agent", "EGestion360-Certificado/1.1.0"
        ];

        var result = await RunProcessAsync(legoPath, arguments, ProcessTimeout);
        LogProcessOutput(result);

        if (result.ExitCode != 0)
        {
            throw new InvalidOperationException(
                $"Let's Encrypt terminó con código {result.ExitCode}. " +
                "Verifica que el puerto 80 de la IP pública esté abierto y dirigido a este servidor.");
        }

        Log.Success(options.Scheduled
            ? "La comprobación de renovación terminó correctamente."
            : "Let's Encrypt emitió el certificado correctamente.");
    }

    private static X509Certificate2 InstallLegoCertificate(string ipAddress)
    {
        Log.Step("Importando el certificado en Windows...");
        var certificateDirectory = Path.Combine(LegoDataPath, "certificates");
        var fullChainPath = Path.Combine(certificateDirectory, $"{ipAddress}.crt");
        var privateKeyPath = Path.Combine(certificateDirectory, $"{ipAddress}.key");

        if (!File.Exists(fullChainPath) || !File.Exists(privateKeyPath))
        {
            throw new FileNotFoundException(
                $"Let's Encrypt no dejó los archivos del certificado en {certificateDirectory}.");
        }

        var fullChainPem = File.ReadAllText(fullChainPath);
        var privateKeyPem = File.ReadAllText(privateKeyPath);
        var publicChain = new X509Certificate2Collection();
        publicChain.ImportFromPem(fullChainPem);

        if (publicChain.Count == 0)
        {
            throw new InvalidOperationException("El archivo del certificado no contiene una cadena válida.");
        }

        using var leafWithPrivateKey = X509Certificate2.CreateFromPem(fullChainPem, privateKeyPem);
        ValidateCertificate(leafWithPrivateKey, ipAddress);

        var exportCollection = new X509Certificate2Collection { leafWithPrivateKey };
        foreach (var chainCertificate in publicChain.Cast<X509Certificate2>().Skip(1))
        {
            exportCollection.Add(chainCertificate);
        }

        var password = Convert.ToHexString(RandomNumberGenerator.GetBytes(24));
        var pfxBytes = exportCollection.Export(X509ContentType.Pfx, password)
            ?? throw new InvalidOperationException("No fue posible generar el PFX en memoria.");

        try
        {
            var importedCollection = new X509Certificate2Collection();
            importedCollection.Import(
                pfxBytes,
                password,
                X509KeyStorageFlags.MachineKeySet |
                X509KeyStorageFlags.PersistKeySet |
                X509KeyStorageFlags.Exportable);

            var importedLeaf = importedCollection
                .Cast<X509Certificate2>()
                .SingleOrDefault(certificate => certificate.HasPrivateKey)
                ?? throw new InvalidOperationException("El certificado importado no contiene su clave privada.");

            using (var personalStore = new X509Store(StoreName.My, StoreLocation.LocalMachine))
            {
                personalStore.Open(OpenFlags.ReadWrite);
                personalStore.Add(importedLeaf);
            }

            var intermediates = importedCollection
                .Cast<X509Certificate2>()
                .Where(certificate => !certificate.HasPrivateKey)
                .ToArray();

            if (intermediates.Length > 0)
            {
                using var intermediateStore =
                    new X509Store(StoreName.CertificateAuthority, StoreLocation.LocalMachine);
                intermediateStore.Open(OpenFlags.ReadWrite);
                intermediateStore.AddRange(new X509Certificate2Collection(intermediates));
            }

            Log.Success($"Certificado importado. Thumbprint: {importedLeaf.Thumbprint}");
            Log.Info(
                $"Vigencia: {importedLeaf.NotBefore.ToUniversalTime():yyyy-MM-dd HH:mm:ss} - " +
                $"{importedLeaf.NotAfter.ToUniversalTime():yyyy-MM-dd HH:mm:ss} UTC");
            return importedLeaf;
        }
        finally
        {
            CryptographicOperations.ZeroMemory(pfxBytes);
        }
    }

    private static async Task ObtainCertificateAsync(string certbotPath, Options options)
    {
        IReadOnlyList<string> certbotArguments;
        if (options.Scheduled)
        {
            Log.Step("Ejecutando renovación programada...");
            certbotArguments = ["renew", "--quiet"];
        }
        else
        {
            Log.Step("Solicitando un certificado nuevo a Let's Encrypt...");
            certbotArguments =
            [
                "certonly",
                "--standalone",
                "--preferred-profile", "shortlived",
                "--ip-address", options.IpAddress,
                "--cert-name", options.IpAddress,
                "--agree-tos",
                "--email", options.Email!,
                "--non-interactive",
                "--force-renewal"
            ];
        }

        var result = await RunProcessAsync(certbotPath, certbotArguments, ProcessTimeout);
        LogProcessOutput(result);

        if (result.ExitCode != 0)
        {
            throw new InvalidOperationException(
                $"Certbot terminó con código {result.ExitCode}. Revisa el mensaje anterior y el acceso público al puerto 80.");
        }

        Log.Success("Certbot terminó correctamente.");
    }

    private static X509Certificate2 InstallCertificate(string ipAddress)
    {
        Log.Step("Importando el certificado en Windows...");
        var livePath = ResolveCertbotLivePath(ipAddress);
        var fullChainPath = Path.Combine(livePath, "fullchain.pem");
        var privateKeyPath = Path.Combine(livePath, "privkey.pem");

        if (!File.Exists(fullChainPath) || !File.Exists(privateKeyPath))
        {
            throw new FileNotFoundException(
                $"Certbot no dejó fullchain.pem y privkey.pem en {livePath}.");
        }

        var fullChainPem = File.ReadAllText(fullChainPath);
        var privateKeyPem = File.ReadAllText(privateKeyPath);
        var publicChain = new X509Certificate2Collection();
        publicChain.ImportFromPem(fullChainPem);

        if (publicChain.Count == 0)
        {
            throw new InvalidOperationException("El archivo fullchain.pem no contiene certificados.");
        }

        using var leafWithPrivateKey = X509Certificate2.CreateFromPem(fullChainPem, privateKeyPem);
        ValidateCertificate(leafWithPrivateKey, ipAddress);

        var exportCollection = new X509Certificate2Collection { leafWithPrivateKey };
        foreach (var chainCertificate in publicChain.Cast<X509Certificate2>().Skip(1))
        {
            exportCollection.Add(chainCertificate);
        }

        var password = Convert.ToHexString(RandomNumberGenerator.GetBytes(24));
        var pfxBytes = exportCollection.Export(X509ContentType.Pfx, password)
            ?? throw new InvalidOperationException("No fue posible generar el PFX en memoria.");

        var importedCollection = new X509Certificate2Collection();
        importedCollection.Import(
            pfxBytes,
            password,
            X509KeyStorageFlags.MachineKeySet |
            X509KeyStorageFlags.PersistKeySet |
            X509KeyStorageFlags.Exportable);

        CryptographicOperations.ZeroMemory(pfxBytes);

        var importedLeaf = importedCollection
            .Cast<X509Certificate2>()
            .SingleOrDefault(certificate => certificate.HasPrivateKey)
            ?? throw new InvalidOperationException("El certificado importado no contiene su clave privada.");

        using (var personalStore = new X509Store(StoreName.My, StoreLocation.LocalMachine))
        {
            personalStore.Open(OpenFlags.ReadWrite);
            personalStore.Add(importedLeaf);
        }

        var intermediates = importedCollection
            .Cast<X509Certificate2>()
            .Where(certificate => !certificate.HasPrivateKey)
            .ToArray();

        if (intermediates.Length > 0)
        {
            using var intermediateStore = new X509Store(StoreName.CertificateAuthority, StoreLocation.LocalMachine);
            intermediateStore.Open(OpenFlags.ReadWrite);
            intermediateStore.AddRange(new X509Certificate2Collection(intermediates));
        }

        Log.Success($"Certificado importado. Thumbprint: {importedLeaf.Thumbprint}");
        Log.Info(
            $"Vigencia: {importedLeaf.NotBefore.ToUniversalTime():yyyy-MM-dd HH:mm:ss} - " +
            $"{importedLeaf.NotAfter.ToUniversalTime():yyyy-MM-dd HH:mm:ss} UTC");
        return importedLeaf;
    }

    private static string ResolveCertbotLivePath(string ipAddress)
    {
        var liveRoot = @"C:\Certbot\live";
        var exactPath = Path.Combine(liveRoot, ipAddress);
        if (File.Exists(Path.Combine(exactPath, "fullchain.pem")))
        {
            return exactPath;
        }

        if (!Directory.Exists(liveRoot))
        {
            return exactPath;
        }

        return Directory
                   .EnumerateDirectories(liveRoot, $"{ipAddress}*")
                   .Where(path => File.Exists(Path.Combine(path, "fullchain.pem")))
                   .OrderByDescending(path => File.GetLastWriteTimeUtc(Path.Combine(path, "fullchain.pem")))
                   .FirstOrDefault()
               ?? exactPath;
    }

    private static void ValidateCertificate(X509Certificate2 certificate, string ipAddress)
    {
        var now = DateTime.UtcNow;
        if (!certificate.HasPrivateKey)
        {
            throw new InvalidOperationException("El certificado emitido no contiene una clave privada.");
        }

        if (certificate.NotBefore.ToUniversalTime() > now ||
            certificate.NotAfter.ToUniversalTime() <= now.AddDays(1))
        {
            throw new InvalidOperationException(
                $"El certificado emitido no tiene vigencia suficiente: " +
                $"{certificate.NotBefore.ToUniversalTime():u} - {certificate.NotAfter.ToUniversalTime():u}.");
        }

        var subjectAlternativeName = certificate.Extensions["2.5.29.17"]?.Format(false) ?? string.Empty;
        if (!subjectAlternativeName.Contains(ipAddress, StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException(
                $"El certificado emitido no incluye la IP {ipAddress} en Subject Alternative Name.");
        }
    }

    private static async Task<IReadOnlyDictionary<int, IReadOnlyList<string>>> UpdateSslBindingsAsync(
        X509Certificate2 certificate,
        IReadOnlyCollection<int> ports)
    {
        Log.Step("Actualizando bindings HTTPS de Windows/IIS...");
        var showAll = await RunProcessAsync("netsh.exe", ["http", "show", "sslcert"], TimeSpan.FromMinutes(1));
        var updatedByPort = new Dictionary<int, IReadOnlyList<string>>();

        foreach (var port in ports.Distinct().Order())
        {
            var endpoints = DiscoverIpPortBindings(showAll.StandardOutput, port).ToList();
            if (!endpoints.Contains($"0.0.0.0:{port}", StringComparer.OrdinalIgnoreCase))
            {
                endpoints.Add($"0.0.0.0:{port}");
            }

            var successfulEndpoints = new List<string>();
            var failures = new List<string>();
            foreach (var endpoint in endpoints.Distinct(StringComparer.OrdinalIgnoreCase))
            {
                var commonArguments = new[]
                {
                    $"ipport={endpoint}",
                    $"certhash={certificate.Thumbprint}",
                    $"appid={AppId}",
                    "certstorename=MY"
                };

                var updateArguments = new[] { "http", "update", "sslcert" }.Concat(commonArguments).ToArray();
                var update = await RunProcessAsync("netsh.exe", updateArguments, TimeSpan.FromMinutes(1));
                if (update.ExitCode != 0)
                {
                    var addArguments = new[] { "http", "add", "sslcert" }.Concat(commonArguments).ToArray();
                    update = await RunProcessAsync("netsh.exe", addArguments, TimeSpan.FromMinutes(1));
                }

                if (update.ExitCode == 0)
                {
                    successfulEndpoints.Add(endpoint);
                    Log.Success($"Binding actualizado: {endpoint}");
                }
                else
                {
                    failures.Add($"{endpoint}: {FirstUsefulLine(update)}");
                }
            }

            if (successfulEndpoints.Count == 0)
            {
                throw new InvalidOperationException(
                    $"No fue posible actualizar ningún binding del puerto {port}. {string.Join(" | ", failures)}");
            }

            updatedByPort[port] = successfulEndpoints;
        }

        return updatedByPort;
    }

    private static IEnumerable<string> DiscoverIpPortBindings(string output, int port)
    {
        var escapedPort = Regex.Escape(port.ToString());
        var pattern =
            $@"(?<![A-Za-z0-9_.-])((?:\d{{1,3}}\.){{3}}\d{{1,3}}|\[[0-9A-Fa-f:]+\]):{escapedPort}(?!\d)";

        return Regex.Matches(output, pattern)
            .Select(match => match.Groups[1].Value)
            .Distinct(StringComparer.OrdinalIgnoreCase);
    }

    private static async Task VerifyBindingsAsync(
        X509Certificate2 expectedCertificate,
        string publicIpAddress,
        IReadOnlyCollection<int> ports,
        IReadOnlyDictionary<int, IReadOnlyList<string>> endpoints)
    {
        Log.Step("Verificando los bindings instalados...");
        foreach (var port in ports.Distinct().Order())
        {
            var bindingVerified = false;
            foreach (var endpoint in endpoints[port])
            {
                var show = await RunProcessAsync(
                    "netsh.exe",
                    ["http", "show", "sslcert", $"ipport={endpoint}"],
                    TimeSpan.FromMinutes(1));

                if (show.ExitCode == 0 &&
                    ContainsThumbprint(show.StandardOutput, expectedCertificate.Thumbprint))
                {
                    bindingVerified = true;
                    break;
                }
            }

            if (!bindingVerified)
            {
                throw new InvalidOperationException(
                    $"Windows no confirma el thumbprint nuevo en el puerto {port}.");
            }

            try
            {
                var servedCertificate = await ReadServedCertificateAsync(publicIpAddress, port);
                if (!string.Equals(
                        NormalizeThumbprint(servedCertificate.Thumbprint),
                        NormalizeThumbprint(expectedCertificate.Thumbprint),
                        StringComparison.OrdinalIgnoreCase))
                {
                    throw new InvalidOperationException(
                        $"El puerto público {port} todavía sirve otro certificado. " +
                        $"Esperado={expectedCertificate.Thumbprint}; Actual={servedCertificate.Thumbprint}.");
                }

                Log.Success($"Puerto público {port} sirve el certificado nuevo.");
            }
            catch (SocketException ex)
            {
                Log.Warning($"No fue posible verificar el puerto público {port} desde el propio servidor: {ex.Message}");
            }
            catch (TimeoutException ex)
            {
                Log.Warning($"No fue posible verificar el puerto público {port} desde el propio servidor: {ex.Message}");
            }
        }
    }

    private static bool ContainsThumbprint(string output, string? thumbprint)
    {
        if (string.IsNullOrWhiteSpace(thumbprint))
        {
            return false;
        }

        var compactOutput = output.Replace(" ", string.Empty, StringComparison.Ordinal);
        return compactOutput.Contains(
            NormalizeThumbprint(thumbprint),
            StringComparison.OrdinalIgnoreCase);
    }

    private static string NormalizeThumbprint(string? value) =>
        Regex.Replace(value ?? string.Empty, "[^0-9A-Fa-f]", string.Empty);

    private static async Task<X509Certificate2> ReadServedCertificateAsync(string host, int port)
    {
        using var client = new TcpClient();
        await client.ConnectAsync(host, port).WaitAsync(TimeSpan.FromSeconds(12));
        X509Certificate2? remoteCertificate = null;

        using var sslStream = new SslStream(
            client.GetStream(),
            leaveInnerStreamOpen: false,
            (_, certificate, _, _) =>
            {
                if (certificate is not null)
                {
                    remoteCertificate = new X509Certificate2(certificate);
                }

                return true;
            });

        await sslStream.AuthenticateAsClientAsync(new SslClientAuthenticationOptions
        {
            TargetHost = host,
            EnabledSslProtocols = SslProtocols.Tls12 | SslProtocols.Tls13,
            CertificateRevocationCheckMode = X509RevocationMode.NoCheck
        }).WaitAsync(TimeSpan.FromSeconds(12));

        return remoteCertificate
            ?? throw new InvalidOperationException($"El puerto {port} no presentó un certificado.");
    }

    private static async Task RegisterScheduledTaskAsync(Options options)
    {
        Log.Step("Registrando renovación automática diaria...");
        var executablePath = Environment.ProcessPath
            ?? throw new InvalidOperationException("No fue posible localizar el ejecutable actual.");
        var taskCommand =
            $"\"{executablePath}\" --scheduled --no-pause --ip {options.IpAddress} " +
            $"--ports {string.Join(',', options.Ports)}";

        var result = await RunProcessAsync(
            "schtasks.exe",
            [
                "/Create",
                "/TN", ScheduledTaskName,
                "/SC", "DAILY",
                "/ST", "03:15",
                "/RU", "SYSTEM",
                "/RL", "HIGHEST",
                "/TR", taskCommand,
                "/F"
            ],
            TimeSpan.FromMinutes(1));

        if (result.ExitCode != 0)
        {
            Log.Warning(
                $"El certificado quedó instalado, pero no se pudo registrar la tarea diaria: {FirstUsefulLine(result)}");
            return;
        }

        Log.Success($"Tarea programada registrada: {ScheduledTaskName}");
    }

    private static async Task<ProcessResult> RunProcessAsync(
        string fileName,
        IReadOnlyList<string> arguments,
        TimeSpan timeout)
    {
        using var process = new Process
        {
            StartInfo = new ProcessStartInfo
            {
                FileName = fileName,
                UseShellExecute = false,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                CreateNoWindow = true
            }
        };

        foreach (var argument in arguments)
        {
            process.StartInfo.ArgumentList.Add(argument);
        }

        if (!process.Start())
        {
            throw new InvalidOperationException($"No fue posible iniciar {fileName}.");
        }

        var standardOutput = process.StandardOutput.ReadToEndAsync();
        var standardError = process.StandardError.ReadToEndAsync();
        try
        {
            await process.WaitForExitAsync().WaitAsync(timeout);
        }
        catch (TimeoutException)
        {
            try
            {
                process.Kill(entireProcessTree: true);
            }
            catch
            {
                // El proceso puede haber terminado justo antes de intentar cancelarlo.
            }

            throw new TimeoutException($"{fileName} excedió el tiempo máximo de {timeout.TotalMinutes:0} minutos.");
        }

        return new ProcessResult(
            process.ExitCode,
            await standardOutput,
            await standardError);
    }

    private static void LogProcessOutput(ProcessResult result)
    {
        foreach (var line in (result.StandardOutput + Environment.NewLine + result.StandardError)
                     .Split(Environment.NewLine, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries))
        {
            Log.Info(line);
        }
    }

    private static string FirstUsefulLine(ProcessResult result) =>
        (result.StandardError + Environment.NewLine + result.StandardOutput)
        .Split(Environment.NewLine, StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
        .FirstOrDefault() ?? $"código {result.ExitCode}";

    private static void ShowHelp()
    {
        Console.WriteLine(
            """
            EGestion360-Certificado.exe

            Doble clic:
              Solicita permisos de administrador y pide el correo de Let's Encrypt.

            Uso:
              EGestion360-Certificado.exe --email correo@dominio.com

            Opciones:
              --email <correo>       Correo de Let's Encrypt.
              --ip <dirección>       IP pública. Predeterminado: 74.208.88.178
              --ports <lista>        Puertos HTTPS. Predeterminado: 443,8440
              --scheduled            Modo de renovación automática.
              --no-pause             No esperar una tecla al terminar.
              --help                 Mostrar esta ayuda.
            """);
    }

    private sealed class Options
    {
        public string IpAddress { get; private set; } = DefaultIpAddress;
        public string? Email { get; set; }
        public int[] Ports { get; private set; } = [443, 8440];
        public string? CertbotPath { get; private set; }
        public bool Scheduled { get; private set; }
        public bool NoPause { get; private set; }
        public bool ElevationAttempted { get; private set; }
        public bool ShowHelp { get; private set; }

        public void Apply(SavedSettings settings)
        {
            Email = settings.Email;
            IpAddress = settings.IpAddress;
            Ports = settings.Ports;
        }

        public static Options Parse(IReadOnlyList<string> args)
        {
            var options = new Options();
            for (var index = 0; index < args.Count; index++)
            {
                var argument = args[index];
                switch (argument.ToLowerInvariant())
                {
                    case "--email":
                        options.Email = ReadValue(args, ref index, argument);
                        break;
                    case "--ip":
                        options.IpAddress = ReadValue(args, ref index, argument);
                        break;
                    case "--ports":
                        options.Ports = ReadValue(args, ref index, argument)
                            .Split([',', ';'], StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
                            .Select(value => int.TryParse(value, out var port)
                                ? port
                                : throw new ArgumentException($"Puerto inválido: {value}"))
                            .Distinct()
                            .ToArray();
                        break;
                    case "--certbot":
                        options.CertbotPath = ReadValue(args, ref index, argument);
                        break;
                    case "--scheduled":
                        options.Scheduled = true;
                        break;
                    case "--no-pause":
                        options.NoPause = true;
                        break;
                    case "--elevated":
                        options.ElevationAttempted = true;
                        break;
                    case "--help":
                    case "-h":
                    case "/?":
                        options.ShowHelp = true;
                        break;
                    default:
                        throw new ArgumentException($"Opción desconocida: {argument}");
                }
            }

            return options;
        }

        private static string ReadValue(IReadOnlyList<string> args, ref int index, string option)
        {
            if (++index >= args.Count || string.IsNullOrWhiteSpace(args[index]))
            {
                throw new ArgumentException($"Falta el valor de {option}.");
            }

            return args[index];
        }
    }

    private sealed record SavedSettings(string Email, string IpAddress, int[] Ports);

    private sealed record ProcessResult(int ExitCode, string StandardOutput, string StandardError);

    private static class Log
    {
        private static readonly object Sync = new();
        private static string? _logPath;

        public static void Initialize()
        {
            try
            {
                _logPath = Path.Combine(AppContext.BaseDirectory, "EGestion360-Certificado.log");
                File.AppendAllText(
                    _logPath,
                    $"{Environment.NewLine}===== {DateTimeOffset.Now:yyyy-MM-dd HH:mm:ss zzz} ====={Environment.NewLine}",
                    Encoding.UTF8);
            }
            catch
            {
                _logPath = Path.Combine(Path.GetTempPath(), "EGestion360-Certificado.log");
            }
        }

        public static void Info(string message) => Write(message, ConsoleColor.Gray);
        public static void Step(string message) => Write(message, ConsoleColor.Cyan);
        public static void Success(string message) => Write(message, ConsoleColor.Green);
        public static void Warning(string message) => Write($"ADVERTENCIA: {message}", ConsoleColor.Yellow);
        public static void Error(string message) => Write($"ERROR: {message}", ConsoleColor.Red);
        public static void Debug(string message) => AppendToFile($"DETALLE: {message}");

        private static void Write(string message, ConsoleColor color)
        {
            lock (Sync)
            {
                var previousColor = Console.ForegroundColor;
                Console.ForegroundColor = color;
                Console.WriteLine(message);
                Console.ForegroundColor = previousColor;
                AppendToFile(message);
            }
        }

        private static void AppendToFile(string message)
        {
            if (string.IsNullOrWhiteSpace(_logPath))
            {
                return;
            }

            try
            {
                File.AppendAllText(
                    _logPath,
                    $"[{DateTimeOffset.Now:yyyy-MM-dd HH:mm:ss zzz}] {message}{Environment.NewLine}",
                    Encoding.UTF8);
            }
            catch
            {
                // Un problema de logging no debe impedir la reparación.
            }
        }
    }
}
