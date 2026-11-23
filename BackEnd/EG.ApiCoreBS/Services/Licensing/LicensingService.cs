using System.Data;
using System.Security.Cryptography;
using System.Text;
using EG.Contracts.Platform.Licensing;
using EG.Domain.Platform.Licensing;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Licensing;

public sealed class LicensingService : ILicensingService
{
    private const string Product = "GE360";
    private const short FormatVersion = 1;
    private static readonly TimeSpan FutureIssueTolerance = TimeSpan.FromMinutes(5);

    private readonly EGestionContext _context;
    private readonly LicenseMachineStateProtector _protector;
    private readonly ILicenseRuntimeState _runtime;
    private readonly ILogger<LicensingService> _logger;

    public LicensingService(
        EGestionContext context,
        LicenseMachineStateProtector protector,
        ILicenseRuntimeState runtime,
        ILogger<LicensingService> logger)
    {
        _context = context;
        _protector = protector;
        _runtime = runtime;
        _logger = logger;
    }

    public async Task EnsureInitializedAsync(CancellationToken cancellationToken = default)
    {
        await using (var transaction = await _context.Database.BeginTransactionAsync(
            IsolationLevel.Serializable,
            cancellationToken))
        {
            var existing = await LoadInstallationRowForUpdateAsync(cancellationToken);
            if (existing is null)
            {
                var state = _protector.Create();
                var fingerprint = LicenseMachineStateProtector.GetFingerprint(state);
                var protectedState = _protector.Protect(state);

                await ExecuteAsync(
                    """
                    INSERT INTO [LIC].[EstadoInstalacion]
                        ([PkidEstado], [InstalacionId], [HuellaInstalacion], [SerialMinimoAceptado],
                         [UltimaHoraConfiableUtc], [EstadoReloj], [SelloProtegidoMaquina])
                    VALUES
                        (1, @InstalacionId, @Huella, 0, @UltimaHora, 'VALIDO', @Sello);
                    """,
                    cancellationToken,
                    new SqlParameter("@InstalacionId", state.InstallationId),
                    new SqlParameter("@Huella", fingerprint),
                    new SqlParameter("@UltimaHora", state.LastObservedUtc.UtcDateTime),
                    new SqlParameter("@Sello", protectedState));

                await InsertEventAsync(
                    null,
                    "SOLICITUD_CREADA",
                    null,
                    "Se creó la identidad protegida de la instalación.",
                    "SYSTEM",
                    "HOSTED_SERVICE",
                    cancellationToken);
            }

            await transaction.CommitAsync(cancellationToken);
        }

        await LoadRuntimeAsync(cancellationToken);
    }

    public async Task<LicenseSnapshotResponse> GetSnapshotAsync(CancellationToken cancellationToken = default)
    {
        if (_runtime.GetRuntimeSnapshot().InstallationId == Guid.Empty)
            await EnsureInitializedAsync(cancellationToken);

        return _runtime.GetSnapshot();
    }

    public async Task<LicenseInstallationRequestResponse> GetInstallationRequestAsync(
        CancellationToken cancellationToken = default)
    {
        var snapshot = await GetSnapshotAsync(cancellationToken);
        return new LicenseInstallationRequestResponse
        {
            Product = Product,
            FormatVersion = FormatVersion,
            InstallationId = snapshot.InstallationId,
            InstallationFingerprint = snapshot.InstallationFingerprint,
            GeneratedAtUtc = DateTimeOffset.UtcNow
        };
    }

    public async Task<LicenseSnapshotResponse> ImportAsync(
        string signedLicense,
        int operatorUserId,
        CancellationToken cancellationToken = default)
    {
        var verification = LicenseTokenVerifier.Verify(signedLicense);
        if (!verification.Valid || verification.Payload is null || verification.KeyId is null || verification.CompactToken is null)
        {
            await RecordRejectedImportAsync(operatorUserId, verification.Code, cancellationToken);
            throw new LicenseOperationException(verification.Code, verification.Message);
        }

        if (_runtime.GetRuntimeSnapshot().InstallationId == Guid.Empty)
            await EnsureInitializedAsync(cancellationToken);

        var currentRuntime = _runtime.GetRuntimeSnapshot();
        ValidatePayload(verification.Payload, currentRuntime, requireNewSerial: true);

        await using var transaction = await _context.Database.BeginTransactionAsync(
            IsolationLevel.Serializable,
            cancellationToken);

        var row = await LoadInstallationRowForUpdateAsync(cancellationToken)
            ?? throw new LicenseOperationException("LIC_INSTALLATION_MISSING", "No existe el estado de instalación.");
        var protectedState = ValidateProtectedState(row);

        if (verification.Payload.Serial <= protectedState.Serial)
        {
            throw new LicenseOperationException(
                "LIC_SERIAL_REPLAYED",
                "La licencia no es más reciente que la ya aceptada.");
        }

        var previousModules = await LoadCurrentModuleCodesAsync(protectedState.Serial, cancellationToken);

        await ExecuteAsync(
            """
            UPDATE [LIC].[LicenciaImportada]
               SET [Resultado] = 'SUSTITUIDA'
             WHERE [InstalacionId] = @InstalacionId
               AND [Resultado] = 'ACEPTADA';
            """,
            cancellationToken,
            new SqlParameter("@InstalacionId", protectedState.InstallationId));

        var envelopeHash = SHA256.HashData(Encoding.UTF8.GetBytes(verification.CompactToken));
        await ExecuteAsync(
            """
            INSERT INTO [LIC].[LicenciaImportada]
                ([LicenciaId], [InstalacionId], [Serial], [VersionFormato], [KeyId],
                 [SobreFirmado], [HuellaSobre], [EmitidaUtc], [Resultado], [ImportadaPor])
            VALUES
                (@LicenciaId, @InstalacionId, @Serial, @VersionFormato, @KeyId,
                 @SobreFirmado, @HuellaSobre, @EmitidaUtc, 'ACEPTADA', @ImportadaPor);
            """,
            cancellationToken,
            new SqlParameter("@LicenciaId", verification.Payload.LicenseId),
            new SqlParameter("@InstalacionId", verification.Payload.InstallationId),
            new SqlParameter("@Serial", verification.Payload.Serial),
            new SqlParameter("@VersionFormato", verification.Payload.FormatVersion),
            new SqlParameter("@KeyId", verification.KeyId),
            new SqlParameter("@SobreFirmado", verification.CompactToken),
            new SqlParameter("@HuellaSobre", envelopeHash),
            new SqlParameter("@EmitidaUtc", verification.Payload.IssuedAtUtc.UtcDateTime),
            new SqlParameter("@ImportadaPor", operatorUserId));

        var importedLicenseId = await _context.Database
            .SqlQueryRaw<long>(
                """
                SELECT [PkidLicenciaImportada] AS [Value]
                FROM [LIC].[LicenciaImportada]
                WHERE [LicenciaId] = @LicenciaId;
                """,
                new SqlParameter("@LicenciaId", verification.Payload.LicenseId))
            .SingleAsync(cancellationToken);

        foreach (var module in verification.Payload.Modules)
        {
            var canonicalCode = LicenseModuleCodes.Find(module.Code)!.Code;
            await ExecuteAsync(
                """
                INSERT INTO [LIC].[LicenciaModulo]
                    ([FkidLicenciaImportada], [CodigoModulo], [InicioUtc], [FinUtc])
                VALUES
                    (@LicenciaId, @CodigoModulo, @InicioUtc, @FinUtc);
                """,
                cancellationToken,
                new SqlParameter("@LicenciaId", importedLicenseId),
                new SqlParameter("@CodigoModulo", canonicalCode),
                new SqlParameter("@InicioUtc", module.StartsAtUtc.UtcDateTime),
                new SqlParameter("@FinUtc", module.EndsAtUtc?.UtcDateTime ?? (object)DBNull.Value));
        }

        var grantedCodes = verification.Payload.Modules
            .Select(module => LicenseModuleCodes.Find(module.Code)!.Code)
            .ToHashSet(StringComparer.OrdinalIgnoreCase);

        foreach (var module in LicenseModuleCodes.All)
        {
            var isGranted = grantedCodes.Contains(module.Code);
            var wasPreviouslyGranted = previousModules.Contains(module.Code);
            var enableNewGrant = isGranted && !wasPreviouslyGranted;

            await ExecuteAsync(
                """
                UPDATE [LIC].[ConfiguracionModulo]
                   SET [ActivoOperativo] = CASE
                           WHEN @Concedido = 0 THEN 0
                           WHEN @ConcesionNueva = 1 THEN 1
                           ELSE [ActivoOperativo]
                       END,
                       [Motivo] = CASE
                           WHEN @Concedido = 0 THEN N'No incluido en la licencia vigente'
                           WHEN @ConcesionNueva = 1 THEN NULL
                           ELSE [Motivo]
                       END,
                       [ActualizadoPor] = @Usuario,
                       [ActualizadoUtc] = SYSUTCDATETIME()
                 WHERE [CodigoModulo] = @CodigoModulo;
                """,
                cancellationToken,
                new SqlParameter("@Concedido", isGranted),
                new SqlParameter("@ConcesionNueva", enableNewGrant),
                new SqlParameter("@Usuario", operatorUserId),
                new SqlParameter("@CodigoModulo", module.Code));
        }

        var now = DateTimeOffset.UtcNow;
        var nextProtectedState = protectedState with
        {
            Serial = verification.Payload.Serial,
            LastObservedUtc = now
        };
        var nextSeal = _protector.Protect(nextProtectedState);

        await ExecuteAsync(
            """
            UPDATE [LIC].[EstadoInstalacion]
               SET [SerialMinimoAceptado] = @Serial,
                   [UltimaHoraConfiableUtc] = @UltimaHora,
                   [EstadoReloj] = 'VALIDO',
                   [SelloProtegidoMaquina] = @Sello,
                   [ModificadoUtc] = SYSUTCDATETIME()
             WHERE [PkidEstado] = 1;
            """,
            cancellationToken,
            new SqlParameter("@Serial", nextProtectedState.Serial),
            new SqlParameter("@UltimaHora", nextProtectedState.LastObservedUtc.UtcDateTime),
            new SqlParameter("@Sello", nextSeal));

        await InsertEventAsync(
            importedLicenseId,
            "IMPORTACION_ACEPTADA",
            null,
            $"Licencia serial {verification.Payload.Serial} aceptada.",
            operatorUserId.ToString(),
            "WEB",
            cancellationToken);

        await transaction.CommitAsync(cancellationToken);
        await LoadRuntimeAsync(cancellationToken);

        _logger.LogInformation(
            "Licencia aceptada. LicenseId={LicenseId}; Serial={Serial}; UserId={UserId}",
            verification.Payload.LicenseId,
            verification.Payload.Serial,
            operatorUserId);

        return _runtime.GetSnapshot();
    }

    public async Task<LicenseSnapshotResponse> SetModuleStateAsync(
        string moduleCode,
        bool active,
        string? reason,
        int operatorUserId,
        CancellationToken cancellationToken = default)
    {
        var definition = LicenseModuleCodes.Find(moduleCode)
            ?? throw new LicenseOperationException("LIC_MODULE_UNKNOWN", "El módulo indicado no existe.");
        var snapshot = _runtime.GetSnapshot();
        var module = snapshot.Modules.First(status => status.Code == definition.Code);

        if (active && !module.Contracted)
            throw new LicenseOperationException("LIC_MODULE_NOT_CONTRACTED", "El contrato vigente no incluye este módulo.");
        if (active && module.StateCode is not ("LIC_MODULE_DISABLED" or "LIC_ALLOWED"))
            throw new LicenseOperationException(module.StateCode, module.Message);

        var safeReason = string.IsNullOrWhiteSpace(reason)
            ? null
            : reason.Trim()[..Math.Min(reason.Trim().Length, 300)];

        await using var transaction = await _context.Database.BeginTransactionAsync(
            IsolationLevel.Serializable,
            cancellationToken);

        await ExecuteAsync(
            """
            UPDATE [LIC].[ConfiguracionModulo]
               SET [ActivoOperativo] = @Activo,
                   [Motivo] = @Motivo,
                   [ActualizadoPor] = @Usuario,
                   [ActualizadoUtc] = SYSUTCDATETIME()
             WHERE [CodigoModulo] = @CodigoModulo;
            """,
            cancellationToken,
            new SqlParameter("@Activo", active),
            new SqlParameter("@Motivo", safeReason ?? (object)DBNull.Value),
            new SqlParameter("@Usuario", operatorUserId),
            new SqlParameter("@CodigoModulo", definition.Code));

        await InsertEventAsync(
            null,
            active ? "MODULO_ENCENDIDO" : "MODULO_APAGADO",
            definition.Code,
            safeReason,
            operatorUserId.ToString(),
            "WEB",
            cancellationToken);

        await transaction.CommitAsync(cancellationToken);
        await LoadRuntimeAsync(cancellationToken);

        return _runtime.GetSnapshot();
    }

    public async Task PersistTrustedClockAsync(CancellationToken cancellationToken = default)
    {
        var runtime = _runtime.GetRuntimeSnapshot();
        if (runtime.InstallationId == Guid.Empty)
            return;

        var row = await LoadInstallationRowAsync(cancellationToken);
        if (row is null)
            return;

        ProtectedLicenseState state;
        try
        {
            state = ValidateProtectedState(row);
        }
        catch (LicenseOperationException ex)
        {
            _logger.LogWarning("No se persistió el reloj de licencia: {Code}", ex.Code);
            return;
        }

        var nextState = state with
        {
            Serial = runtime.Serial,
            LastObservedUtc = runtime.LastObservedUtc
        };

        await ExecuteAsync(
            """
            UPDATE [LIC].[EstadoInstalacion]
               SET [UltimaHoraConfiableUtc] = @UltimaHora,
                   [EstadoReloj] = @EstadoReloj,
                   [SelloProtegidoMaquina] = @Sello,
                   [ModificadoUtc] = SYSUTCDATETIME()
             WHERE [PkidEstado] = 1;
            """,
            cancellationToken,
            new SqlParameter("@UltimaHora", nextState.LastObservedUtc.UtcDateTime),
            new SqlParameter("@EstadoReloj", runtime.ClockSuspicious ? "SOSPECHOSO" : "VALIDO"),
            new SqlParameter("@Sello", _protector.Protect(nextState)));
    }

    private async Task LoadRuntimeAsync(CancellationToken cancellationToken)
    {
        var row = await LoadInstallationRowAsync(cancellationToken);
        if (row is null)
        {
            _runtime.Replace(new LicenseRuntimeSnapshot(
                Guid.Empty,
                string.Empty,
                null,
                0,
                false,
                DateTimeOffset.UtcNow,
                true,
                []));
            return;
        }

        ProtectedLicenseState protectedState;
        try
        {
            protectedState = ValidateProtectedState(row);
        }
        catch (LicenseOperationException ex)
        {
            _logger.LogError("Estado protegido de licencia inválido: {Code}", ex.Code);
            _runtime.Replace(new LicenseRuntimeSnapshot(
                row.InstallationId,
                row.HuellaInstalacion,
                null,
                row.SerialMinimoAceptado,
                false,
                ToUtc(row.UltimaHoraConfiableUtc),
                true,
                []));
            return;
        }

        var clockSuspicious = string.Equals(row.EstadoReloj, "SOSPECHOSO", StringComparison.Ordinal) ||
                              DateTimeOffset.UtcNow < protectedState.LastObservedUtc - TimeSpan.FromMinutes(5);
        if (protectedState.Serial == 0)
        {
            _runtime.Replace(new LicenseRuntimeSnapshot(
                protectedState.InstallationId,
                LicenseMachineStateProtector.GetFingerprint(protectedState),
                null,
                0,
                false,
                protectedState.LastObservedUtc,
                clockSuspicious,
                []));
            return;
        }

        var accepted = await _context.Database
            .SqlQueryRaw<AcceptedLicenseRow>(
                """
                SELECT TOP (1)
                    [LicenciaId], [Serial], [SobreFirmado]
                FROM [LIC].[LicenciaImportada]
                WHERE [InstalacionId] = @InstalacionId
                  AND [Serial] = @Serial
                  AND [Resultado] = 'ACEPTADA';
                """,
                new SqlParameter("@InstalacionId", protectedState.InstallationId),
                new SqlParameter("@Serial", protectedState.Serial))
            .SingleOrDefaultAsync(cancellationToken);

        if (accepted is null)
        {
            _runtime.Replace(new LicenseRuntimeSnapshot(
                protectedState.InstallationId,
                LicenseMachineStateProtector.GetFingerprint(protectedState),
                null,
                protectedState.Serial,
                false,
                protectedState.LastObservedUtc,
                clockSuspicious,
                []));
            return;
        }

        var verification = LicenseTokenVerifier.Verify(accepted.SobreFirmado);
        var valid = verification.Valid && verification.Payload is not null;
        if (valid)
        {
            try
            {
                ValidatePayload(
                    verification.Payload!,
                    new LicenseRuntimeSnapshot(
                        protectedState.InstallationId,
                        LicenseMachineStateProtector.GetFingerprint(protectedState),
                        accepted.LicenciaId,
                        protectedState.Serial,
                        true,
                        protectedState.LastObservedUtc,
                        clockSuspicious,
                        []),
                    requireNewSerial: false);
            }
            catch (LicenseOperationException ex)
            {
                _logger.LogError("Licencia almacenada rechazada al recargar: {Code}", ex.Code);
                valid = false;
            }
        }

        var configurations = await LoadConfigurationsAsync(cancellationToken);
        var grants = valid
            ? verification.Payload!.Modules.Select(module => new LicenseRuntimeGrant(
                LicenseModuleCodes.Find(module.Code)!.Code,
                module.StartsAtUtc,
                module.EndsAtUtc,
                configurations.GetValueOrDefault(LicenseModuleCodes.Find(module.Code)!.Code)))
                .ToArray()
            : [];

        _runtime.Replace(new LicenseRuntimeSnapshot(
            protectedState.InstallationId,
            LicenseMachineStateProtector.GetFingerprint(protectedState),
            valid ? accepted.LicenciaId : null,
            protectedState.Serial,
            valid,
            protectedState.LastObservedUtc,
            clockSuspicious,
            grants));
    }

    private static void ValidatePayload(
        LicenseTokenPayload payload,
        LicenseRuntimeSnapshot installation,
        bool requireNewSerial)
    {
        if (!string.Equals(payload.Product, Product, StringComparison.Ordinal))
            throw new LicenseOperationException("LIC_PRODUCT_INVALID", "La licencia corresponde a otro producto.");
        if (payload.FormatVersion != FormatVersion)
            throw new LicenseOperationException("LIC_VERSION_INVALID", "La versión del archivo de licencia no es compatible.");
        if (payload.LicenseId == Guid.Empty || payload.InstallationId == Guid.Empty)
            throw new LicenseOperationException("LIC_ID_INVALID", "La licencia no contiene identificadores válidos.");
        if (payload.InstallationId != installation.InstallationId ||
            !FixedEquals(payload.InstallationFingerprint, installation.InstallationFingerprint))
            throw new LicenseOperationException("LIC_INSTALLATION_MISMATCH", "La licencia fue emitida para otra instalación.");
        if (payload.Serial <= 0 || (requireNewSerial && payload.Serial <= installation.Serial) ||
            (!requireNewSerial && payload.Serial != installation.Serial))
            throw new LicenseOperationException("LIC_SERIAL_INVALID", "El serial de la licencia no es válido para esta instalación.");
        if (payload.IssuedAtUtc == default || payload.IssuedAtUtc > DateTimeOffset.UtcNow + FutureIssueTolerance)
            throw new LicenseOperationException("LIC_ISSUED_AT_INVALID", "La fecha de emisión de la licencia no es válida.");
        if (payload.Modules.Count > LicenseModuleCodes.All.Count)
            throw new LicenseOperationException("LIC_MODULE_COUNT_INVALID", "La licencia contiene demasiados módulos.");

        var distinctCodes = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        foreach (var module in payload.Modules)
        {
            var definition = LicenseModuleCodes.Find(module.Code)
                ?? throw new LicenseOperationException("LIC_MODULE_UNKNOWN", $"La licencia contiene el módulo desconocido '{module.Code}'.");
            if (!distinctCodes.Add(definition.Code))
                throw new LicenseOperationException("LIC_MODULE_DUPLICATED", $"El módulo '{definition.Code}' aparece más de una vez.");
            if (module.StartsAtUtc == default ||
                (module.EndsAtUtc.HasValue && module.EndsAtUtc.Value <= module.StartsAtUtc))
                throw new LicenseOperationException("LIC_MODULE_DATES_INVALID", $"Las fechas de '{definition.Code}' no son válidas.");
        }
    }

    private ProtectedLicenseState ValidateProtectedState(InstallationStateRow row)
    {
        if (!_protector.TryUnprotect(row.SelloProtegidoMaquina, out var state))
            throw new LicenseOperationException("LIC_STATE_UNPROTECTABLE", "No se pudo validar el estado protegido de la instalación.");
        if (state.InstallationId != row.InstallationId || state.Serial != row.SerialMinimoAceptado)
            throw new LicenseOperationException("LIC_STATE_MISMATCH", "El estado de licencia fue modificado fuera de la aplicación.");

        var fingerprint = LicenseMachineStateProtector.GetFingerprint(state);
        if (!FixedEquals(fingerprint, row.HuellaInstalacion))
            throw new LicenseOperationException("LIC_FINGERPRINT_MISMATCH", "La huella protegida de la instalación no coincide.");

        return state;
    }

    private async Task<InstallationStateRow?> LoadInstallationRowAsync(CancellationToken cancellationToken) =>
        await _context.Database
            .SqlQueryRaw<InstallationStateRow>(
                """
                SELECT [InstalacionId], [HuellaInstalacion], [SerialMinimoAceptado],
                       [UltimaHoraConfiableUtc], [EstadoReloj], [SelloProtegidoMaquina]
                FROM [LIC].[EstadoInstalacion]
                WHERE [PkidEstado] = 1;
                """)
            .SingleOrDefaultAsync(cancellationToken);

    private async Task<InstallationStateRow?> LoadInstallationRowForUpdateAsync(CancellationToken cancellationToken) =>
        await _context.Database
            .SqlQueryRaw<InstallationStateRow>(
                """
                SELECT [InstalacionId], [HuellaInstalacion], [SerialMinimoAceptado],
                       [UltimaHoraConfiableUtc], [EstadoReloj], [SelloProtegidoMaquina]
                FROM [LIC].[EstadoInstalacion] WITH (UPDLOCK, HOLDLOCK)
                WHERE [PkidEstado] = 1;
                """)
            .SingleOrDefaultAsync(cancellationToken);

    private async Task<HashSet<string>> LoadCurrentModuleCodesAsync(
        long serial,
        CancellationToken cancellationToken)
    {
        if (serial <= 0)
            return new HashSet<string>(StringComparer.OrdinalIgnoreCase);

        var values = await _context.Database
            .SqlQueryRaw<string>(
                """
                SELECT module.[CodigoModulo] AS [Value]
                FROM [LIC].[LicenciaModulo] module
                INNER JOIN [LIC].[LicenciaImportada] license
                    ON license.[PkidLicenciaImportada] = module.[FkidLicenciaImportada]
                WHERE license.[InstalacionId] = @InstalacionId
                  AND license.[Serial] = @Serial;
                """,
                new SqlParameter("@InstalacionId", _runtime.GetRuntimeSnapshot().InstallationId),
                new SqlParameter("@Serial", serial))
            .ToListAsync(cancellationToken);

        return values.ToHashSet(StringComparer.OrdinalIgnoreCase);
    }

    private async Task<Dictionary<string, bool>> LoadConfigurationsAsync(CancellationToken cancellationToken)
    {
        var rows = await _context.Database
            .SqlQueryRaw<ModuleConfigurationRow>(
                """
                SELECT [CodigoModulo], [ActivoOperativo]
                FROM [LIC].[ConfiguracionModulo];
                """)
            .ToListAsync(cancellationToken);

        return rows.ToDictionary(row => row.CodigoModulo, row => row.ActivoOperativo, StringComparer.OrdinalIgnoreCase);
    }

    private async Task RecordRejectedImportAsync(
        int operatorUserId,
        string code,
        CancellationToken cancellationToken)
    {
        try
        {
            await InsertEventAsync(
                null,
                "IMPORTACION_RECHAZADA",
                null,
                code,
                operatorUserId.ToString(),
                "WEB",
                cancellationToken);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "No se pudo registrar un rechazo de licencia. Code={Code}", code);
        }
    }

    private Task<int> InsertEventAsync(
        long? importedLicenseId,
        string type,
        string? moduleCode,
        string? detail,
        string actor,
        string source,
        CancellationToken cancellationToken) =>
        ExecuteAsync(
            """
            INSERT INTO [LIC].[EventoLicencia]
                ([FkidLicenciaImportada], [Tipo], [CodigoModulo], [DetalleSeguro], [Actor], [Origen])
            VALUES
                (@LicenciaId, @Tipo, @CodigoModulo, @Detalle, @Actor, @Origen);
            """,
            cancellationToken,
            new SqlParameter("@LicenciaId", importedLicenseId ?? (object)DBNull.Value),
            new SqlParameter("@Tipo", type),
            new SqlParameter("@CodigoModulo", moduleCode ?? (object)DBNull.Value),
            new SqlParameter("@Detalle", detail ?? (object)DBNull.Value),
            new SqlParameter("@Actor", actor),
            new SqlParameter("@Origen", source));

    private Task<int> ExecuteAsync(string sql, CancellationToken cancellationToken, params object[] parameters) =>
        _context.Database.ExecuteSqlRawAsync(sql, parameters, cancellationToken);

    private static bool FixedEquals(string left, string right)
    {
        var leftBytes = Encoding.UTF8.GetBytes(left ?? string.Empty);
        var rightBytes = Encoding.UTF8.GetBytes(right ?? string.Empty);
        return leftBytes.Length == rightBytes.Length &&
               CryptographicOperations.FixedTimeEquals(leftBytes, rightBytes);
    }

    private static DateTimeOffset ToUtc(DateTime value) =>
        new(DateTime.SpecifyKind(value, DateTimeKind.Utc));

    private sealed class InstallationStateRow
    {
        public Guid InstallationId { get; set; }
        public string HuellaInstalacion { get; set; } = string.Empty;
        public long SerialMinimoAceptado { get; set; }
        public DateTime UltimaHoraConfiableUtc { get; set; }
        public string EstadoReloj { get; set; } = string.Empty;
        public string SelloProtegidoMaquina { get; set; } = string.Empty;
    }

    private sealed class AcceptedLicenseRow
    {
        public Guid LicenciaId { get; set; }
        public long Serial { get; set; }
        public string SobreFirmado { get; set; } = string.Empty;
    }

    private sealed class ModuleConfigurationRow
    {
        public string CodigoModulo { get; set; } = string.Empty;
        public bool ActivoOperativo { get; set; }
    }
}
