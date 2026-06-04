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
    public class ResguardoAppService : IResguardoAppService
    {
        private readonly GenericService<Resguardo, ResguardoDto, ResguardoResponse> _service;
        private readonly GenericService<VwResguardo, ResguardoDto, ResguardoResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public ResguardoAppService(
            GenericService<Resguardo, ResguardoDto, ResguardoResponse> service,
            GenericService<VwResguardo, ResguardoDto, ResguardoResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<ResguardoResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            return Success(items, "Resguardos obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<ResguardoResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidResguardo");
            if (item == null)
            {
                return Failure<ResguardoResponse>($"Resguardo con ID {id} no encontrado.", "NOT_FOUND");
            }

            return new PagedResult<ResguardoResponse>
            {
                Success = true,
                Message = "Resguardo encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<ResguardoResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<ResguardoResponse>> CreateAsync(ResguardoResponse response, int usuarioActual)
        {
            var validation = Validate(response);
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

                return new PagedResult<ResguardoResponse>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = "SUCCESS",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return Failure<ResguardoResponse>($"Error al crear resguardo: {ex.Message}");
            }
        }

        public async Task<PagedResult<ResguardoResponse>> UpdateAsync(int id, ResguardoResponse response, int usuarioActual)
        {
            if (!await _context.Resguardos.AsNoTracking().AnyAsync(x => x.PkidResguardo == id && x.Activo))
            {
                return Failure<ResguardoResponse>($"Resguardo con ID {id} no encontrado.", "NOT_FOUND");
            }

            var validation = Validate(response);
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
                return Failure<ResguardoResponse>($"Error al actualizar resguardo: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var result = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ALMA].[SP_MantenimientoResguardo]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdResguardo", id),
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
                    Message = $"Error al eliminar resguardo: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ResguardoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (TryGetIntFilter(request, "FkidEmpresaSis", out var empresaId))
                {
                    query = query.Where(x => x.FkidEmpresaSis == empresaId);
                }

                if (TryGetIntFilter(request, "FkidAreaSis", out var areaId))
                {
                    query = query.Where(x => x.FkidAreaSis == areaId);
                }

                if (TryGetIntFilter(request, "FkidPersonaNom", out var personaId))
                {
                    query = query.Where(x => x.FkidPersonaNom == personaId);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Folio != null && x.Folio.Contains(filtro)) ||
                        (x.PersonaNombre != null && x.PersonaNombre.Contains(filtro)) ||
                        (x.PersonaClave != null && x.PersonaClave.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)) ||
                        (x.Observaciones != null && x.Observaciones.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

                return Success(items.Adapt<List<ResguardoResponse>>(), "Resguardos obtenidos correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<ResguardoResponse>($"Error al obtener resguardos: {ex.Message}");
            }
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            ResguardoResponse response,
            int usuarioActual)
        {
            _service.ApplyCurrentEmpresaIfPresent(response);

            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ALMA].[SP_MantenimientoResguardo]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdResguardo", id),
                StoredProcedureExecutor.Param("@Folio", response.Folio),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdArea_SIS", response.FkidAreaSis),
                StoredProcedureExecutor.Param("@FKIdPersona_NOM", response.FkidPersonaNom),
                StoredProcedureExecutor.Param("@FechaResguardo", response.FechaResguardo.Date),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));
        }

        private static PagedResult<ResguardoResponse>? Validate(ResguardoResponse response)
        {
            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<ResguardoResponse>("Debe existir una empresa seleccionada.");
            }

            if (response.FkidPersonaNom <= 0)
            {
                return Failure<ResguardoResponse>("Debe seleccionar la persona responsable.");
            }

            if (response.FechaResguardo == default)
            {
                response.FechaResguardo = DateTime.Today;
            }

            response.Folio ??= string.Empty;
            response.Observaciones ??= string.Empty;
            response.Activo = true;

            return null;
        }

        private static IQueryable<VwResguardo> ApplySort(IQueryable<VwResguardo> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "Folio" => ascending ? query.OrderBy(x => x.Folio) : query.OrderByDescending(x => x.Folio),
                "PersonaNombre" => ascending ? query.OrderBy(x => x.PersonaNombre) : query.OrderByDescending(x => x.PersonaNombre),
                "AreaNombre" => ascending ? query.OrderBy(x => x.AreaNombre) : query.OrderByDescending(x => x.AreaNombre),
                "FechaResguardo" => ascending ? query.OrderBy(x => x.FechaResguardo) : query.OrderByDescending(x => x.FechaResguardo),
                "TotalBienes" => ascending ? query.OrderBy(x => x.TotalBienes) : query.OrderByDescending(x => x.TotalBienes),
                _ => ascending ? query.OrderByDescending(x => x.PkidResguardo) : query.OrderBy(x => x.PkidResguardo)
            };
        }

        private static PagedResult<ResguardoResponse> Success(List<ResguardoResponse> items, string message, int total)
        {
            return new PagedResult<ResguardoResponse>
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
