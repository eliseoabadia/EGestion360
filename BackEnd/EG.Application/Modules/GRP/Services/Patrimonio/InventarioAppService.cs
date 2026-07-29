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
            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            var calendarios = _context.CalendarioInventarios
                .AsNoTracking()
                .Where(x => x.Activo && x.FkidEmpresaSis == scope.EmpresaId && x.Anio == scope.Anio)
                .Select(x => x.PkidCalendarioInventario);
            var entities = await _serviceView.GetQueryWithIncludes()
                .Where(x => x.FkidEmpresaSis == scope.EmpresaId &&
                    x.FkidCalendarioInventarioAlma.HasValue && calendarios.Contains(x.FkidCalendarioInventarioAlma.Value))
                .ToListAsync();
            var items = entities.Adapt<List<InventarioResponse>>();
            await ApplyStatusFlagsAsync(items);
            return Success(items, "Inventarios obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<InventarioResponse>> GetByIdAsync(int id)
        {
            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            var entity = await _serviceView.GetQueryWithIncludes()
                .Where(x => x.PkidInventario == id && x.FkidEmpresaSis == scope.EmpresaId)
                .Join(_context.CalendarioInventarios.AsNoTracking(),
                    inventario => inventario.FkidCalendarioInventarioAlma,
                    calendario => (int?)calendario.PkidCalendarioInventario,
                    (inventario, calendario) => new { inventario, calendario })
                .Where(x => x.calendario.Activo && x.calendario.Anio == scope.Anio)
                .Select(x => x.inventario)
                .FirstOrDefaultAsync();
            if (entity == null)
            {
                return Failure<InventarioResponse>($"Inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            var item = entity.Adapt<InventarioResponse>();

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
            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            response.FkidEmpresaSis = scope.EmpresaId;
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
            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            var current = await _context.Inventarios
                .AsNoTracking()
                .Include(x => x.FkidEstatusInventarioAlmaNavigation)
                .Include(x => x.FkidCalendarioInventarioAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidInventario == id && x.Activo &&
                    x.FkidEmpresaSis == scope.EmpresaId &&
                    x.FkidCalendarioInventarioAlmaNavigation != null &&
                    x.FkidCalendarioInventarioAlmaNavigation.Anio == scope.Anio);

            if (current == null)
            {
                return Failure<InventarioResponse>($"Inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (IsLocked(current))
            {
                return Failure<InventarioResponse>("El inventario ya esta autorizado o en estatus final y no puede modificarse.", "INVALID_STATE");
            }

            if (response.Autorizado || response.FkidEstatusInventarioAlma != current.FkidEstatusInventarioAlma)
            {
                return Failure<InventarioResponse>("El estatus no se modifica desde la edición. Use la acción de autorizar inventario.", "INVALID_TRANSITION");
            }

            response.PkidInventario = id;
            response.FkidEmpresaSis = current.FkidEmpresaSis;
            response.FkidCalendarioInventarioAlma = current.FkidCalendarioInventarioAlma;
            response.FkidAreaSis = current.FkidAreaSis;
            response.FkidEstatusInventarioAlma = current.FkidEstatusInventarioAlma;
            response.Autorizado = false;
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
                var result = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
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
            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            var current = await _context.Inventarios
                .AsNoTracking()
                .Include(x => x.FkidEstatusInventarioAlmaNavigation)
                .Include(x => x.FkidCalendarioInventarioAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidInventario == id && x.Activo &&
                    x.FkidEmpresaSis == scope.EmpresaId &&
                    x.FkidCalendarioInventarioAlmaNavigation != null &&
                    x.FkidCalendarioInventarioAlmaNavigation.Anio == scope.Anio);

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
                var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
                var calendarios = _context.CalendarioInventarios.AsNoTracking()
                    .Where(x => x.Activo && x.FkidEmpresaSis == scope.EmpresaId && x.Anio == scope.Anio)
                    .Select(x => x.PkidCalendarioInventario);
                var query = _serviceView.GetQueryWithIncludes()
                    .Where(x => x.FkidEmpresaSis == scope.EmpresaId && x.FkidCalendarioInventarioAlma.HasValue && calendarios.Contains(x.FkidCalendarioInventarioAlma.Value));

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

            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            if (calendario.FkidEmpresaSis != scope.EmpresaId || calendario.Anio != scope.Anio)
            {
                return Failure<InventarioResponse>("El calendario no pertenece a la empresa y ejercicio presupuestal seleccionados.");
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

            var estatus = await _context.EstatusInventarios.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidEstatusInventario == response.FkidEstatusInventarioAlma && x.Activo);
            if (estatus == null)
            {
                return Failure<InventarioResponse>("El estatus seleccionado no existe o esta inactivo.");
            }

            if (estatus.EsFinal)
            {
                return Failure<InventarioResponse>("El estatus final solo se asigna mediante la autorizacion del inventario.", "INVALID_TRANSITION");
            }

            response.FechaInventario = response.FechaInventario == default ? DateTime.Today : response.FechaInventario.Date;
            if (response.FechaInventario.Year != calendario.Anio ||
                response.FechaInventario.Date < calendario.FechaInicio.ToDateTime(TimeOnly.MinValue) ||
                response.FechaInventario.Date > calendario.FechaFin.ToDateTime(TimeOnly.MinValue))
            {
                return Failure<InventarioResponse>("La fecha del inventario debe quedar dentro del calendario del ejercicio seleccionado.");
            }
            response.Responsable ??= string.Empty;
            response.Observaciones ??= string.Empty;
            response.Folio ??= string.Empty;
            response.Activo = true;

            return null;
        }

        public async Task<PagedResult<InventarioResponse>> AutorizarAsync(int id, int usuarioActual)
        {
            var scope = await PatrimonioScopeResolver.RequireAsync(_context, _userContext);
            var current = await _context.Inventarios
                .AsNoTracking()
                .Include(x => x.FkidEstatusInventarioAlmaNavigation)
                .Include(x => x.FkidCalendarioInventarioAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidInventario == id && x.Activo &&
                    x.FkidEmpresaSis == scope.EmpresaId &&
                    x.FkidCalendarioInventarioAlmaNavigation != null &&
                    x.FkidCalendarioInventarioAlmaNavigation.Anio == scope.Anio);
            if (current == null)
            {
                return Failure<InventarioResponse>($"Inventario con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (IsLocked(current))
            {
                return Failure<InventarioResponse>("El inventario ya esta autorizado o en estatus final.", "INVALID_STATE");
            }

            if (!await _context.InventarioDetalles.AsNoTracking().AnyAsync(x => x.FkidInventarioAlma == id && x.Activo))
            {
                return Failure<InventarioResponse>("Agrega al menos un bien antes de autorizar el inventario.", "INVALID_STATE");
            }

            var result = await ExecuteMantenimientoAsync(4, id, new InventarioResponse
            {
                PkidInventario = current.PkidInventario,
                FkidEmpresaSis = current.FkidEmpresaSis,
                FkidCalendarioInventarioAlma = current.FkidCalendarioInventarioAlma,
                FkidAreaSis = current.FkidAreaSis,
                FkidEstatusInventarioAlma = current.FkidEstatusInventarioAlma,
                FechaInventario = current.FechaInventario.ToDateTime(TimeOnly.MinValue),
                Responsable = current.Responsable ?? string.Empty,
                Observaciones = current.Observaciones ?? string.Empty
            }, usuarioActual);
            var refreshed = await GetByIdAsync(id);
            refreshed.Message = result.Mensaje;
            return refreshed;
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
