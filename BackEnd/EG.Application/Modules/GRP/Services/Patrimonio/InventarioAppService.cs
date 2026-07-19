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
    public class InventarioAppService : IInventarioAppService
    {
        private const string EstatusInicial = "INICIAL";

        private readonly GenericService<Inventario, InventarioDto, InventarioResponse> _service;
        private readonly GenericService<VwInventario, InventarioDto, InventarioResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public InventarioAppService(
            GenericService<Inventario, InventarioDto, InventarioResponse> service,
            GenericService<VwInventario, InventarioDto, InventarioResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<InventarioResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            await ApplyStatusFlagsAsync(items);
            return Success(items, "Inventarios obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<InventarioResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidInventario");
            if (item == null)
            {
                return Failure<InventarioResponse>($"Inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            await ApplyStatusFlagsAsync(new List<InventarioResponse> { item });

            return new PagedResult<InventarioResponse>
            {
                Success = true,
                Message = "Inventario encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<InventarioResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<InventarioResponse>> CreateAsync(InventarioResponse response, int usuarioActual)
        {
            // La autorización se concede únicamente mediante el flujo posterior al alta.
            response.Autorizado = false;
            var validation = await NormalizeAndValidateAsync(response, isCreate: true);
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

                return new PagedResult<InventarioResponse>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = "SUCCESS",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return Failure<InventarioResponse>($"Error al crear inventario: {ex.Message}");
            }
        }

        public async Task<PagedResult<InventarioResponse>> UpdateAsync(int id, InventarioResponse response, int usuarioActual)
        {
            var current = await _context.Inventarios
                .AsNoTracking()
                .Include(x => x.FkidEstatusInventarioAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidInventario == id && x.Activo);

            if (current == null)
            {
                return Failure<InventarioResponse>($"Inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (IsLocked(current))
            {
                return Failure<InventarioResponse>("El inventario ya esta autorizado o en estatus final y no puede modificarse.", "INVALID_STATE");
            }

            response.PkidInventario = id;
            var validation = await NormalizeAndValidateAsync(response, isCreate: false);
            if (validation != null)
            {
                return validation;
            }

            response.Folio = string.IsNullOrWhiteSpace(response.Folio) ? current.Folio ?? string.Empty : response.Folio;
            response.UsuarioCreacion = current.UsuarioCreacion;
            response.FechaCreacion = current.FechaCreacion;

            try
            {
                var action = await ResolveUpdateActionAsync(response);
                var result = await ExecuteMantenimientoAsync(action, id, response, usuarioActual);
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = result.Mensaje;
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<InventarioResponse>($"Error al actualizar inventario: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await _context.Inventarios
                .AsNoTracking()
                .Include(x => x.FkidEstatusInventarioAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidInventario == id && x.Activo);

            if (current == null)
            {
                return BoolFailure($"Inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (IsLocked(current))
            {
                return BoolFailure("El inventario ya esta autorizado o en estatus final y no puede eliminarse.", "INVALID_STATE");
            }

            try
            {
                var result = await ExecuteMantenimientoAsync(3, id, new InventarioResponse
                {
                    PkidInventario = id,
                    FkidEmpresaSis = current.FkidEmpresaSis,
                    FkidCalendarioInventarioAlma = current.FkidCalendarioInventarioAlma,
                    FkidAreaSis = current.FkidAreaSis,
                    FkidEstatusInventarioAlma = current.FkidEstatusInventarioAlma,
                    FechaInventario = current.FechaInventario.ToDateTime(TimeOnly.MinValue),
                    Responsable = current.Responsable ?? string.Empty,
                    Observaciones = current.Observaciones ?? string.Empty
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
                return BoolFailure($"Error al eliminar inventario: {ex.Message}");
            }
        }

        public async Task<PagedResult<InventarioResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (PatrimonioPagedFilter.TryGetInt(request, "FkidEmpresaSis", out var empresaId))
                {
                    query = query.Where(x => x.FkidEmpresaSis == empresaId);
                }

                if (PatrimonioPagedFilter.TryGetInt(request, "FkidCalendarioInventarioAlma", out var calendarioId))
                {
                    query = query.Where(x => x.FkidCalendarioInventarioAlma == calendarioId);
                }

                if (PatrimonioPagedFilter.TryGetInt(request, "FkidAreaSis", out var areaId))
                {
                    query = query.Where(x => x.FkidAreaSis == areaId);
                }

                if (PatrimonioPagedFilter.TryGetInt(request, "FkidEstatusInventarioAlma", out var estatusId))
                {
                    query = query.Where(x => x.FkidEstatusInventarioAlma == estatusId);
                }

                if (PatrimonioPagedFilter.TryGetBool(request, "Autorizado", out var autorizado))
                {
                    query = query.Where(x => x.Autorizado == autorizado);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Folio != null && x.Folio.Contains(filtro)) ||
                        (x.CalendarioFolio != null && x.CalendarioFolio.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)) ||
                        (x.EstatusDescripcion != null && x.EstatusDescripcion.Contains(filtro)) ||
                        (x.Responsable != null && x.Responsable.Contains(filtro)) ||
                        (x.Observaciones != null && x.Observaciones.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
                var responses = items.Adapt<List<InventarioResponse>>();
                await ApplyStatusFlagsAsync(responses);

                return Success(responses, "Inventarios obtenidos correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<InventarioResponse>($"Error al obtener inventarios: {ex.Message}");
            }
        }

        private async Task<PagedResult<InventarioResponse>?> NormalizeAndValidateAsync(InventarioResponse response, bool isCreate)
        {
            _service.ApplyCurrentEmpresaIfPresent(response);

            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<InventarioResponse>("Debe existir una empresa seleccionada.");
            }

            if (!response.FkidCalendarioInventarioAlma.HasValue || response.FkidCalendarioInventarioAlma.Value <= 0)
            {
                return Failure<InventarioResponse>("Debe seleccionar un calendario de inventario.");
            }

            var calendario = await _context.CalendarioInventarios
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidCalendarioInventario == response.FkidCalendarioInventarioAlma.Value && x.Activo);
            if (calendario == null)
            {
                return Failure<InventarioResponse>("El calendario seleccionado no existe o esta inactivo.");
            }

            if (calendario.FkidEmpresaSis != response.FkidEmpresaSis)
            {
                return Failure<InventarioResponse>("El calendario no pertenece a la empresa seleccionada.");
            }

            response.FkidAreaSis ??= calendario.FkidAreaSis;
            if (!response.FkidAreaSis.HasValue || response.FkidAreaSis.Value <= 0)
            {
                return Failure<InventarioResponse>("El inventario debe quedar asociado a un area.");
            }

            if (response.FkidEstatusInventarioAlma <= 0)
            {
                var inicial = await GetInitialStatusAsync();
                if (inicial == null)
                {
                    return Failure<InventarioResponse>("No existe estatus inicial para inventarios.");
                }

                response.FkidEstatusInventarioAlma = inicial.PkidEstatusInventario;
            }

            if (!await _context.EstatusInventarios.AsNoTracking().AnyAsync(x => x.PkidEstatusInventario == response.FkidEstatusInventarioAlma && x.Activo))
            {
                return Failure<InventarioResponse>("El estatus seleccionado no existe o esta inactivo.");
            }

            response.FechaInventario = response.FechaInventario == default ? DateTime.Today : response.FechaInventario.Date;
            response.Responsable ??= string.Empty;
            response.Observaciones ??= string.Empty;
            response.Folio ??= string.Empty;
            response.Activo = true;

            return null;
        }

        private async Task<int> ResolveUpdateActionAsync(InventarioResponse response)
        {
            if (response.Autorizado)
            {
                return 4;
            }

            var status = await _context.EstatusInventarios
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidEstatusInventario == response.FkidEstatusInventarioAlma);

            return status?.EsFinal == true ? 4 : 2;
        }

        private async Task<EstatusInventario?> GetInitialStatusAsync()
        {
            return await _context.EstatusInventarios
                .AsNoTracking()
                .Where(x => x.Activo)
                .OrderByDescending(x => x.Descripcion == EstatusInicial)
                .ThenBy(x => x.Orden)
                .FirstOrDefaultAsync();
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(int action, int? id, InventarioResponse response, int usuarioActual)
        {
            var idParameter = new SqlParameter("@Id", id.HasValue ? id.Value : DBNull.Value)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                SqlDbType = System.Data.SqlDbType.Int
            };

            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ALMA].[SP_MantenimientoInventario]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdInventario", id),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdCalendarioInventario_ALMA", response.FkidCalendarioInventarioAlma),
                StoredProcedureExecutor.Param("@FKIdArea_SIS", response.FkidAreaSis),
                StoredProcedureExecutor.Param("@FKIdEstatusInventario_ALMA", response.FkidEstatusInventarioAlma),
                StoredProcedureExecutor.Param("@FechaInventario", response.FechaInventario.Date),
                StoredProcedureExecutor.Param("@Responsable", response.Responsable),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                idParameter);
        }

        private async Task ApplyStatusFlagsAsync(IList<InventarioResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var statusIds = items.Select(x => x.FkidEstatusInventarioAlma).Distinct().ToList();
            var statusMap = await _context.EstatusInventarios
                .AsNoTracking()
                .Where(x => statusIds.Contains(x.PkidEstatusInventario))
                .ToDictionaryAsync(x => x.PkidEstatusInventario, x => x.EsFinal);

            foreach (var item in items)
            {
                if (statusMap.TryGetValue(item.FkidEstatusInventarioAlma, out var esFinal))
                {
                    item.EsFinal = esFinal;
                }
            }
        }

        private static bool IsLocked(Inventario inventario) =>
            inventario.Autorizado || inventario.FkidEstatusInventarioAlmaNavigation?.EsFinal == true;

        private static IQueryable<VwInventario> ApplySort(IQueryable<VwInventario> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "Folio" => ascending ? query.OrderBy(x => x.Folio) : query.OrderByDescending(x => x.Folio),
                "CalendarioFolio" => ascending ? query.OrderBy(x => x.CalendarioFolio) : query.OrderByDescending(x => x.CalendarioFolio),
                "AreaNombre" => ascending ? query.OrderBy(x => x.AreaNombre) : query.OrderByDescending(x => x.AreaNombre),
                "EstatusDescripcion" => ascending ? query.OrderBy(x => x.EstatusDescripcion) : query.OrderByDescending(x => x.EstatusDescripcion),
                "FechaInventario" => ascending ? query.OrderBy(x => x.FechaInventario) : query.OrderByDescending(x => x.FechaInventario),
                "Responsable" => ascending ? query.OrderBy(x => x.Responsable) : query.OrderByDescending(x => x.Responsable),
                "TotalBienes" => ascending ? query.OrderBy(x => x.TotalBienes) : query.OrderByDescending(x => x.TotalBienes),
                "TotalDiferencias" => ascending ? query.OrderBy(x => x.TotalDiferencias) : query.OrderByDescending(x => x.TotalDiferencias),
                _ => ascending ? query.OrderByDescending(x => x.PkidInventario) : query.OrderBy(x => x.PkidInventario)
            };
        }

        private static PagedResult<InventarioResponse> Success(List<InventarioResponse> items, string message, int total)
        {
            return new PagedResult<InventarioResponse>
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

        private static PagedResult<bool> BoolFailure(string message, string code = "ERROR")
        {
            return new PagedResult<bool>
            {
                Success = false,
                Message = message,
                Code = code,
                Data = false,
                TotalCount = 0
            };
        }
    }
}
