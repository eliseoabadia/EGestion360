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
    public class ResguardoDetalleAppService : IResguardoDetalleAppService
    {
        private readonly GenericService<ResguardoDetalle, ResguardoDetalleDto, ResguardoDetalleResponse> _service;
        private readonly GenericService<VwResguardoDetalle, ResguardoDetalleDto, ResguardoDetalleResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public ResguardoDetalleAppService(
            GenericService<ResguardoDetalle, ResguardoDetalleDto, ResguardoDetalleResponse> service,
            GenericService<VwResguardoDetalle, ResguardoDetalleDto, ResguardoDetalleResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            return Success(items, "Detalles de resguardo obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidResguardoDetalle");
            if (item == null)
            {
                return Failure<ResguardoDetalleResponse>($"Detalle de resguardo con ID {id} no encontrado.", "NOT_FOUND");
            }

            return new PagedResult<ResguardoDetalleResponse>
            {
                Success = true,
                Message = "Detalle de resguardo encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<ResguardoDetalleResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> CreateAsync(ResguardoDetalleResponse response, int usuarioActual)
        {
            var validation = Validate(response, true);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var result = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                var id = result.GetId();
                if (id.HasValue)
                {
                    var refreshed = await GetByIdAsync(id.Value);
                    refreshed.Message = result.Mensaje;
                    return refreshed;
                }

                return new PagedResult<ResguardoDetalleResponse>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = "SUCCESS",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return Failure<ResguardoDetalleResponse>($"Error al asignar resguardo: {ex.Message}");
            }
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> UpdateAsync(int id, ResguardoDetalleResponse response, int usuarioActual)
        {
            if (!await _context.ResguardoDetalles.AsNoTracking().AnyAsync(x => x.PkidResguardoDetalle == id && x.Activo))
            {
                return Failure<ResguardoDetalleResponse>($"Detalle de resguardo con ID {id} no encontrado.", "NOT_FOUND");
            }

            var validation = Validate(response, false);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var result = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = result.Mensaje;
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<ResguardoDetalleResponse>($"Error al actualizar detalle de resguardo: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var result = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ALMA].[SP_MantenimientoResguardoDetalle]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdResguardoDetalle", id),
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
                    Message = $"Error al liberar resguardo: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ResguardoDetalleResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (TryGetIntFilter(request, "FkidBienAlma", out var bienId))
                {
                    query = query.Where(x => x.FkidBienAlma == bienId);
                }

                if (TryGetIntFilter(request, "FkidResguardoAlma", out var resguardoId))
                {
                    query = query.Where(x => x.FkidResguardoAlma == resguardoId);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Folio != null && x.Folio.Contains(filtro)) ||
                        (x.PersonaNombre != null && x.PersonaNombre.Contains(filtro)) ||
                        (x.BienClave != null && x.BienClave.Contains(filtro)) ||
                        (x.BienDescripcion != null && x.BienDescripcion.Contains(filtro)) ||
                        (x.TipoBienDescripcion != null && x.TipoBienDescripcion.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

                return Success(items.Adapt<List<ResguardoDetalleResponse>>(), "Detalles de resguardo obtenidos correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<ResguardoDetalleResponse>($"Error al obtener detalles de resguardo: {ex.Message}");
            }
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            ResguardoDetalleResponse response,
            int usuarioActual)
        {
            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ALMA].[SP_MantenimientoResguardoDetalle]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdResguardoDetalle", id),
                StoredProcedureExecutor.Param("@FKIdResguardo_ALMA", response.FkidResguardoAlma),
                StoredProcedureExecutor.Param("@FKIdBien_ALMA", response.FkidBienAlma),
                StoredProcedureExecutor.Param("@FKIdEstadoBien_ALMA", response.FkidEstadoBienAlma),
                StoredProcedureExecutor.Param("@ImprimeEtiqueta", response.ImprimeEtiqueta),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));
        }

        private static PagedResult<ResguardoDetalleResponse>? Validate(ResguardoDetalleResponse response, bool isCreate)
        {
            if (isCreate && response.FkidResguardoAlma <= 0)
            {
                return Failure<ResguardoDetalleResponse>("Debe seleccionar el resguardo.");
            }

            if (isCreate && response.FkidBienAlma <= 0)
            {
                return Failure<ResguardoDetalleResponse>("Debe existir un bien seleccionado.");
            }

            response.ImprimeEtiqueta = true;
            response.Observaciones ??= string.Empty;
            response.Activo = true;

            return null;
        }

        private static IQueryable<VwResguardoDetalle> ApplySort(IQueryable<VwResguardoDetalle> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "Folio" => ascending ? query.OrderBy(x => x.Folio) : query.OrderByDescending(x => x.Folio),
                "PersonaNombre" => ascending ? query.OrderBy(x => x.PersonaNombre) : query.OrderByDescending(x => x.PersonaNombre),
                "BienClave" => ascending ? query.OrderBy(x => x.BienClave) : query.OrderByDescending(x => x.BienClave),
                "FechaAsignacion" => ascending ? query.OrderBy(x => x.FechaAsignacion) : query.OrderByDescending(x => x.FechaAsignacion),
                _ => ascending ? query.OrderByDescending(x => x.PkidResguardoDetalle) : query.OrderBy(x => x.PkidResguardoDetalle)
            };
        }

        private static PagedResult<ResguardoDetalleResponse> Success(List<ResguardoDetalleResponse> items, string message, int total)
        {
            return new PagedResult<ResguardoDetalleResponse>
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
