using EG.Application.Interfaces.Contabilidad;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class PolizaService
        : AdquisicionCrudAppService<Poliza, VwPoliza, PolizaDto, PolizaResponse>,
            IPolizaService
    {
        private readonly EGestionContext _context;
        private readonly ILogger<PolizaService> _logger;

        public PolizaService(
            GenericService<Poliza, PolizaDto, PolizaResponse> service,
            GenericService<VwPoliza, PolizaDto, PolizaResponse> serviceView,
            EGestionContext context,
            ILogger<PolizaService> logger)
            : base(
                service,
                serviceView,
                "PkidPoliza",
                "Poliza",
                (dto, id) => dto.PkidPoliza = id)
        {
            _context = context;
            _logger = logger;
        }

        public override Task<PagedResult<PolizaResponse>> CreateAsync(PolizaResponse response, int usuarioActual)
        {
            response.FechaPoliza = response.FechaPoliza == default ? DateTime.Today : response.FechaPoliza;
            response.EstaBalanceado = false;
            response.PermitirModificar ??= true;
            response.Autorizado ??= false;

            return base.CreateAsync(response, usuarioActual);
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                var poliza = await _context.Polizas
                    .Include(x => x.PolizaDetalles)
                    .FirstOrDefaultAsync(x => x.PkidPoliza == id && x.Activo);

                if (poliza == null)
                {
                    return NotFound(id);
                }

                var now = DateTime.Now;
                poliza.Activo = false;
                poliza.UsuarioModificacion = usuarioActual;
                poliza.FechaModificacion = now;

                foreach (var detalle in poliza.PolizaDetalles.Where(x => x.Activo))
                {
                    detalle.Activo = false;
                    detalle.UsuarioModificacion = usuarioActual;
                    detalle.FechaModificacion = now;
                }

                await _context.SaveChangesAsync();

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Poliza eliminada correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar Poliza: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PolizaAiImportPreviewResponse>> PreviewAiImportAsync(PolizaAiImportUploadRequest request, int usuarioActual)
        {
            if (request.Contenido.Length == 0)
                return FailurePreview("El archivo es requerido.", "INVALID_FILE");

            var extension = Path.GetExtension(request.NombreOriginal).ToLowerInvariant();
            if (extension is not ".xlsx" and not ".csv" and not ".txt")
                return FailurePreview("Para importar polizas usa un archivo Excel (.xlsx), CSV o TXT con columnas Cuenta, Concepto, Debe y Haber.", "UNSUPPORTED_FILE");

            var parsed = PolizaAiImportParser.Parse(request.NombreOriginal, request.Contenido);
            var preview = await BuildImportPreviewAsync(
                request.NombreOriginal,
                request.HeaderFallback,
                parsed.Details,
                parsed.HeaderValues,
                parsed.Messages,
                parsed.DetectedColumns,
                validateDuplicateClave: true);

            _logger.LogInformation(
                "Preview IA poliza. Usuario={Usuario}; Archivo={Archivo}; Detalles={Detalles}; Debe={Debe}; Haber={Haber}; CanImport={CanImport}",
                usuarioActual,
                request.NombreOriginal,
                preview.Details.Count,
                preview.TotalDebe,
                preview.TotalHaber,
                preview.CanImport);

            return SuccessPreview(preview.CanImport
                    ? "Archivo analizado. La poliza esta cuadrada y lista para importar."
                    : "Archivo analizado con observaciones. Corrige los errores antes de importar.",
                preview);
        }

        public async Task<PagedResult<PolizaAiImportPreviewResponse>> ConfirmAiImportAsync(PolizaAiImportConfirmRequest request, int usuarioActual)
        {
            var preview = await BuildImportPreviewAsync(
                request.SourceFileName,
                request.Header,
                request.Details,
                new Dictionary<string, string>(),
                [],
                [],
                validateDuplicateClave: true);

            if (!preview.CanImport)
                return FailurePreview("La poliza no puede importarse porque tiene errores de validacion.", "VALIDATION", preview);

            var strategy = _context.Database.CreateExecutionStrategy();
            try
            {
                return await strategy.ExecuteAsync(async () =>
                {
                    await using var transaction = await _context.Database.BeginTransactionAsync();

                    var now = DateTime.Now;
                    var poliza = new Poliza
                    {
                        FkidAnioSis = preview.Header.FkidAnioSis!.Value,
                        FkidMesSis = preview.Header.FkidMesSis!.Value,
                        FkidTipoPolizaSis = preview.Header.FkidTipoPolizaSis!.Value,
                        ClavePoliza = preview.Header.ClavePoliza!,
                        NombrePoliza = preview.Header.NombrePoliza!,
                        FechaPoliza = preview.Header.FechaPoliza!.Value,
                        EstaBalanceado = true,
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioActual,
                        PermitirModificar = preview.Header.PermitirModificar,
                        Autorizado = preview.Header.Autorizado
                    };

                    _context.Polizas.Add(poliza);
                    await _context.SaveChangesAsync();

                    foreach (var detail in preview.Details)
                    {
                        _context.PolizaDetalles.Add(new PolizaDetalle
                        {
                            FkidPolizaConta = poliza.PkidPoliza,
                            FkidCuentaContableConta = detail.FkidCuentaContableConta!.Value,
                            FkidTipoDetallePolizaSis = detail.FkidTipoDetallePolizaSis,
                            Descripcion = string.IsNullOrWhiteSpace(detail.Descripcion) ? null : detail.Descripcion.Trim(),
                            ImporteDebe = detail.ImporteDebe.GetValueOrDefault() == 0m ? null : detail.ImporteDebe,
                            ImporteHaber = detail.ImporteHaber.GetValueOrDefault() == 0m ? null : detail.ImporteHaber,
                            Activo = true,
                            FechaCreacion = now,
                            UsuarioCreacion = usuarioActual
                        });
                    }

                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();

                    preview.ImportedPolizaId = poliza.PkidPoliza;
                    var view = await _context.VwPolizas.AsNoTracking()
                        .FirstOrDefaultAsync(x => x.PkidPoliza == poliza.PkidPoliza);
                    preview.Poliza = view?.Adapt<PolizaResponse>() ?? poliza.Adapt<PolizaResponse>();

                    _logger.LogInformation(
                        "Poliza importada con IA. Usuario={Usuario}; PolizaId={PolizaId}; Clave={Clave}; Detalles={Detalles}; Archivo={Archivo}",
                        usuarioActual,
                        poliza.PkidPoliza,
                        poliza.ClavePoliza,
                        preview.Details.Count,
                        request.SourceFileName);

                    return SuccessPreview("Poliza importada correctamente con validacion previa.", preview);
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al importar poliza con IA. Usuario={Usuario}; Archivo={Archivo}", usuarioActual, request.SourceFileName);
                return FailurePreview($"Error al importar poliza: {ex.InnerException?.Message ?? ex.Message}", "ERROR", preview);
            }
        }

        private static PagedResult<bool> NotFound(int id) => new()
        {
            Success = false,
            Message = $"Poliza con ID {id} no encontrada",
            Code = "NOT_FOUND",
            Data = false,
            TotalCount = 0
        };

        private async Task<PolizaAiImportPreviewResponse> BuildImportPreviewAsync(
            string sourceFileName,
            PolizaAiImportHeaderRequest fallback,
            IEnumerable<PolizaAiImportDetailRequest> rawDetails,
            IReadOnlyDictionary<string, string> detectedHeaderValues,
            IEnumerable<PolizaAiImportValidationMessage> parserMessages,
            IEnumerable<string> detectedColumns,
            bool validateDuplicateClave)
        {
            var preview = new PolizaAiImportPreviewResponse
            {
                SourceFileName = sourceFileName,
                Header = MergeHeader(sourceFileName, fallback, detectedHeaderValues),
                DetectedColumns = detectedColumns.ToList(),
                Messages = parserMessages.ToList()
            };

            await ResolveHeaderAsync(preview, validateDuplicateClave);
            await ResolveDetailsAsync(preview, rawDetails);

            preview.TotalDebe = preview.Details.Sum(x => x.ImporteDebe ?? 0m);
            preview.TotalHaber = preview.Details.Sum(x => x.ImporteHaber ?? 0m);
            preview.Diferencia = decimal.Round(preview.TotalDebe - preview.TotalHaber, 2);
            preview.EstaCuadrada = preview.Details.Count > 0 && preview.Diferencia == 0m;

            if (preview.Details.Count == 0)
                AddError(preview, "NO_DETAILS", "La poliza debe tener al menos un movimiento.");

            if (preview.Details.Count > 0 && !preview.EstaCuadrada)
                AddError(preview, "POLIZA_DESCUADRADA", $"La poliza no esta cuadrada. Debe {preview.TotalDebe:0.00}, Haber {preview.TotalHaber:0.00}, Diferencia {preview.Diferencia:0.00}.");

            preview.CanImport = !preview.Messages.Any(x => x.Severity.Equals("Error", StringComparison.OrdinalIgnoreCase));
            return preview;
        }

        private static PolizaAiImportHeaderRequest MergeHeader(
            string sourceFileName,
            PolizaAiImportHeaderRequest fallback,
            IReadOnlyDictionary<string, string> detected)
        {
            var detectedDate = PolizaAiImportParser.ParseDate(GetDetected(detected, "FechaPoliza"));
            var fallbackDate = fallback.FechaPoliza?.Date;
            var fecha = fallbackDate ?? detectedDate ?? DateTime.Today;
            var clave = FirstNonEmpty(fallback.ClavePoliza, GetDetected(detected, "ClavePoliza"), Path.GetFileNameWithoutExtension(sourceFileName));
            var nombre = FirstNonEmpty(fallback.NombrePoliza, GetDetected(detected, "NombrePoliza"), $"Poliza importada {Path.GetFileNameWithoutExtension(sourceFileName)}");

            return new PolizaAiImportHeaderRequest
            {
                FkidEmpresaSis = PositiveOrNull(fallback.FkidEmpresaSis),
                FkidAnioSis = PositiveOrNull(fallback.FkidAnioSis),
                Anio = fallback.Anio ?? ParseInt(GetDetected(detected, "Anio")) ?? fecha.Year,
                FkidMesSis = PositiveOrNull(fallback.FkidMesSis)
                    ?? PolizaAiImportParser.ParseMonth(fallback.Mes)
                    ?? PolizaAiImportParser.ParseMonth(GetDetected(detected, "Mes"))
                    ?? fecha.Month,
                Mes = FirstNonEmpty(fallback.Mes, GetDetected(detected, "Mes")),
                FkidTipoPolizaSis = PositiveOrNull(fallback.FkidTipoPolizaSis),
                TipoPoliza = FirstNonEmpty(fallback.TipoPoliza, GetDetected(detected, "TipoPoliza")),
                ClavePoliza = clave,
                NombrePoliza = nombre,
                FechaPoliza = fecha,
                PermitirModificar = fallback.PermitirModificar,
                Autorizado = fallback.Autorizado
            };
        }

        private async Task ResolveHeaderAsync(PolizaAiImportPreviewResponse preview, bool validateDuplicateClave)
        {
            var header = preview.Header;

            if (!header.FkidEmpresaSis.HasValue || header.FkidEmpresaSis <= 0)
                AddError(preview, "EMPRESA_REQUIRED", "Debe existir una empresa seleccionada para validar las cuentas contables.", field: "FkidEmpresaSis");

            if (!header.FkidAnioSis.HasValue && header.Anio.HasValue)
            {
                var anio = await _context.Anios.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.Clave == header.Anio.Value && x.Activo);
                header.FkidAnioSis = anio?.PkidAnio;
            }

            if (!header.FkidAnioSis.HasValue || header.FkidAnioSis <= 0)
                AddError(preview, "ANIO_REQUIRED", "No se pudo resolver el anio presupuestal de la poliza.", field: "Anio");
            else
            {
                var anio = await _context.Anios.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidAnio == header.FkidAnioSis.Value && x.Activo);
                if (anio == null)
                    AddError(preview, "ANIO_INVALID", $"El anio {header.FkidAnioSis} no existe o esta inactivo.", field: "Anio");
                else
                    header.Anio = anio.Clave;
            }

            if (!header.FkidMesSis.HasValue || header.FkidMesSis is < 1 or > 12)
                AddError(preview, "MES_INVALID", "El mes de la poliza debe estar entre 1 y 12.", field: "Mes");

            if (!header.FkidTipoPolizaSis.HasValue && !string.IsNullOrWhiteSpace(header.TipoPoliza))
            {
                var normalized = NormalizeText(header.TipoPoliza);
                var tipo = await _context.TipoPolizas.AsNoTracking()
                    .Where(x => x.Activo)
                    .FirstOrDefaultAsync(x => x.Descripcion.ToLower().Contains(header.TipoPoliza!.Trim().ToLower()));
                if (tipo == null)
                {
                    var tipos = await _context.TipoPolizas.AsNoTracking().Where(x => x.Activo).ToListAsync();
                    tipo = tipos.FirstOrDefault(x => NormalizeText(x.Descripcion) == normalized);
                }

                header.FkidTipoPolizaSis = tipo?.PkidTipoPoliza;
                header.TipoPoliza = tipo?.Descripcion ?? header.TipoPoliza;
            }

            if (!header.FkidTipoPolizaSis.HasValue || header.FkidTipoPolizaSis <= 0)
                AddError(preview, "TIPO_POLIZA_REQUIRED", "Selecciona o incluye un tipo de poliza valido.", field: "TipoPoliza");
            else
            {
                var tipo = await _context.TipoPolizas.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidTipoPoliza == header.FkidTipoPolizaSis.Value && x.Activo);
                if (tipo == null)
                    AddError(preview, "TIPO_POLIZA_INVALID", $"El tipo de poliza {header.FkidTipoPolizaSis} no existe o esta inactivo.", field: "TipoPoliza");
                else
                    header.TipoPoliza = tipo.Descripcion;
            }

            header.ClavePoliza = (header.ClavePoliza ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(header.ClavePoliza))
                AddError(preview, "CLAVE_REQUIRED", "La clave de poliza es requerida.", field: "ClavePoliza");

            if (header.ClavePoliza.Length > 10)
            {
                AddWarning(preview, "CLAVE_TRUNCATED", $"La clave excede 10 caracteres y se tomara como {header.ClavePoliza[..10]}.", field: "ClavePoliza");
                header.ClavePoliza = header.ClavePoliza[..10];
            }

            if (validateDuplicateClave && !string.IsNullOrWhiteSpace(header.ClavePoliza))
            {
                var exists = await _context.Polizas.AsNoTracking()
                    .AnyAsync(x => x.Activo && x.ClavePoliza == header.ClavePoliza);
                if (exists)
                    AddError(preview, "CLAVE_DUPLICADA", $"Ya existe una poliza activa con clave {header.ClavePoliza}.", field: "ClavePoliza");
            }

            header.NombrePoliza = (header.NombrePoliza ?? string.Empty).Trim();
            if (string.IsNullOrWhiteSpace(header.NombrePoliza))
                AddError(preview, "NOMBRE_REQUIRED", "El nombre de la poliza es requerido.", field: "NombrePoliza");
            if (header.NombrePoliza.Length > 1000)
                header.NombrePoliza = header.NombrePoliza[..1000];

            header.FechaPoliza ??= DateTime.Today;
        }

        private async Task ResolveDetailsAsync(PolizaAiImportPreviewResponse preview, IEnumerable<PolizaAiImportDetailRequest> rawDetails)
        {
            var empresaId = preview.Header.FkidEmpresaSis;
            var accounts = await _context.CuentaContables.AsNoTracking()
                .Where(x => x.Activo && (!empresaId.HasValue || empresaId <= 0 || x.FkidEmpresaSis == empresaId.Value))
                .Select(x => new AccountCandidate
                {
                    PkidCuentaContable = x.PkidCuentaContable,
                    Cuenta = x.Cuenta,
                    ClaveOrd = x.ClaveOrd,
                    CtaCoi = x.CtaCoi,
                    Descripcion = x.Descripcion,
                    IsCuentaDetalle = x.IsCuentaDetalle
                })
                .ToListAsync();

            var accountMap = new Dictionary<string, AccountCandidate>(StringComparer.OrdinalIgnoreCase);
            var accountById = accounts.ToDictionary(x => x.PkidCuentaContable);
            foreach (var account in accounts)
            {
                AddAccountKey(accountMap, account.Cuenta, account);
                AddAccountKey(accountMap, account.ClaveOrd, account);
                AddAccountKey(accountMap, account.CtaCoi, account);
            }

            var tipoDetalles = await _context.TipoDetallePolizas.AsNoTracking()
                .Where(x => x.Activo)
                .Select(x => new TipoDetalleCandidate
                {
                    PkIdTipoDetallePoliza = x.PkIdTipoDetallePoliza,
                    Descripcion = x.Descripcion
                })
                .ToListAsync();

            foreach (var raw in rawDetails)
            {
                var detail = new PolizaAiImportDetailRequest
                {
                    RowNumber = raw.RowNumber,
                    Cuenta = raw.Cuenta?.Trim() ?? string.Empty,
                    FkidCuentaContableConta = raw.FkidCuentaContableConta,
                    Descripcion = string.IsNullOrWhiteSpace(raw.Descripcion) ? null : raw.Descripcion.Trim(),
                    FkidTipoDetallePolizaSis = raw.FkidTipoDetallePolizaSis,
                    TipoDetallePoliza = string.IsNullOrWhiteSpace(raw.TipoDetallePoliza) ? null : raw.TipoDetallePoliza.Trim(),
                    ImporteDebe = NormalizeMoney(raw.ImporteDebe),
                    ImporteHaber = NormalizeMoney(raw.ImporteHaber)
                };

                ResolveAccount(preview, detail, accountMap, accountById);
                ResolveTipoDetalle(detail, tipoDetalles);
                ValidateDetail(preview, detail);
                preview.Details.Add(detail);
            }
        }

        private static void ResolveAccount(
            PolizaAiImportPreviewResponse preview,
            PolizaAiImportDetailRequest detail,
            IReadOnlyDictionary<string, AccountCandidate> accountMap,
            IReadOnlyDictionary<int, AccountCandidate> accountById)
        {
            if (detail.FkidCuentaContableConta.HasValue)
            {
                if (!accountById.TryGetValue(detail.FkidCuentaContableConta.Value, out var accountByIdMatch))
                {
                    AddError(preview, "ACCOUNT_NOT_FOUND", $"No se encontro la cuenta contable {detail.FkidCuentaContableConta}.", detail.RowNumber, "Cuenta");
                    return;
                }

                SetAccount(detail, accountByIdMatch);
                if (accountByIdMatch.IsCuentaDetalle != 1)
                    AddWarning(preview, "ACCOUNT_NOT_DETAIL", $"La cuenta {accountByIdMatch.Cuenta} no esta marcada como cuenta de detalle.", detail.RowNumber, "Cuenta");

                return;
            }

            if (string.IsNullOrWhiteSpace(detail.Cuenta))
            {
                AddError(preview, "ACCOUNT_REQUIRED", "La cuenta contable es requerida.", detail.RowNumber, "Cuenta");
                return;
            }

            var key = PolizaAiImportParser.NormalizeAccountKey(detail.Cuenta);
            if (!accountMap.TryGetValue(key, out var account))
            {
                AddError(preview, "ACCOUNT_NOT_FOUND", $"No se encontro la cuenta contable {detail.Cuenta}.", detail.RowNumber, "Cuenta");
                return;
            }

            SetAccount(detail, account);
            if (account.IsCuentaDetalle != 1)
                AddWarning(preview, "ACCOUNT_NOT_DETAIL", $"La cuenta {account.Cuenta} no esta marcada como cuenta de detalle.", detail.RowNumber, "Cuenta");
        }

        private static void SetAccount(PolizaAiImportDetailRequest detail, AccountCandidate account)
        {
            detail.FkidCuentaContableConta = account.PkidCuentaContable;
            detail.Cuenta = account.Cuenta ?? detail.Cuenta;
            detail.CuentaDescripcion = account.Descripcion;
        }

        private static void ResolveTipoDetalle(PolizaAiImportDetailRequest detail, IEnumerable<TipoDetalleCandidate> tipoDetalles)
        {
            if (detail.FkidTipoDetallePolizaSis.HasValue || string.IsNullOrWhiteSpace(detail.TipoDetallePoliza))
                return;

            var normalized = NormalizeText(detail.TipoDetallePoliza);
            var tipo = tipoDetalles.FirstOrDefault(x => NormalizeText(x.Descripcion) == normalized);
            if (tipo != null)
            {
                detail.FkidTipoDetallePolizaSis = tipo.PkIdTipoDetallePoliza;
                detail.TipoDetallePoliza = tipo.Descripcion;
            }
        }

        private static void ValidateDetail(PolizaAiImportPreviewResponse preview, PolizaAiImportDetailRequest detail)
        {
            var debe = detail.ImporteDebe ?? 0m;
            var haber = detail.ImporteHaber ?? 0m;

            if (debe < 0m || haber < 0m)
                AddError(preview, "NEGATIVE_AMOUNT", "Los importes de debe y haber no pueden ser negativos.", detail.RowNumber);

            if (debe == 0m && haber == 0m)
                AddError(preview, "AMOUNT_REQUIRED", "Captura un importe en debe o en haber.", detail.RowNumber);

            if (debe > 0m && haber > 0m)
                AddError(preview, "DOUBLE_AMOUNT", "Un movimiento no puede tener importe en debe y haber al mismo tiempo.", detail.RowNumber);
        }

        private static decimal? NormalizeMoney(decimal? value)
        {
            if (!value.HasValue || value.Value == 0m)
                return null;

            return decimal.Round(value.Value, 2);
        }

        private static void AddAccountKey(IDictionary<string, AccountCandidate> map, string? value, AccountCandidate account)
        {
            var key = PolizaAiImportParser.NormalizeAccountKey(value);
            if (!string.IsNullOrWhiteSpace(key))
                map.TryAdd(key, account);
        }

        private static void AddError(PolizaAiImportPreviewResponse preview, string code, string message, int? rowNumber = null, string? field = null)
            => preview.Messages.Add(new PolizaAiImportValidationMessage
            {
                Severity = "Error",
                Code = code,
                Message = message,
                RowNumber = rowNumber,
                Field = field
            });

        private static void AddWarning(PolizaAiImportPreviewResponse preview, string code, string message, int? rowNumber = null, string? field = null)
            => preview.Messages.Add(new PolizaAiImportValidationMessage
            {
                Severity = "Warning",
                Code = code,
                Message = message,
                RowNumber = rowNumber,
                Field = field
            });

        private static PagedResult<PolizaAiImportPreviewResponse> SuccessPreview(string message, PolizaAiImportPreviewResponse preview) => new()
        {
            Success = true,
            Message = message,
            Code = "SUCCESS",
            Data = preview,
            Items = [preview],
            TotalCount = 1
        };

        private static PagedResult<PolizaAiImportPreviewResponse> FailurePreview(string message, string code, PolizaAiImportPreviewResponse? preview = null) => new()
        {
            Success = false,
            Message = message,
            Code = code,
            Data = preview,
            Items = preview == null ? [] : [preview],
            TotalCount = preview == null ? 0 : 1
        };

        private static string GetDetected(IReadOnlyDictionary<string, string> values, string key)
            => values.TryGetValue(key, out var value) ? value : string.Empty;

        private static string FirstNonEmpty(params string?[] values)
            => values.FirstOrDefault(value => !string.IsNullOrWhiteSpace(value))?.Trim() ?? string.Empty;

        private static int? ParseInt(string? value)
            => int.TryParse(value, out var parsed) ? parsed : null;

        private static int? PositiveOrNull(int? value)
            => value.GetValueOrDefault() > 0 ? value : null;

        private static string NormalizeText(string? value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return string.Empty;

            var normalized = value.Normalize(System.Text.NormalizationForm.FormD);
            var chars = normalized
                .Where(ch => System.Globalization.CharUnicodeInfo.GetUnicodeCategory(ch) != System.Globalization.UnicodeCategory.NonSpacingMark)
                .Select(char.ToLowerInvariant)
                .ToArray();

            return new string(chars).Normalize(System.Text.NormalizationForm.FormC).Trim();
        }

        private sealed class AccountCandidate
        {
            public int PkidCuentaContable { get; init; }
            public string? Cuenta { get; init; }
            public string? ClaveOrd { get; init; }
            public string? CtaCoi { get; init; }
            public string? Descripcion { get; init; }
            public int IsCuentaDetalle { get; init; }
        }

        private sealed class TipoDetalleCandidate
        {
            public int PkIdTipoDetallePoliza { get; init; }
            public string? Descripcion { get; init; }
        }
    }
}
