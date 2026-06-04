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
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio
{
    public class BienAppService : IBienAppService
    {
        private readonly GenericService<Bien, BienDto, BienResponse> _service;
        private readonly GenericService<VwBien, BienDto, BienResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public BienAppService(
            GenericService<Bien, BienDto, BienResponse> service,
            GenericService<VwBien, BienDto, BienResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<BienResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            await ApplyEntityKeysAsync(items);
            return Success(items, "Bienes obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<BienResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidBien");
            if (item == null)
            {
                return Failure<BienResponse>($"Bien con ID {id} no encontrado.", "NOT_FOUND");
            }

            await ApplyEntityKeysAsync(new List<BienResponse> { item });

            return new PagedResult<BienResponse>
            {
                Success = true,
                Message = "Bien encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<BienResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<BienResponse>> CreateAsync(BienResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, true);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var result = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                var id = result.GetId();
                if (!id.HasValue)
                {
                    return new PagedResult<BienResponse>
                    {
                        Success = true,
                        Message = result.Mensaje,
                        Code = "SUCCESS",
                        TotalCount = 0
                    };
                }

                var refreshed = await GetByIdAsync(id.Value);
                refreshed.Message = result.Mensaje;
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<BienResponse>($"Error al crear bien: {ex.Message}");
            }
        }

        public async Task<PagedResult<BienResponse>> UpdateAsync(int id, BienResponse response, int usuarioActual)
        {
            var current = await _context.Biens.AsNoTracking().FirstOrDefaultAsync(x => x.PkidBien == id && x.Activo);
            if (current == null)
            {
                return Failure<BienResponse>($"Bien con ID {id} no encontrado.", "NOT_FOUND");
            }

            var validation = await NormalizeAndValidateAsync(response, false);
            if (validation != null)
            {
                return validation;
            }

            response.PkidBien = id;
            response.Clave = string.IsNullOrWhiteSpace(response.Clave) ? current.Clave ?? string.Empty : response.Clave;
            response.ClaveAnt = string.IsNullOrWhiteSpace(response.ClaveAnt) ? current.ClaveAnt ?? string.Empty : response.ClaveAnt;
            response.Resguardo = current.Resguardo;
            response.ResguardoAnterior = current.ResguardoAnterior;
            response.EstaResguardado = current.EstaResguardado;
            response.FechaResguardado = current.FechaResguardado;

            try
            {
                var result = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = result.Mensaje;
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<BienResponse>($"Error al actualizar bien: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            if (!await _context.Biens.AsNoTracking().AnyAsync(x => x.PkidBien == id && x.Activo))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Bien con ID {id} no encontrado.",
                    Code = "NOT_FOUND",
                    Data = false,
                    TotalCount = 0
                };
            }

            try
            {
                var result = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ALMA].[SP_MantenimientoBien]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdBien", id),
                    StoredProcedureExecutor.Param("@IdBaja", id),
                    StoredProcedureExecutor.Param("@IdUser", _userContext.GetCurrentUserId()));

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
                    Message = $"Error al eliminar bien: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<BienResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (TryGetIntFilter(request, "Resguardo", out var resguardoId))
                {
                    query = query.Where(x => x.Resguardo == resguardoId);
                }

                if (TryGetIntFilter(request, "FkidTipoBienAlma", out var tipoBienId))
                {
                    query = query.Where(x => _context.Biens.Any(b => b.PkidBien == x.PkidBien && b.FkidTipoBienAlma == tipoBienId));
                }

                if (TryGetIntFilter(request, "FkidAreaSis", out var areaId))
                {
                    query = query.Where(x => _context.Biens.Any(b => b.PkidBien == x.PkidBien && b.FkidAreaSis == areaId));
                }

                if (TryGetBoolFilter(request, "EstaResguardado", out var estaResguardado))
                {
                    query = query.Where(x => x.EstaResguardado == estaResguardado);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Clave != null && x.Clave.Contains(filtro)) ||
                        (x.ClaveAnt != null && x.ClaveAnt.Contains(filtro)) ||
                        (x.Descripcion != null && x.Descripcion.Contains(filtro)) ||
                        (x.TipoBienDescripcion != null && x.TipoBienDescripcion.Contains(filtro)) ||
                        (x.TipoBienCodigoClave != null && x.TipoBienCodigoClave.Contains(filtro)) ||
                        (x.MarcaDescripcion != null && x.MarcaDescripcion.Contains(filtro)) ||
                        (x.Modelo != null && x.Modelo.Contains(filtro)) ||
                        (x.Serie != null && x.Serie.Contains(filtro)) ||
                        (x.Factura != null && x.Factura.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)) ||
                        (x.ProveedorNombre != null && x.ProveedorNombre.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
                var responses = items.Adapt<List<BienResponse>>();
                await ApplyEntityKeysAsync(responses);

                return Success(responses, "Bienes obtenidos correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<BienResponse>($"Error al obtener bienes: {ex.Message}");
            }
        }

        private async Task<PagedResult<BienResponse>?> NormalizeAndValidateAsync(BienResponse response, bool isCreate)
        {
            if (response.FkidTipoBienAlma <= 0)
            {
                return Failure<BienResponse>("Debe seleccionar el tipo de bien.");
            }

            if (string.IsNullOrWhiteSpace(response.Descripcion))
            {
                return Failure<BienResponse>("La descripcion del bien es requerida.");
            }

            if (response.ValorActual is <= 0 || (isCreate && !response.ValorActual.HasValue))
            {
                return Failure<BienResponse>("El valor factura debe ser mayor a cero.");
            }

            if (!await _context.TipoBiens.AsNoTracking().AnyAsync(x => x.PkidTipoBien == response.FkidTipoBienAlma && x.Activo))
            {
                return Failure<BienResponse>("El tipo de bien seleccionado no existe o esta inactivo.");
            }

            response.Modelo ??= string.Empty;
            response.Serie ??= string.Empty;
            response.Factura ??= string.Empty;
            response.Requisicion ??= string.Empty;
            response.Referencia ??= string.Empty;
            response.Notas ??= string.Empty;
            response.Ubicacion ??= string.Empty;
            response.Aadquisicion ??= string.Empty;
            response.Rango ??= string.Empty;
            response.Resolucion ??= string.Empty;
            response.Estatus ??= string.Empty;
            response.Caracteristicas ??= string.Empty;
            response.Costo ??= response.ValorActual;
            response.Activo = true;
            response.Localizado ??= true;
            response.EsContabilizado ??= false;

            return null;
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            BienResponse response,
            int usuarioActual)
        {
            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ALMA].[SP_MantenimientoBien]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdBien", id),
                StoredProcedureExecutor.Param("@FKIdGrupoBien_ALMA", response.FkidGrupoBienAlma),
                StoredProcedureExecutor.Param("@FKIdTipoBien_ALMA", response.FkidTipoBienAlma),
                StoredProcedureExecutor.Param("@FKIdArea_SIS", response.FkidAreaSis),
                StoredProcedureExecutor.Param("@FKIdProveedor_SIS", response.FkidProveedorSis),
                StoredProcedureExecutor.Param("@FKIdEstadoBien_ALMA", response.FkidEstadoBienAlma),
                StoredProcedureExecutor.Param("@FKIdTipoPatrimonio_ALMA", response.FkidTipoPatrimonioAlma),
                StoredProcedureExecutor.Param("@FKIdMarca_ALMA", response.FkidMarcaAlma),
                StoredProcedureExecutor.Param("@FKIdMaterial_ALMA", response.FkidMaterialAlma),
                StoredProcedureExecutor.Param("@FKIdTipoAdq_ALMA", response.FkidTipoAdqAlma),
                StoredProcedureExecutor.Param("@FKIdPartida_CONTA", response.FkidPartidaConta),
                StoredProcedureExecutor.Param("@FKIdDetalleOrdenCompra_ORCO", response.FkidDetalleOrdenCompraOrco),
                StoredProcedureExecutor.Param("@Clave", response.Clave),
                StoredProcedureExecutor.Param("@ClaveAnt", response.ClaveAnt),
                StoredProcedureExecutor.Param("@Descripcion", response.Descripcion),
                StoredProcedureExecutor.Param("@Modelo", response.Modelo),
                StoredProcedureExecutor.Param("@Serie", response.Serie),
                StoredProcedureExecutor.Param("@Requisicion", response.Requisicion),
                StoredProcedureExecutor.Param("@Factura", response.Factura),
                StoredProcedureExecutor.Param("@Costo", response.Costo),
                StoredProcedureExecutor.Param("@ValorActual", response.ValorActual),
                StoredProcedureExecutor.Param("@FechaAdq", response.FechaAdq),
                StoredProcedureExecutor.Param("@Referencia", response.Referencia),
                StoredProcedureExecutor.Param("@Notas", response.Notas),
                StoredProcedureExecutor.Param("@Ubicacion", response.Ubicacion),
                StoredProcedureExecutor.Param("@AAdquisicion", response.Aadquisicion),
                StoredProcedureExecutor.Param("@Frente", response.Frente),
                StoredProcedureExecutor.Param("@Fondo", response.Fondo),
                StoredProcedureExecutor.Param("@Altura", response.Altura),
                StoredProcedureExecutor.Param("@Diametro", response.Diametro),
                StoredProcedureExecutor.Param("@VerificacionesDias", response.VerificacionesDias),
                StoredProcedureExecutor.Param("@MantenimientoDias", response.MantenimientoDias),
                StoredProcedureExecutor.Param("@Mantenimiento", response.Mantenimiento),
                StoredProcedureExecutor.Param("@Calibracion", response.Calibracion),
                StoredProcedureExecutor.Param("@Rango", response.Rango),
                StoredProcedureExecutor.Param("@Resolucion", response.Resolucion),
                StoredProcedureExecutor.Param("@FechaUltInv", response.FechaUltInv),
                StoredProcedureExecutor.Param("@FechaReqscn", response.FechaReqscn),
                StoredProcedureExecutor.Param("@Estatus", response.Estatus),
                StoredProcedureExecutor.Param("@Caracteristicas", response.Caracteristicas),
                StoredProcedureExecutor.Param("@Resguardo", response.Resguardo),
                StoredProcedureExecutor.Param("@ValorRescate", response.ValorRescate),
                StoredProcedureExecutor.Param("@Localizado", response.Localizado),
                StoredProcedureExecutor.Param("@EsContabilizado", response.EsContabilizado),
                StoredProcedureExecutor.Param("@LiberarResguardo", false),
                StoredProcedureExecutor.Param("@PropagarOrdenCompra", true),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));
        }

        private async Task ApplyEntityKeysAsync(IList<BienResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var ids = items.Select(x => x.PkidBien).Distinct().ToList();
            var keys = await _context.Biens
                .AsNoTracking()
                .Where(x => ids.Contains(x.PkidBien))
                .Select(x => new
                {
                    x.PkidBien,
                    x.FkidGrupoBienAlma,
                    x.FkidTipoBienAlma,
                    x.FkidAreaSis,
                    x.FkidProveedorSis,
                    x.FkidEstadoBienAlma,
                    x.FkidTipoPatrimonioAlma,
                    x.FkidMarcaAlma,
                    x.FkidMaterialAlma,
                    x.FkidTipoAdqAlma,
                    x.FkidPartidaConta,
                    x.FkidDetalleOrdenCompraOrco,
                    x.Resguardo,
                    x.ResguardoAnterior,
                    x.RelId
                })
                .ToDictionaryAsync(x => x.PkidBien);

            foreach (var item in items)
            {
                if (!keys.TryGetValue(item.PkidBien, out var key))
                {
                    continue;
                }

                item.FkidGrupoBienAlma = key.FkidGrupoBienAlma;
                item.FkidTipoBienAlma = key.FkidTipoBienAlma;
                item.FkidAreaSis = key.FkidAreaSis;
                item.FkidProveedorSis = key.FkidProveedorSis;
                item.FkidEstadoBienAlma = key.FkidEstadoBienAlma;
                item.FkidTipoPatrimonioAlma = key.FkidTipoPatrimonioAlma;
                item.FkidMarcaAlma = key.FkidMarcaAlma;
                item.FkidMaterialAlma = key.FkidMaterialAlma;
                item.FkidTipoAdqAlma = key.FkidTipoAdqAlma;
                item.FkidPartidaConta = key.FkidPartidaConta;
                item.FkidDetalleOrdenCompraOrco = key.FkidDetalleOrdenCompraOrco;
                item.Resguardo = key.Resguardo;
                item.ResguardoAnterior = key.ResguardoAnterior;
                item.RelId = key.RelId;
            }
        }

        private static IQueryable<VwBien> ApplySort(IQueryable<VwBien> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "Clave" => ascending ? query.OrderBy(x => x.Clave) : query.OrderByDescending(x => x.Clave),
                "Descripcion" => ascending ? query.OrderBy(x => x.Descripcion) : query.OrderByDescending(x => x.Descripcion),
                "TipoBienDescripcion" => ascending ? query.OrderBy(x => x.TipoBienDescripcion) : query.OrderByDescending(x => x.TipoBienDescripcion),
                "AreaNombre" => ascending ? query.OrderBy(x => x.AreaNombre) : query.OrderByDescending(x => x.AreaNombre),
                "ValorActual" => ascending ? query.OrderBy(x => x.ValorActual) : query.OrderByDescending(x => x.ValorActual),
                "FechaAdq" => ascending ? query.OrderBy(x => x.FechaAdq) : query.OrderByDescending(x => x.FechaAdq),
                "EstaResguardado" => ascending ? query.OrderBy(x => x.EstaResguardado) : query.OrderByDescending(x => x.EstaResguardado),
                _ => ascending ? query.OrderByDescending(x => x.PkidBien) : query.OrderBy(x => x.PkidBien)
            };
        }

        private static PagedResult<BienResponse> Success(List<BienResponse> items, string message, int total)
        {
            return new PagedResult<BienResponse>
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

        private static bool TryGetBoolFilter(PagedRequest request, string key, out bool value)
        {
            value = false;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            {
                return false;
            }

            if (raw is JsonElement json)
            {
                if (json.ValueKind == JsonValueKind.True || json.ValueKind == JsonValueKind.False)
                {
                    value = json.GetBoolean();
                    return true;
                }

                if (json.ValueKind == JsonValueKind.String && bool.TryParse(json.GetString(), out value))
                {
                    return true;
                }
            }

            return bool.TryParse(raw.ToString(), out value);
        }
    }
}
