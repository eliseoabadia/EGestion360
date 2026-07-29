using System.Text.Json;
using EG.Application.Interfaces.Patrimonio;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio
{
    public class BajaAppService : IBajaAppService
    {
        private const string EstatusInicial = "INICIAL";
        private const string EstatusAplicada = "APLICADA";
        private const string EstatusRechazada = "RECHAZADA";

        private readonly GenericService<Baja, BajaDto, BajaResponse> _service;
        private readonly GenericService<VwBaja, BajaDto, BajaResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public BajaAppService(
            GenericService<Baja, BajaDto, BajaResponse> service,
            GenericService<VwBaja, BajaDto, BajaResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<BajaResponse>> GetAllAsync()
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var items = (await _serviceView.GetQueryWithIncludes()
                .Where(x => x.FkidEmpresaSis == empresaId)
                .ToListAsync()).Adapt<List<BajaResponse>>();
            await ApplyStatusFlagsAsync(items);
            return Success(items, "Bajas obtenidas correctamente", items.Count);
        }

        public async Task<PagedResult<BajaResponse>> GetByIdAsync(int id)
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var entity = await _serviceView.GetQueryWithIncludes()
                .FirstOrDefaultAsync(x => x.PkidBaja == id && x.FkidEmpresaSis == empresaId);
            if (entity == null)
            {
                return Failure<BajaResponse>($"Baja con ID {id} no encontrada.", "NOT_FOUND");
            }

            var item = entity.Adapt<BajaResponse>();
            await ApplyStatusFlagsAsync(new List<BajaResponse> { item });

            return new PagedResult<BajaResponse>
            {
                Success = true,
                Message = "Baja encontrada",
                Code = "SUCCESS",
                Data = item,
                Items = new List<BajaResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<BajaResponse>> CreateAsync(BajaResponse response, int usuarioActual)
        {
            response.FkidPolizaConta = null;
            var validation = await NormalizeAndValidateAsync(response, isCreate: true);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();
                var result = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                var id = result.GetId();
                if (id.HasValue)
                {
                    await _context.Bajas
                        .Where(x => x.PkidBaja == id.Value && x.FkidEmpresaSis == response.FkidEmpresaSis)
                        .ExecuteUpdateAsync(setters => setters
                            .SetProperty(x => x.FkidAnioSis, response.FkidAnioSis)
                            .SetProperty(x => x.FkidPolizaConta, (int?)null));
                    await transaction.CommitAsync();
                    var refreshed = await GetByIdAsync(id.Value);
                    refreshed.Message = result.Mensaje;
                    return refreshed;
                }

                return new PagedResult<BajaResponse>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = "SUCCESS",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return Failure<BajaResponse>($"Error al crear baja: {ex.Message}");
            }
        }

        public async Task<PagedResult<BajaResponse>> UpdateAsync(int id, BajaResponse response, int usuarioActual)
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var current = await _context.Bajas
                .AsNoTracking()
                .Include(x => x.FkidEstatusBajaAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidBaja == id && x.Activo && x.FkidEmpresaSis == empresaId);

            if (current == null)
            {
                return Failure<BajaResponse>($"Baja con ID {id} no encontrada.", "NOT_FOUND");
            }

            if (current.FkidEstatusBajaAlmaNavigation?.EsFinal == true)
            {
                return Failure<BajaResponse>("La baja ya esta en estatus final y no puede modificarse.", "INVALID_STATE");
            }

            if (response.FkidEstatusBajaAlma > 0 && response.FkidEstatusBajaAlma != current.FkidEstatusBajaAlma)
            {
                return Failure<BajaResponse>("El estatus no se cambia desde la edicion. Use la accion de autorizar, rechazar o cancelar.", "INVALID_TRANSITION");
            }

            response.FkidEmpresaSis = current.FkidEmpresaSis;
            response.FkidAnioSis = current.FkidAnioSis;
            response.FkidBienAlma = current.FkidBienAlma;
            response.FkidEstatusBajaAlma = current.FkidEstatusBajaAlma;
            response.FkidPolizaConta = current.FkidPolizaConta;

            var validation = await NormalizeAndValidateAsync(response, isCreate: false);
            if (validation != null)
            {
                return validation;
            }

            response.PkidBaja = id;
            response.Folio = string.IsNullOrWhiteSpace(response.Folio) ? current.Folio ?? string.Empty : response.Folio;
            response.UsuarioCreacion = current.UsuarioCreacion;
            response.FechaCreacion = current.FechaCreacion;

            try
            {
                var result = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = result.Mensaje;
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<BajaResponse>($"Error al actualizar baja: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var current = await _context.Bajas
                .AsNoTracking()
                .Include(x => x.FkidEstatusBajaAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidBaja == id && x.Activo && x.FkidEmpresaSis == empresaId);

            if (current == null)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Baja con ID {id} no encontrada.",
                    Code = "NOT_FOUND",
                    Data = false,
                    TotalCount = 0
                };
            }

            if (current.FkidEstatusBajaAlmaNavigation?.EsFinal == true)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "La baja ya esta en estatus final y no puede eliminarse.",
                    Code = "INVALID_STATE",
                    Data = false,
                    TotalCount = 0
                };
            }

            try
            {
                var result = await ExecuteMantenimientoAsync(3, id, new BajaResponse
                {
                    PkidBaja = id,
                    FkidEmpresaSis = current.FkidEmpresaSis,
                    FkidAreaSis = current.FkidAreaSis,
                    FkidBienAlma = current.FkidBienAlma,
                    FkidTipoBajaAlma = current.FkidTipoBajaAlma,
                    FkidEstatusBajaAlma = current.FkidEstatusBajaAlma,
                    FkidEstadoBienDestinoAlma = current.FkidEstadoBienDestinoAlma,
                    FechaSolicitud = current.FechaSolicitud.ToDateTime(TimeOnly.MinValue),
                    FechaBaja = current.FechaBaja?.ToDateTime(TimeOnly.MinValue),
                    Referencia = current.Referencia ?? string.Empty,
                    FechaReferencia = current.FechaReferencia?.ToDateTime(TimeOnly.MinValue),
                    Destinatario = current.Destinatario ?? string.Empty,
                    Recibo = current.Recibo ?? string.Empty,
                    Cantidad = current.Cantidad,
                    Motivo = current.Motivo ?? string.Empty,
                    Dictamen = current.Dictamen ?? string.Empty,
                    Observaciones = current.Observaciones ?? string.Empty,
                    FkidPolizaConta = current.FkidPolizaConta,
                    SolicitadoPorNom = current.SolicitadoPorNom,
                    AutorizadoPorNom = current.AutorizadoPorNom
                }, _userContext.GetCurrentUserId());

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = result.Mensaje,
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
                    Message = $"Error al eliminar baja: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<BajaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var empresaActual = _userContext.TryGetCurrentEmpresaId();
                if (empresaActual is not > 0)
                {
                    return Failure<BajaResponse>("Debe seleccionar una empresa activa.", "COMPANY_REQUIRED");
                }

                if (!TryGetIntFilter(request, "FkidAnioSis", out var anioId) || anioId <= 0)
                {
                    return Failure<BajaResponse>("Debe seleccionar el año presupuestal.", "YEAR_REQUIRED");
                }

                var query = _serviceView.GetQueryWithIncludes()
                    .Where(x => x.FkidEmpresaSis == empresaActual.Value && x.FkidAnioSis == anioId);

                if (TryGetIntFilter(request, "FkidEmpresaSis", out var empresaId))
                {
                    query = query.Where(x => x.FkidEmpresaSis == empresaId);
                }

                if (TryGetIntFilter(request, "FkidAreaSis", out var areaId))
                {
                    query = query.Where(x => x.FkidAreaSis == areaId);
                }

                if (TryGetIntFilter(request, "FkidBienAlma", out var bienId))
                {
                    query = query.Where(x => x.FkidBienAlma == bienId);
                }

                if (TryGetIntFilter(request, "FkidTipoBajaAlma", out var tipoBajaId))
                {
                    query = query.Where(x => x.FkidTipoBajaAlma == tipoBajaId);
                }

                if (TryGetIntFilter(request, "FkidEstatusBajaAlma", out var estatusId))
                {
                    query = query.Where(x => x.FkidEstatusBajaAlma == estatusId);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Folio != null && x.Folio.Contains(filtro)) ||
                        (x.BienClave != null && x.BienClave.Contains(filtro)) ||
                        (x.BienClaveAnterior != null && x.BienClaveAnterior.Contains(filtro)) ||
                        (x.BienDescripcion != null && x.BienDescripcion.Contains(filtro)) ||
                        (x.Serie != null && x.Serie.Contains(filtro)) ||
                        (x.Factura != null && x.Factura.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)) ||
                        (x.TipoBajaDescripcion != null && x.TipoBajaDescripcion.Contains(filtro)) ||
                        (x.EstatusDescripcion != null && x.EstatusDescripcion.Contains(filtro)) ||
                        (x.Referencia != null && x.Referencia.Contains(filtro)) ||
                        (x.Recibo != null && x.Recibo.Contains(filtro)) ||
                        (x.Destinatario != null && x.Destinatario.Contains(filtro)) ||
                        (x.ClavePoliza != null && x.ClavePoliza.Contains(filtro)) ||
                        (x.Motivo != null && x.Motivo.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
                var responses = items.Adapt<List<BajaResponse>>();
                await ApplyStatusFlagsAsync(responses);

                return Success(responses, "Bajas obtenidas correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<BajaResponse>($"Error al obtener bajas: {ex.Message}");
            }
        }

        private async Task<PagedResult<BajaResponse>?> NormalizeAndValidateAsync(BajaResponse response, bool isCreate)
        {
            response.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();

            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<BajaResponse>("Debe existir una empresa seleccionada.");
            }

            if (response.FkidAnioSis is not > 0)
            {
                return Failure<BajaResponse>("Debe seleccionar el año presupuestal.", "YEAR_REQUIRED");
            }

            var anio = await _context.Anios.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidAnio == response.FkidAnioSis.Value && x.Activo);
            if (anio == null)
            {
                return Failure<BajaResponse>("El año presupuestal seleccionado no existe o está inactivo.", "YEAR_REQUIRED");
            }

            if (response.FkidBienAlma <= 0)
            {
                return Failure<BajaResponse>("Debe seleccionar el bien a dar de baja.");
            }

            if (response.FkidTipoBajaAlma <= 0)
            {
                return Failure<BajaResponse>("Debe seleccionar el tipo de baja.");
            }

            if (string.IsNullOrWhiteSpace(response.Motivo))
            {
                return Failure<BajaResponse>("El motivo de la baja es requerido.");
            }

            if (response.Cantidad.HasValue && response.Cantidad <= 0)
            {
                return Failure<BajaResponse>("La cantidad debe ser mayor a cero.");
            }

            if (response.Cantidad.HasValue && response.Cantidad.Value != 1m)
            {
                return Failure<BajaResponse>("La baja patrimonial corresponde a un bien individual y su cantidad debe ser uno.");
            }

            var fechaBajaValidacion = response.FechaBaja?.Date
                ?? (response.FechaSolicitud == default ? DateTime.Today : response.FechaSolicitud.Date);
            if (response.FechaReferencia.HasValue && fechaBajaValidacion > response.FechaReferencia.Value.Date)
            {
                return Failure<BajaResponse>("La fecha de referencia debe ser mayor o igual a la fecha de baja.");
            }

            var bien = await _context.Biens.AsNoTracking().FirstOrDefaultAsync(x =>
                x.PkidBien == response.FkidBienAlma && x.Activo && x.FkidEmpresaSis == response.FkidEmpresaSis);
            if (bien == null)
            {
                return Failure<BajaResponse>("El bien no existe, no está activo o no pertenece a la empresa actual.");
            }

            if (bien.EsContabilizado != true)
            {
                return Failure<BajaResponse>("El bien debe estar contabilizado antes de iniciar su baja patrimonial.", "NOT_ACCOUNTED");
            }

            var fechaSolicitud = response.FechaSolicitud == default ? DateTime.Today : response.FechaSolicitud.Date;
            if (fechaSolicitud.Year != anio.Clave || (response.FechaBaja.HasValue && response.FechaBaja.Value.Year != anio.Clave))
            {
                return Failure<BajaResponse>("Las fechas de la baja deben pertenecer al año presupuestal seleccionado.", "YEAR_MISMATCH");
            }

            if (isCreate && await _context.Bajas.AsNoTracking().AnyAsync(x => x.FkidBienAlma == response.FkidBienAlma && x.Activo))
            {
                return Failure<BajaResponse>("El bien ya tiene una baja activa.", "DUPLICATE");
            }

            var tipoBaja = await _context.TipoBajas.AsNoTracking().FirstOrDefaultAsync(x => x.PkidTipoBaja == response.FkidTipoBajaAlma && x.Activo);
            if (tipoBaja == null)
            {
                return Failure<BajaResponse>("El tipo de baja seleccionado no existe o esta inactivo.");
            }

            if (isCreate || response.FkidEstatusBajaAlma <= 0)
            {
                var inicial = await GetStatusByDescriptionAsync(EstatusInicial);
                if (inicial == null)
                {
                    return Failure<BajaResponse>("No existe el estatus inicial de bajas.");
                }

                response.FkidEstatusBajaAlma = inicial.PkidEstatusBaja;
            }

            response.FkidAreaSis ??= bien.FkidAreaSis;
            response.FkidEstadoBienAnteriorAlma ??= bien.FkidEstadoBienAlma;
            response.FkidEstadoBienDestinoAlma ??= tipoBaja.FkidEstadoBienDestinoAlma;
            response.FechaSolicitud = response.FechaSolicitud == default ? DateTime.Today : response.FechaSolicitud.Date;
            response.Motivo = response.Motivo.Trim();
            response.Referencia ??= string.Empty;
            response.Destinatario ??= string.Empty;
            response.Recibo ??= string.Empty;
            response.Cantidad ??= 1m;
            response.Dictamen ??= string.Empty;
            response.Observaciones ??= string.Empty;
            response.Folio ??= string.Empty;
            response.Activo = true;

            return null;
        }

        public async Task<PagedResult<BajaResponse>> AplicarAsync(int id, int fkidAnioSis, int usuarioActual)
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var current = await _context.Bajas
                .AsNoTracking()
                .Include(x => x.FkidEstatusBajaAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidBaja == id && x.Activo && x.FkidEmpresaSis == empresaId);

            if (current == null)
                return Failure<BajaResponse>("La baja no existe o no pertenece a la empresa activa.", "NOT_FOUND");
            if (current.FkidEstatusBajaAlmaNavigation?.EsFinal == true)
                return Failure<BajaResponse>("La baja ya se encuentra en un estatus final.", "INVALID_STATE");
            if (current.FkidAnioSis != fkidAnioSis)
                return Failure<BajaResponse>("La baja no pertenece al año presupuestal seleccionado.", "YEAR_MISMATCH");

            var anio = await _context.Anios.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidAnio == fkidAnioSis && x.Activo);
            if (anio == null)
                return Failure<BajaResponse>("El año presupuestal seleccionado no existe o está inactivo.", "YEAR_REQUIRED");
            if (anio.Clave != DateTime.Today.Year)
                return Failure<BajaResponse>("Las bajas operativas sólo pueden aplicarse en el ejercicio vigente.", "YEAR_NOT_CURRENT");

            var bienElegible = await _context.Biens.AsNoTracking().AnyAsync(x =>
                x.PkidBien == current.FkidBienAlma &&
                x.FkidEmpresaSis == empresaId &&
                x.Activo &&
                x.EsContabilizado == true);
            if (!bienElegible)
                return Failure<BajaResponse>("El bien ya no está activo, contabilizado o disponible para aplicar la baja.", "ASSET_NOT_ELIGIBLE");

            var aplicada = await GetStatusByDescriptionAsync(EstatusAplicada);
            if (aplicada == null)
                return Failure<BajaResponse>("No existe el estatus APLICADA.");

            var response = current.Adapt<BajaResponse>();
            response.FkidEstatusBajaAlma = aplicada.PkidEstatusBaja;
            response.FechaBaja = DateTime.Today;
            response.FkidPolizaConta = current.FkidPolizaConta;

            try
            {
                var result = await ExecuteMantenimientoAsync(4, id, response, usuarioActual);
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = result.Mensaje;
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<BajaResponse>($"Error al aplicar la baja: {ex.Message}");
            }
        }

        private async Task<int> ResolveUpdateActionAsync(int estatusBajaId)
        {
            var status = await _context.EstatusBajas
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidEstatusBaja == estatusBajaId);

            if (status?.Descripcion.Equals(EstatusAplicada, StringComparison.OrdinalIgnoreCase) == true)
            {
                return 4;
            }

            if (status?.Descripcion.Equals(EstatusRechazada, StringComparison.OrdinalIgnoreCase) == true)
            {
                return 5;
            }

            return 2;
        }

        private async Task<EstatusBaja?> GetStatusByDescriptionAsync(string description)
        {
            return await _context.EstatusBajas
                .AsNoTracking()
                .Where(x => x.Activo && x.Descripcion == description)
                .OrderBy(x => x.Orden)
                .FirstOrDefaultAsync();
        }

        private async Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            BajaResponse response,
            int usuarioActual)
        {
            var idParameter = new SqlParameter("@Id", id.HasValue ? id.Value : DBNull.Value)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                SqlDbType = System.Data.SqlDbType.Int
            };

            return await StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ALMA].[SP_MantenimientoBajas]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdBaja", id),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdArea_SIS", response.FkidAreaSis),
                StoredProcedureExecutor.Param("@FKIdBien_ALMA", response.FkidBienAlma),
                StoredProcedureExecutor.Param("@FKIdTipoBaja_ALMA", response.FkidTipoBajaAlma),
                StoredProcedureExecutor.Param("@FKIdEstatusBaja_ALMA", response.FkidEstatusBajaAlma),
                StoredProcedureExecutor.Param("@FKIdEstadoBienDestino_ALMA", response.FkidEstadoBienDestinoAlma),
                StoredProcedureExecutor.Param("@FechaSolicitud", response.FechaSolicitud == default ? DateTime.Today : response.FechaSolicitud.Date),
                StoredProcedureExecutor.Param("@FechaBaja", response.FechaBaja?.Date),
                StoredProcedureExecutor.Param("@Referencia", response.Referencia),
                StoredProcedureExecutor.Param("@FechaReferencia", response.FechaReferencia?.Date),
                StoredProcedureExecutor.Param("@Destinatario", response.Destinatario),
                StoredProcedureExecutor.Param("@Recibo", response.Recibo),
                StoredProcedureExecutor.Param("@Cantidad", response.Cantidad),
                StoredProcedureExecutor.Param("@Motivo", response.Motivo),
                StoredProcedureExecutor.Param("@Dictamen", response.Dictamen),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@FKIdPoliza_CONTA", response.FkidPolizaConta),
                StoredProcedureExecutor.Param("@SolicitadoPor_NOM", response.SolicitadoPorNom),
                StoredProcedureExecutor.Param("@AutorizadoPor_NOM", response.AutorizadoPorNom),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                idParameter);
        }

        private async Task ApplyStatusFlagsAsync(IList<BajaResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var statusIds = items.Select(x => x.FkidEstatusBajaAlma).Distinct().ToList();
            var statusMap = await _context.EstatusBajas
                .AsNoTracking()
                .Where(x => statusIds.Contains(x.PkidEstatusBaja))
                .ToDictionaryAsync(x => x.PkidEstatusBaja, x => x.EsFinal);

            foreach (var item in items)
            {
                if (statusMap.TryGetValue(item.FkidEstatusBajaAlma, out var esFinal))
                {
                    item.EsFinal = esFinal;
                }
            }
        }

        private static IQueryable<VwBaja> ApplySort(IQueryable<VwBaja> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "Folio" => ascending ? query.OrderBy(x => x.Folio) : query.OrderByDescending(x => x.Folio),
                "BienClave" => ascending ? query.OrderBy(x => x.BienClave) : query.OrderByDescending(x => x.BienClave),
                "BienDescripcion" => ascending ? query.OrderBy(x => x.BienDescripcion) : query.OrderByDescending(x => x.BienDescripcion),
                "AreaNombre" => ascending ? query.OrderBy(x => x.AreaNombre) : query.OrderByDescending(x => x.AreaNombre),
                "FechaSolicitud" => ascending ? query.OrderBy(x => x.FechaSolicitud) : query.OrderByDescending(x => x.FechaSolicitud),
                "FechaBaja" => ascending ? query.OrderBy(x => x.FechaBaja) : query.OrderByDescending(x => x.FechaBaja),
                "FechaReferencia" => ascending ? query.OrderBy(x => x.FechaReferencia) : query.OrderByDescending(x => x.FechaReferencia),
                "Referencia" => ascending ? query.OrderBy(x => x.Referencia) : query.OrderByDescending(x => x.Referencia),
                "TipoBajaDescripcion" => ascending ? query.OrderBy(x => x.TipoBajaDescripcion) : query.OrderByDescending(x => x.TipoBajaDescripcion),
                "EstatusDescripcion" => ascending ? query.OrderBy(x => x.EstatusDescripcion) : query.OrderByDescending(x => x.EstatusDescripcion),
                "ValorActual" => ascending ? query.OrderBy(x => x.ValorActual) : query.OrderByDescending(x => x.ValorActual),
                _ => ascending ? query.OrderByDescending(x => x.PkidBaja) : query.OrderBy(x => x.PkidBaja)
            };
        }

        private static PagedResult<BajaResponse> Success(List<BajaResponse> items, string message, int total)
        {
            return new PagedResult<BajaResponse>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Items = items,
                TotalCount = total
            };
        }

        private static PagedResult<T> Failure<T>(string message, string code = "ERROR")
            where T : class
        {
            return new PagedResult<T>
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };
        }

        private static bool TryGetIntFilter(PagedRequest request, string key, out int value)
        {
            value = 0;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            {
                return false;
            }

            if (raw is JsonElement json)
            {
                if (json.ValueKind == JsonValueKind.Number && json.TryGetInt32(out value))
                {
                    return true;
                }

                if (json.ValueKind == JsonValueKind.String && int.TryParse(json.GetString(), out value))
                {
                    return true;
                }
            }

            return int.TryParse(raw.ToString(), out value);
        }
    }
}
