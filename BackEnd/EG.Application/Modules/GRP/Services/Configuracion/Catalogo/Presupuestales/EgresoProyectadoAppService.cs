using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class EgresoProyectadoAppService
        : AdquisicionCrudAppService<EgresoProyectado, VwEgresoProyectado, EgresoProyectadoDto, EgresoProyectadoResponse>,
            IEgresoProyectadoAppService
    {
        public EgresoProyectadoAppService(
            GenericService<EgresoProyectado, EgresoProyectadoDto, EgresoProyectadoResponse> service,
            GenericService<VwEgresoProyectado, EgresoProyectadoDto, EgresoProyectadoResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext,
            ILogger<EgresoProyectadoAppService> logger)
            : base(
                service,
                serviceView,
                "PkidEgresoProyectado",
                "Anteproyecto de egresos",
                (dto, id) => dto.PkidEgresoProyectado = id)
        {
            _context = context;
            _userContext = userContext;
            _logger = logger;
        }

        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;
        private readonly ILogger<EgresoProyectadoAppService> _logger;

        public override Task<PagedResult<EgresoProyectadoResponse>> CreateAsync(EgresoProyectadoResponse response, int usuarioActual)
        {
            response.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
            ClearMonthsBeforeStartDate(response);
            var validation = ValidateAmounts(response);
            if (validation != null)
                return Task.FromResult(validation);

            return base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<EgresoProyectadoResponse>> UpdateAsync(int id, EgresoProyectadoResponse response, int usuarioActual)
        {
            if (await IsAuthorizedAsync(id))
            {
                return Locked(id, "El anteproyecto ya fue autorizado y no puede editarse.");
            }

            response.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
            ClearMonthsBeforeStartDate(response);
            var validation = ValidateAmounts(response);
            if (validation != null)
                return validation;

            return await base.UpdateAsync(id, response, usuarioActual);
        }

        private PagedResult<EgresoProyectadoResponse>? ValidateAmounts(EgresoProyectadoResponse response)
        {
            var months = new[]
            {
                response.Enero, response.Febrero, response.Marzo, response.Abril,
                response.Mayo, response.Junio, response.Julio, response.Agosto,
                response.Septiembre, response.Octubre, response.Noviembre, response.Diciembre
            };

            if (months.Any(amount => amount < 0m))
                return Failure<EgresoProyectadoResponse>("Los importes mensuales del anteproyecto no pueden ser negativos.", "INVALID_AMOUNT");

            var total = months.Sum();
            if (total <= 0m)
                return Failure<EgresoProyectadoResponse>("El anteproyecto debe contener al menos un importe mensual mayor a cero.", "INVALID_AMOUNT");

            response.Total = total;
            return null;
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            if (await IsAuthorizedAsync(id))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "El anteproyecto ya fue autorizado y no puede eliminarse.",
                    Code = "LOCKED",
                    Data = false,
                    TotalCount = 0
                };
            }

            return await base.DeleteAsync(id);
        }

        public async Task<PagedResult<bool>> EstaAutorizadoAsync(int id)
        {
            var isAuthorized = await IsAuthorizedAsync(id);
            return new PagedResult<bool>
            {
                Success = true,
                Message = isAuthorized ? "El anteproyecto esta autorizado." : "El anteproyecto no esta autorizado.",
                Code = "SUCCESS",
                Data = isAuthorized,
                Items = new List<bool> { isAuthorized },
                TotalCount = 1
            };
        }

        public Task<PagedResult<LookupItem>> GetFuenteFinanciamientoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.FuenteFinanciamientos
                .AsNoTracking()
                .Where(x => x.Activo && (x.Clave ?? string.Empty).Trim() != "6");

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidFuenteFinanciamiento, Text = BuildText(x.Clave, x.Descripcion) },
                "Fuentes de financiamiento obtenidas correctamente");
        }

        public Task<PagedResult<LookupItem>> GetTipoGastoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.TipoGastos
                .AsNoTracking()
                .Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x => EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidTipoGasto, Text = BuildText(x.Clave, x.Descripcion) },
                "Tipos de gasto obtenidos correctamente");
        }

        public Task<PagedResult<LookupItem>> GetDigitoIdentificadorLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.DigitoIdentificadors
                .AsNoTracking()
                .Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidDigitoIdentificador, Text = BuildText(x.Clave, x.Descripcion) },
                "Digitos identificadores obtenidos correctamente");
        }

        public Task<PagedResult<LookupItem>> GetDestinoGastoLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.DestinoGastos
                .AsNoTracking()
                .Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidDestinoGasto, Text = BuildText(x.Clave, x.Descripcion) },
                "Destinos de gasto obtenidos correctamente");
        }

        public Task<PagedResult<LookupItem>> GetPyLookupPaginadoAsync(int page, int pageSize, string? filter)
        {
            var query = _context.Pies
                .AsNoTracking()
                .Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(filter))
            {
                var term = $"%{filter.Trim()}%";
                query = query.Where(x =>
                    EF.Functions.Like(x.Clave ?? string.Empty, term) ||
                    EF.Functions.Like(x.Descripcion ?? string.Empty, term) ||
                    EF.Functions.Like(x.NombreProyecto ?? string.Empty, term));
            }

            query = query.OrderBy(x => x.Clave).ThenBy(x => x.Descripcion);

            return ToLookupResultAsync(
                query,
                page,
                pageSize,
                x => new LookupItem { Id = x.PkidPy, Text = BuildText(x.Clave, x.Descripcion) },
                "Proyectos PY obtenidos correctamente");
        }

        public async Task<PagedResult<EgresoProyectadoAiImportPreviewResponse>> PreviewAiImportAsync(EgresoProyectadoAiImportUploadRequest request, int usuarioActual)
        {
            if (request.Contenido.Length == 0)
                return FailurePreview("El archivo es requerido.", "INVALID_FILE");

            var extension = Path.GetExtension(request.NombreOriginal).ToLowerInvariant();
            if (extension is not ".xlsx" and not ".csv" and not ".txt")
                return FailurePreview("Para importar anteproyecto usa un archivo Excel (.xlsx), CSV o TXT.", "UNSUPPORTED_FILE");

            var parsed = EgresoProyectadoAiImportParser.Parse(request.NombreOriginal, request.Contenido);
            var preview = await BuildImportPreviewAsync(
                request.NombreOriginal,
                request.HeaderFallback,
                parsed.Rows,
                parsed.HeaderValues,
                parsed.Messages,
                parsed.DetectedColumns);

            _logger.LogInformation(
                "Preview IA anteproyecto. Usuario={Usuario}; Archivo={Archivo}; Filas={Filas}; Total={Total}; CanImport={CanImport}",
                usuarioActual,
                request.NombreOriginal,
                preview.Rows.Count,
                preview.Total,
                preview.CanImport);

            return SuccessPreview(preview.CanImport
                    ? "Archivo analizado. El anteproyecto esta listo para importar."
                    : "Archivo analizado con observaciones. Corrige los errores antes de importar.",
                preview);
        }

        public async Task<PagedResult<EgresoProyectadoAiImportPreviewResponse>> ConfirmAiImportAsync(EgresoProyectadoAiImportConfirmRequest request, int usuarioActual)
        {
            var preview = await BuildImportPreviewAsync(
                request.SourceFileName,
                request.Header,
                request.Rows,
                new Dictionary<string, string>(),
                [],
                []);

            if (!preview.CanImport)
                return FailurePreview("El anteproyecto no puede importarse porque tiene errores de validacion.", "VALIDATION", preview);

            var strategy = _context.Database.CreateExecutionStrategy();
            try
            {
                return await strategy.ExecuteAsync(async () =>
                {
                    await using var transaction = await _context.Database.BeginTransactionAsync();

                    var now = DateTime.Now;
                    var empresaId = _userContext.GetCurrentEmpresaId();
                    var entities = preview.Rows.Select(row => new EgresoProyectado
                    {
                        FkidEmpresaSis = empresaId,
                        FkidProgramaPres = row.FkidProgramaPres!.Value,
                        FkidPartidaConta = row.FkidPartidaConta!.Value,
                        FkidAreaSis = row.FkidAreaSis!.Value,
                        Descripcion = row.Descripcion?.Trim() ?? string.Empty,
                        Fecha = DateOnly.FromDateTime(row.Fecha ?? preview.Header.Fecha ?? DateTime.Today),
                        FkidFuenteFinanciamientoPres = row.FkidFuenteFinanciamientoPres,
                        FkidTipoGastoPres = row.FkidTipoGastoPres,
                        FkidDigitoIdentificadorPres = row.FkidDigitoIdentificadorPres,
                        FkidDestinoGastoPres = row.FkidDestinoGastoPres,
                        FkidPyPres = row.FkidPyPres,
                        Enero = row.Enero,
                        Febrero = row.Febrero,
                        Marzo = row.Marzo,
                        Abril = row.Abril,
                        Mayo = row.Mayo,
                        Junio = row.Junio,
                        Julio = row.Julio,
                        Agosto = row.Agosto,
                        Septiembre = row.Septiembre,
                        Octubre = row.Octubre,
                        Noviembre = row.Noviembre,
                        Diciembre = row.Diciembre,
                        Total = row.Total,
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioActual
                    }).ToList();

                    _context.EgresoProyectados.AddRange(entities);
                    await _context.SaveChangesAsync();
                    await transaction.CommitAsync();

                    preview.ImportedIds = entities.Select(x => x.PkidEgresoProyectado).ToList();
                    preview.ImportedCount = preview.ImportedIds.Count;
                    var importedViews = await _context.VwEgresoProyectados.AsNoTracking()
                        .Where(x => x.FkidEmpresaSis == empresaId && preview.ImportedIds.Contains(x.PkidEgresoProyectado))
                        .ToListAsync();
                    preview.ImportedRows = importedViews.Select(x => x.Adapt<EgresoProyectadoResponse>()).ToList();

                    _logger.LogInformation(
                        "Anteproyecto importado con IA. Usuario={Usuario}; Filas={Filas}; Total={Total}; Archivo={Archivo}",
                        usuarioActual,
                        preview.ImportedCount,
                        preview.Total,
                        request.SourceFileName);

                    return SuccessPreview("Anteproyecto importado correctamente con validacion previa.", preview);
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error al importar anteproyecto con IA. Usuario={Usuario}; Archivo={Archivo}", usuarioActual, request.SourceFileName);
                return FailurePreview($"Error al importar anteproyecto: {ex.InnerException?.Message ?? ex.Message}", "ERROR", preview);
            }
        }

        private async Task<bool> IsAuthorizedAsync(int id)
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            return await _context.EgresoAutorizados
                .AnyAsync(x => x.FkidEmpresaSis == empresaId && x.FkidEgresoProyectadoPres == id && x.Activo);
        }

        private static PagedResult<EgresoProyectadoResponse> Locked(int id, string message)
        {
            return new PagedResult<EgresoProyectadoResponse>
            {
                Success = false,
                Message = message,
                Code = "LOCKED",
                TotalCount = 0
            };
        }

        private static void ClearMonthsBeforeStartDate(EgresoProyectadoResponse response)
        {
            var startMonth = response.Fecha.Month;

            if (startMonth > 1) response.Enero = 0m;
            if (startMonth > 2) response.Febrero = 0m;
            if (startMonth > 3) response.Marzo = 0m;
            if (startMonth > 4) response.Abril = 0m;
            if (startMonth > 5) response.Mayo = 0m;
            if (startMonth > 6) response.Junio = 0m;
            if (startMonth > 7) response.Julio = 0m;
            if (startMonth > 8) response.Agosto = 0m;
            if (startMonth > 9) response.Septiembre = 0m;
            if (startMonth > 10) response.Octubre = 0m;
            if (startMonth > 11) response.Noviembre = 0m;

            response.Total = response.Enero + response.Febrero + response.Marzo + response.Abril +
                response.Mayo + response.Junio + response.Julio + response.Agosto +
                response.Septiembre + response.Octubre + response.Noviembre + response.Diciembre;
        }

        private static async Task<PagedResult<LookupItem>> ToLookupResultAsync<T>(
            IQueryable<T> query,
            int page,
            int pageSize,
            Func<T, LookupItem> map,
            string message)
        {
            var currentPage = Math.Max(1, page);
            var currentPageSize = pageSize <= 0 ? 25 : pageSize;
            var totalCount = await query.CountAsync();
            var rows = await query
                .Skip((currentPage - 1) * currentPageSize)
                .Take(currentPageSize)
                .ToListAsync();

            return new PagedResult<LookupItem>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Items = rows.Select(map).Where(x => !string.IsNullOrWhiteSpace(x.Text)).ToList(),
                TotalCount = totalCount
            };
        }

        private static string BuildText(string? clave, string? descripcion)
        {
            if (string.IsNullOrWhiteSpace(clave))
            {
                return descripcion ?? string.Empty;
            }

            return string.IsNullOrWhiteSpace(descripcion)
                ? clave
                : $"{clave} - {descripcion}";
        }

        private static string BuildText(int clave, string? descripcion)
        {
            return string.IsNullOrWhiteSpace(descripcion)
                ? clave.ToString()
                : $"{clave} - {descripcion}";
        }

        private async Task<EgresoProyectadoAiImportPreviewResponse> BuildImportPreviewAsync(
            string sourceFileName,
            EgresoProyectadoAiImportHeaderRequest fallback,
            IEnumerable<EgresoProyectadoAiImportRowRequest> rawRows,
            IReadOnlyDictionary<string, string> detectedHeaderValues,
            IEnumerable<EgresoProyectadoAiImportValidationMessage> parserMessages,
            IEnumerable<string> detectedColumns)
        {
            var header = new EgresoProyectadoAiImportHeaderRequest
            {
                FkidAnioSis = PositiveOrNull(fallback.FkidAnioSis),
                Anio = fallback.Anio ?? ParseInt(GetDetected(detectedHeaderValues, "Anio")),
                FkidEmpresaSis = _userContext.GetCurrentEmpresaId(),
                EmpresaNombre = null,
                Fecha = fallback.Fecha?.Date ?? DateTime.Today
            };

            var preview = new EgresoProyectadoAiImportPreviewResponse
            {
                SourceFileName = sourceFileName,
                Header = header,
                DetectedColumns = detectedColumns.ToList(),
                Messages = parserMessages.ToList()
            };

            await ResolveHeaderAsync(preview);
            await ResolveRowsAsync(preview, rawRows);

            preview.Total = preview.Rows.Sum(x => x.Total);
            if (preview.Rows.Count == 0)
                AddError(preview, "NO_ROWS", "El archivo debe contener al menos una fila de anteproyecto.");

            preview.CanImport = !preview.Messages.Any(x => x.Severity.Equals("Error", StringComparison.OrdinalIgnoreCase));
            return preview;
        }

        private async Task ResolveHeaderAsync(EgresoProyectadoAiImportPreviewResponse preview)
        {
            var header = preview.Header;

            if (!header.FkidAnioSis.HasValue && header.Anio.HasValue)
            {
                var anio = await _context.Anios.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.Clave == header.Anio.Value && x.Activo);
                header.FkidAnioSis = anio?.PkidAnio;
            }

            if (!header.FkidAnioSis.HasValue || header.FkidAnioSis <= 0)
            {
                AddError(preview, "ANIO_REQUIRED", "Selecciona un anio presupuestal para importar el anteproyecto.", field: "Anio");
                return;
            }

            var resolved = await _context.Anios.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidAnio == header.FkidAnioSis.Value && x.Activo);
            if (resolved == null)
                AddError(preview, "ANIO_INVALID", $"El anio {header.FkidAnioSis} no existe o esta inactivo.", field: "Anio");
            else
                header.Anio = resolved.Clave;

            if (!header.FkidEmpresaSis.HasValue || header.FkidEmpresaSis <= 0)
            {
                AddError(preview, "EMPRESA_REQUIRED", "Selecciona una empresa para importar el anteproyecto.", field: "Empresa");
                return;
            }

            var empresa = await _context.Empresas.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidEmpresa == header.FkidEmpresaSis.Value && x.Activo);
            if (empresa == null)
            {
                AddError(preview, "EMPRESA_INVALID", $"La empresa {header.FkidEmpresaSis} no existe o esta inactiva.", field: "Empresa");
                return;
            }

            header.EmpresaNombre = string.IsNullOrWhiteSpace(empresa.NombreCorto)
                ? empresa.Nombre
                : empresa.NombreCorto;
        }

        private async Task ResolveRowsAsync(EgresoProyectadoAiImportPreviewResponse preview, IEnumerable<EgresoProyectadoAiImportRowRequest> rawRows)
        {
            var anioId = preview.Header.FkidAnioSis;
            var programas = await _context.Programas.AsNoTracking()
                .Where(x => x.Activo && (!anioId.HasValue || x.FkidAnioSis == anioId.Value))
                .Select(x => new CatalogCandidate(x.PkidPrograma, x.Clave, x.Descripcion))
                .ToListAsync();
            var partidas = await _context.Partida.AsNoTracking()
                .Where(x => x.Activo)
                .Select(x => new CatalogCandidate(x.PkidPartida, x.Clave, x.Descripcion))
                .ToListAsync();
            var areas = await _context.Areas.AsNoTracking()
                .Where(x => x.Activo)
                .Select(x => new CatalogCandidate(x.PkidArea, x.Clave, x.Nombre))
                .ToListAsync();
            var fuentes = await _context.FuenteFinanciamientos.AsNoTracking()
                .Where(x => x.Activo && (x.Clave ?? string.Empty).Trim() != "6")
                .Select(x => new CatalogCandidate(x.PkidFuenteFinanciamiento, x.Clave, x.Descripcion))
                .ToListAsync();
            var tiposGasto = await _context.TipoGastos.AsNoTracking()
                .Where(x => x.Activo)
                .Select(x => new CatalogCandidate(x.PkidTipoGasto, x.Clave.ToString(), x.Descripcion))
                .ToListAsync();
            var digitos = await _context.DigitoIdentificadors.AsNoTracking()
                .Where(x => x.Activo)
                .Select(x => new CatalogCandidate(x.PkidDigitoIdentificador, x.Clave, x.Descripcion))
                .ToListAsync();
            var destinos = await _context.DestinoGastos.AsNoTracking()
                .Where(x => x.Activo)
                .Select(x => new CatalogCandidate(x.PkidDestinoGasto, x.Clave, x.Descripcion))
                .ToListAsync();
            var pies = await _context.Pies.AsNoTracking()
                .Where(x => x.Activo)
                .Select(x => new CatalogCandidate(x.PkidPy, x.Clave, string.IsNullOrWhiteSpace(x.Descripcion) ? x.NombreProyecto : x.Descripcion))
                .ToListAsync();

            var programaMap = BuildCatalogMap(programas);
            var partidaMap = BuildCatalogMap(partidas);
            var areaMap = BuildCatalogMap(areas);
            var fuenteMap = BuildCatalogMap(fuentes);
            var tipoGastoMap = BuildCatalogMap(tiposGasto);
            var digitoMap = BuildCatalogMap(digitos);
            var destinoMap = BuildCatalogMap(destinos);
            var pyMap = BuildCatalogMap(pies);

            foreach (var raw in rawRows)
            {
                var row = CloneRow(raw, preview.Header.Fecha ?? DateTime.Today);

                ResolveRequired(preview, row, programas, programaMap, row.FkidProgramaPres, row.Programa, "PROGRAMA", "Programa",
                    candidate =>
                    {
                        row.FkidProgramaPres = candidate.Id;
                        row.Programa = candidate.Key;
                        row.ProgramaDescripcion = candidate.Description;
                    });
                ResolveRequired(preview, row, partidas, partidaMap, row.FkidPartidaConta, row.Partida, "PARTIDA", "Partida",
                    candidate =>
                    {
                        row.FkidPartidaConta = candidate.Id;
                        row.Partida = candidate.Key;
                        row.PartidaDescripcion = candidate.Description;
                    });
                ResolveRequired(preview, row, areas, areaMap, row.FkidAreaSis, row.Area, "AREA", "Area",
                    candidate =>
                    {
                        row.FkidAreaSis = candidate.Id;
                        row.Area = candidate.Key;
                        row.AreaDescripcion = candidate.Description;
                    });

                ResolveOptional(row.FkidFuenteFinanciamientoPres, row.FuenteFinanciamiento, fuentes, fuenteMap,
                    candidate =>
                    {
                        row.FkidFuenteFinanciamientoPres = candidate.Id;
                        row.FuenteFinanciamiento = candidate.Key;
                        row.FuenteFinanciamientoDescripcion = candidate.Description;
                    },
                    () => AddError(preview, "FUENTE_NOT_FOUND", $"No se encontro la fuente de financiamiento {row.FuenteFinanciamiento}.", row.RowNumber, "FuenteFinanciamiento"));
                ResolveOptional(row.FkidTipoGastoPres, row.TipoGasto, tiposGasto, tipoGastoMap,
                    candidate =>
                    {
                        row.FkidTipoGastoPres = candidate.Id;
                        row.TipoGasto = candidate.Key;
                        row.TipoGastoDescripcion = candidate.Description;
                    },
                    () => AddError(preview, "TIPO_GASTO_NOT_FOUND", $"No se encontro el tipo de gasto {row.TipoGasto}.", row.RowNumber, "TipoGasto"));
                ResolveOptional(row.FkidDigitoIdentificadorPres, row.DigitoIdentificador, digitos, digitoMap,
                    candidate =>
                    {
                        row.FkidDigitoIdentificadorPres = candidate.Id;
                        row.DigitoIdentificador = candidate.Key;
                        row.DigitoIdentificadorDescripcion = candidate.Description;
                    },
                    () => AddError(preview, "DIGITO_NOT_FOUND", $"No se encontro el digito identificador {row.DigitoIdentificador}.", row.RowNumber, "DigitoIdentificador"));
                ResolveOptional(row.FkidDestinoGastoPres, row.DestinoGasto, destinos, destinoMap,
                    candidate =>
                    {
                        row.FkidDestinoGastoPres = candidate.Id;
                        row.DestinoGasto = candidate.Key;
                        row.DestinoGastoDescripcion = candidate.Description;
                    },
                    () => AddError(preview, "DESTINO_NOT_FOUND", $"No se encontro el destino de gasto {row.DestinoGasto}.", row.RowNumber, "DestinoGasto"));
                ResolveOptional(row.FkidPyPres, row.Py, pies, pyMap,
                    candidate =>
                    {
                        row.FkidPyPres = candidate.Id;
                        row.Py = candidate.Key;
                        row.PyDescripcion = candidate.Description;
                    },
                    () => AddError(preview, "PY_NOT_FOUND", $"No se encontro el PY {row.Py}.", row.RowNumber, "Py"));

                ValidateAndNormalizeAmounts(preview, row);
                preview.Rows.Add(row);
            }
        }

        private static EgresoProyectadoAiImportRowRequest CloneRow(EgresoProyectadoAiImportRowRequest raw, DateTime fallbackDate)
        {
            var row = new EgresoProyectadoAiImportRowRequest
            {
                RowNumber = raw.RowNumber,
                Programa = Trim(raw.Programa),
                FkidProgramaPres = PositiveOrNull(raw.FkidProgramaPres),
                Partida = Trim(raw.Partida),
                FkidPartidaConta = PositiveOrNull(raw.FkidPartidaConta),
                Area = Trim(raw.Area),
                FkidAreaSis = PositiveOrNull(raw.FkidAreaSis),
                Descripcion = Trim(raw.Descripcion),
                Fecha = raw.Fecha?.Date ?? fallbackDate.Date,
                FuenteFinanciamiento = Trim(raw.FuenteFinanciamiento),
                FkidFuenteFinanciamientoPres = PositiveOrNull(raw.FkidFuenteFinanciamientoPres),
                TipoGasto = Trim(raw.TipoGasto),
                FkidTipoGastoPres = PositiveOrNull(raw.FkidTipoGastoPres),
                DigitoIdentificador = Trim(raw.DigitoIdentificador),
                FkidDigitoIdentificadorPres = PositiveOrNull(raw.FkidDigitoIdentificadorPres),
                DestinoGasto = Trim(raw.DestinoGasto),
                FkidDestinoGastoPres = PositiveOrNull(raw.FkidDestinoGastoPres),
                Py = Trim(raw.Py),
                FkidPyPres = PositiveOrNull(raw.FkidPyPres),
                Enero = NormalizeMoney(raw.Enero),
                Febrero = NormalizeMoney(raw.Febrero),
                Marzo = NormalizeMoney(raw.Marzo),
                Abril = NormalizeMoney(raw.Abril),
                Mayo = NormalizeMoney(raw.Mayo),
                Junio = NormalizeMoney(raw.Junio),
                Julio = NormalizeMoney(raw.Julio),
                Agosto = NormalizeMoney(raw.Agosto),
                Septiembre = NormalizeMoney(raw.Septiembre),
                Octubre = NormalizeMoney(raw.Octubre),
                Noviembre = NormalizeMoney(raw.Noviembre),
                Diciembre = NormalizeMoney(raw.Diciembre)
            };

            row.Total = SumMonths(row);
            return row;
        }

        private static void ValidateAndNormalizeAmounts(EgresoProyectadoAiImportPreviewResponse preview, EgresoProyectadoAiImportRowRequest row)
        {
            if (new[] { row.Enero, row.Febrero, row.Marzo, row.Abril, row.Mayo, row.Junio, row.Julio, row.Agosto, row.Septiembre, row.Octubre, row.Noviembre, row.Diciembre }.Any(x => x < 0m))
                AddError(preview, "NEGATIVE_AMOUNT", "Los importes mensuales no pueden ser negativos.", row.RowNumber);

            var startMonth = row.Fecha?.Month ?? 1;
            if (startMonth > 1 && row.Enero != 0m) { row.Enero = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Enero porque queda antes de la fecha inicial.", row.RowNumber, "Enero"); }
            if (startMonth > 2 && row.Febrero != 0m) { row.Febrero = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Febrero porque queda antes de la fecha inicial.", row.RowNumber, "Febrero"); }
            if (startMonth > 3 && row.Marzo != 0m) { row.Marzo = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Marzo porque queda antes de la fecha inicial.", row.RowNumber, "Marzo"); }
            if (startMonth > 4 && row.Abril != 0m) { row.Abril = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Abril porque queda antes de la fecha inicial.", row.RowNumber, "Abril"); }
            if (startMonth > 5 && row.Mayo != 0m) { row.Mayo = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Mayo porque queda antes de la fecha inicial.", row.RowNumber, "Mayo"); }
            if (startMonth > 6 && row.Junio != 0m) { row.Junio = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Junio porque queda antes de la fecha inicial.", row.RowNumber, "Junio"); }
            if (startMonth > 7 && row.Julio != 0m) { row.Julio = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Julio porque queda antes de la fecha inicial.", row.RowNumber, "Julio"); }
            if (startMonth > 8 && row.Agosto != 0m) { row.Agosto = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Agosto porque queda antes de la fecha inicial.", row.RowNumber, "Agosto"); }
            if (startMonth > 9 && row.Septiembre != 0m) { row.Septiembre = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Septiembre porque queda antes de la fecha inicial.", row.RowNumber, "Septiembre"); }
            if (startMonth > 10 && row.Octubre != 0m) { row.Octubre = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Octubre porque queda antes de la fecha inicial.", row.RowNumber, "Octubre"); }
            if (startMonth > 11 && row.Noviembre != 0m) { row.Noviembre = 0m; AddWarning(preview, "MONTH_CLEARED", "Se limpio Noviembre porque queda antes de la fecha inicial.", row.RowNumber, "Noviembre"); }

            row.Total = SumMonths(row);
            if (row.Total <= 0m)
                AddError(preview, "AMOUNT_REQUIRED", "La fila debe tener al menos un importe mensual mayor a cero.", row.RowNumber);
        }

        private static void ResolveRequired(
            EgresoProyectadoAiImportPreviewResponse preview,
            EgresoProyectadoAiImportRowRequest row,
            IReadOnlyList<CatalogCandidate> candidates,
            IReadOnlyDictionary<string, CatalogCandidate> map,
            int? id,
            string? value,
            string codePrefix,
            string field,
            Action<CatalogCandidate> apply)
        {
            var candidate = FindCandidate(candidates, map, id, value);
            if (candidate == null)
            {
                AddError(preview, $"{codePrefix}_REQUIRED", $"No se pudo resolver {field}: {value}.", row.RowNumber, field);
                return;
            }

            apply(candidate);
        }

        private static void ResolveOptional(
            int? id,
            string? value,
            IReadOnlyList<CatalogCandidate> candidates,
            IReadOnlyDictionary<string, CatalogCandidate> map,
            Action<CatalogCandidate> apply,
            Action onNotFound)
        {
            if (!id.HasValue && string.IsNullOrWhiteSpace(value))
                return;

            var candidate = FindCandidate(candidates, map, id, value);
            if (candidate == null)
            {
                onNotFound();
                return;
            }

            apply(candidate);
        }

        private static CatalogCandidate? FindCandidate(
            IReadOnlyList<CatalogCandidate> candidates,
            IReadOnlyDictionary<string, CatalogCandidate> map,
            int? id,
            string? value)
        {
            if (id.HasValue)
                return candidates.FirstOrDefault(x => x.Id == id.Value);

            var key = EgresoProyectadoAiImportParser.NormalizeLookupKey(value);
            return !string.IsNullOrWhiteSpace(key) && map.TryGetValue(key, out var candidate)
                ? candidate
                : null;
        }

        private static Dictionary<string, CatalogCandidate> BuildCatalogMap(IEnumerable<CatalogCandidate> candidates)
        {
            var map = new Dictionary<string, CatalogCandidate>(StringComparer.OrdinalIgnoreCase);
            foreach (var candidate in candidates)
            {
                AddCatalogKey(map, candidate.Key, candidate);
                AddCatalogKey(map, candidate.Description, candidate);
                AddCatalogKey(map, $"{candidate.Key} {candidate.Description}", candidate);
                AddCatalogKey(map, $"{candidate.Key} - {candidate.Description}", candidate);
            }

            return map;
        }

        private static void AddCatalogKey(IDictionary<string, CatalogCandidate> map, string? value, CatalogCandidate candidate)
        {
            var key = EgresoProyectadoAiImportParser.NormalizeLookupKey(value);
            if (!string.IsNullOrWhiteSpace(key))
                map.TryAdd(key, candidate);
        }

        private static void AddError(EgresoProyectadoAiImportPreviewResponse preview, string code, string message, int? rowNumber = null, string? field = null)
            => preview.Messages.Add(new EgresoProyectadoAiImportValidationMessage
            {
                Severity = "Error",
                Code = code,
                Message = message,
                RowNumber = rowNumber,
                Field = field
            });

        private static void AddWarning(EgresoProyectadoAiImportPreviewResponse preview, string code, string message, int? rowNumber = null, string? field = null)
            => preview.Messages.Add(new EgresoProyectadoAiImportValidationMessage
            {
                Severity = "Warning",
                Code = code,
                Message = message,
                RowNumber = rowNumber,
                Field = field
            });

        private static PagedResult<EgresoProyectadoAiImportPreviewResponse> SuccessPreview(string message, EgresoProyectadoAiImportPreviewResponse preview) => new()
        {
            Success = true,
            Message = message,
            Code = "SUCCESS",
            Data = preview,
            Items = [preview],
            TotalCount = 1
        };

        private static PagedResult<EgresoProyectadoAiImportPreviewResponse> FailurePreview(string message, string code, EgresoProyectadoAiImportPreviewResponse? preview = null) => new()
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

        private static int? ParseInt(string? value)
            => int.TryParse(value, out var parsed) ? parsed : null;

        private static int? PositiveOrNull(int? value)
            => value.GetValueOrDefault() > 0 ? value : null;

        private static string? Trim(string? value)
            => string.IsNullOrWhiteSpace(value) ? null : value.Trim();

        private static decimal NormalizeMoney(decimal value)
            => value == 0m ? 0m : decimal.Round(value, 2);

        private static decimal SumMonths(EgresoProyectadoAiImportRowRequest row)
            => row.Enero + row.Febrero + row.Marzo + row.Abril + row.Mayo + row.Junio +
                row.Julio + row.Agosto + row.Septiembre + row.Octubre + row.Noviembre + row.Diciembre;

        private sealed record CatalogCandidate(int Id, string? Key, string? Description);
    }
}
