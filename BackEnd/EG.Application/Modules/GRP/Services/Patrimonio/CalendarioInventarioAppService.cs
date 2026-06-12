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
    public class CalendarioInventarioAppService : ICalendarioInventarioAppService
    {
        private readonly GenericService<CalendarioInventario, CalendarioInventarioDto, CalendarioInventarioResponse> _service;
        private readonly GenericService<VwCalendarioInventario, CalendarioInventarioDto, CalendarioInventarioResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public CalendarioInventarioAppService(
            GenericService<CalendarioInventario, CalendarioInventarioDto, CalendarioInventarioResponse> service,
            GenericService<VwCalendarioInventario, CalendarioInventarioDto, CalendarioInventarioResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<CalendarioInventarioResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            await ApplyInventoryCountsAsync(items);
            return Success(items, "Calendarios de inventario obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<CalendarioInventarioResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidCalendarioInventario");
            if (item == null)
            {
                return Failure<CalendarioInventarioResponse>($"Calendario con ID {id} no encontrado.", "NOT_FOUND");
            }

            await ApplyInventoryCountsAsync(new List<CalendarioInventarioResponse> { item });

            return new PagedResult<CalendarioInventarioResponse>
            {
                Success = true,
                Message = "Calendario encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<CalendarioInventarioResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<CalendarioInventarioResponse>> CreateAsync(CalendarioInventarioResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, isCreate: true);
            if (validation != null)
            {
                return validation;
            }

            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                await ArchiveCurrentInventariosAsync(response.FkidEmpresaSis, response.FkidAreaSis!.Value, usuarioActual);
                var result = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                await transaction.CommitAsync();

                var id = result.GetId();
                if (id.HasValue)
                {
                    var refreshed = await GetByIdAsync(id.Value);
                    refreshed.Message = result.Mensaje;
                    return refreshed;
                }

                return new PagedResult<CalendarioInventarioResponse>
                {
                    Success = true,
                    Message = result.Mensaje,
                    Code = "SUCCESS",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return Failure<CalendarioInventarioResponse>($"Error al crear calendario: {ex.Message}");
            }
        }

        public async Task<PagedResult<CalendarioInventarioResponse>> UpdateAsync(int id, CalendarioInventarioResponse response, int usuarioActual)
        {
            var current = await _context.CalendarioInventarios.AsNoTracking().FirstOrDefaultAsync(x => x.PkidCalendarioInventario == id && x.Activo);
            if (current == null)
            {
                return Failure<CalendarioInventarioResponse>($"Calendario con ID {id} no encontrado.", "NOT_FOUND");
            }

            response.PkidCalendarioInventario = id;
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
                return Failure<CalendarioInventarioResponse>($"Error al actualizar calendario: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await _context.CalendarioInventarios.AsNoTracking().FirstOrDefaultAsync(x => x.PkidCalendarioInventario == id && x.Activo);
            if (current == null)
            {
                return BoolFailure($"Calendario con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (await _context.Inventarios.AsNoTracking().AnyAsync(x => x.FkidCalendarioInventarioAlma == id && x.Activo))
            {
                return BoolFailure("El calendario tiene inventarios activos y no puede eliminarse.", "INVALID_STATE");
            }

            try
            {
                var result = await ExecuteMantenimientoAsync(3, id, new CalendarioInventarioResponse
                {
                    PkidCalendarioInventario = id,
                    FkidEmpresaSis = current.FkidEmpresaSis,
                    FkidAreaSis = current.FkidAreaSis,
                    Anio = current.Anio,
                    Descripcion = current.Descripcion ?? string.Empty,
                    FechaInicio = current.FechaInicio.ToDateTime(TimeOnly.MinValue),
                    FechaFin = current.FechaFin.ToDateTime(TimeOnly.MinValue),
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
                return BoolFailure($"Error al eliminar calendario: {ex.Message}");
            }
        }

        public async Task<PagedResult<CalendarioInventarioResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (PatrimonioPagedFilter.TryGetInt(request, "FkidEmpresaSis", out var empresaId))
                {
                    query = query.Where(x => x.FkidEmpresaSis == empresaId);
                }

                if (PatrimonioPagedFilter.TryGetInt(request, "FkidAreaSis", out var areaId))
                {
                    query = query.Where(x => x.FkidAreaSis == areaId);
                }

                if (PatrimonioPagedFilter.TryGetInt(request, "Anio", out var anio))
                {
                    query = query.Where(x => x.Anio == anio);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Folio != null && x.Folio.Contains(filtro)) ||
                        (x.Descripcion != null && x.Descripcion.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)) ||
                        (x.EmpresaNombre != null && x.EmpresaNombre.Contains(filtro)) ||
                        (x.Observaciones != null && x.Observaciones.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
                var responses = items.Adapt<List<CalendarioInventarioResponse>>();
                await ApplyInventoryCountsAsync(responses);

                return Success(responses, "Calendarios de inventario obtenidos correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<CalendarioInventarioResponse>($"Error al obtener calendarios: {ex.Message}");
            }
        }

        private async Task<PagedResult<CalendarioInventarioResponse>?> NormalizeAndValidateAsync(CalendarioInventarioResponse response, bool isCreate)
        {
            _service.ApplyCurrentEmpresaIfPresent(response);

            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<CalendarioInventarioResponse>("Debe existir una empresa seleccionada.");
            }

            if (!response.FkidAreaSis.HasValue || response.FkidAreaSis.Value <= 0)
            {
                return Failure<CalendarioInventarioResponse>("Debe seleccionar el area del periodo de inventario.");
            }

            if (!await _context.Areas.AsNoTracking().AnyAsync(x => x.PkidArea == response.FkidAreaSis.Value && x.Activo))
            {
                return Failure<CalendarioInventarioResponse>("El area seleccionada no existe o esta inactiva.");
            }

            if (string.IsNullOrWhiteSpace(response.Descripcion))
            {
                return Failure<CalendarioInventarioResponse>("La descripcion del calendario es requerida.");
            }

            response.FechaInicio = response.FechaInicio == default ? DateTime.Today : response.FechaInicio.Date;
            response.FechaFin = response.FechaFin == default ? response.FechaInicio : response.FechaFin.Date;
            response.Anio = response.Anio <= 0 ? response.FechaInicio.Year : response.Anio;

            if (response.FechaFin < response.FechaInicio)
            {
                return Failure<CalendarioInventarioResponse>("La fecha fin debe ser mayor o igual a la fecha inicio.");
            }

            response.Descripcion = response.Descripcion.Trim();
            response.Observaciones ??= string.Empty;
            response.Folio ??= string.Empty;
            response.Activo = true;

            return null;
        }

        private async Task ArchiveCurrentInventariosAsync(int empresaId, int areaId, int usuarioActual)
        {
            var inventarios = await _context.Inventarios
                .Include(x => x.InventarioDetalles)
                .Where(x => x.Activo && x.FkidEmpresaSis == empresaId && x.FkidAreaSis == areaId)
                .ToListAsync();

            if (inventarios.Count == 0)
            {
                return;
            }

            var now = DateTime.Now;
            var inventarioHist = new List<InventarioHist>();
            var detalleHist = new List<InventarioDetHist>();

            foreach (var inventario in inventarios)
            {
                inventarioHist.Add(new InventarioHist
                {
                    FkidInventarioAlma = inventario.PkidInventario,
                    AccionHist = "NUEVO_PERIODO",
                    Folio = inventario.Folio ?? string.Empty,
                    FkidEmpresaSis = inventario.FkidEmpresaSis,
                    FkidAreaSis = inventario.FkidAreaSis,
                    FkidEstatusInventarioAlma = inventario.FkidEstatusInventarioAlma,
                    FechaInventario = inventario.FechaInventario,
                    Responsable = inventario.Responsable ?? string.Empty,
                    Observaciones = inventario.Observaciones ?? string.Empty,
                    TotalBienes = inventario.TotalBienes,
                    TotalLocalizados = inventario.TotalLocalizados,
                    TotalDiferencias = inventario.TotalDiferencias,
                    Activo = inventario.Activo,
                    FechaCreacion = inventario.FechaCreacion,
                    UsuarioCreacion = inventario.UsuarioCreacion,
                    FechaModificacion = inventario.FechaModificacion,
                    UsuarioModificacion = inventario.UsuarioModificacion,
                    FechaHist = now,
                    UsuarioHist = usuarioActual
                });

                foreach (var detalle in inventario.InventarioDetalles.Where(x => x.Activo))
                {
                    detalleHist.Add(new InventarioDetHist
                    {
                        FkidInventarioDetalleAlma = detalle.PkidInventarioDetalle,
                        FkidInventarioAlma = detalle.FkidInventarioAlma,
                        FkidBienAlma = detalle.FkidBienAlma,
                        AccionHist = "NUEVO_PERIODO",
                        ClaveBien = detalle.ClaveBien ?? string.Empty,
                        DescripcionBien = detalle.DescripcionBien ?? string.Empty,
                        Serie = detalle.Serie ?? string.Empty,
                        UbicacionSistema = detalle.UbicacionSistema ?? string.Empty,
                        UbicacionFisica = detalle.UbicacionFisica ?? string.Empty,
                        Localizado = detalle.Localizado,
                        TieneDiferencia = detalle.TieneDiferencia,
                        Observaciones = detalle.Observaciones ?? string.Empty,
                        Activo = detalle.Activo,
                        FechaHist = now,
                        UsuarioHist = usuarioActual
                    });

                    detalle.Activo = false;
                    detalle.FechaModificacion = now;
                    detalle.UsuarioModificacion = usuarioActual;
                }

                inventario.Activo = false;
                inventario.FechaModificacion = now;
                inventario.UsuarioModificacion = usuarioActual;
            }

            await _context.InventarioHists.AddRangeAsync(inventarioHist);
            await _context.InventarioDetHists.AddRangeAsync(detalleHist);
            await _context.SaveChangesAsync();
        }

        private async Task ApplyInventoryCountsAsync(IList<CalendarioInventarioResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var ids = items.Select(x => x.PkidCalendarioInventario).Distinct().ToList();
            var counts = await _context.Inventarios
                .AsNoTracking()
                .Where(x => x.Activo && x.FkidCalendarioInventarioAlma.HasValue && ids.Contains(x.FkidCalendarioInventarioAlma.Value))
                .GroupBy(x => x.FkidCalendarioInventarioAlma.Value)
                .Select(x => new { Id = x.Key, Count = x.Count() })
                .ToDictionaryAsync(x => x.Id, x => x.Count);

            foreach (var item in items)
            {
                item.InventariosActivos = counts.TryGetValue(item.PkidCalendarioInventario, out var count) ? count : 0;
            }
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(int action, int? id, CalendarioInventarioResponse response, int usuarioActual)
        {
            var idParameter = new SqlParameter("@Id", id.HasValue ? id.Value : DBNull.Value)
            {
                Direction = System.Data.ParameterDirection.InputOutput,
                SqlDbType = System.Data.SqlDbType.Int
            };

            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ALMA].[SP_MantenimientoCalendarioInventario]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdCalendarioInventario", id),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdArea_SIS", response.FkidAreaSis),
                StoredProcedureExecutor.Param("@Anio", response.Anio),
                StoredProcedureExecutor.Param("@Descripcion", response.Descripcion),
                StoredProcedureExecutor.Param("@FechaInicio", response.FechaInicio.Date),
                StoredProcedureExecutor.Param("@FechaFin", response.FechaFin.Date),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual),
                idParameter);
        }

        private static IQueryable<VwCalendarioInventario> ApplySort(IQueryable<VwCalendarioInventario> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "Folio" => ascending ? query.OrderBy(x => x.Folio) : query.OrderByDescending(x => x.Folio),
                "Descripcion" => ascending ? query.OrderBy(x => x.Descripcion) : query.OrderByDescending(x => x.Descripcion),
                "AreaNombre" => ascending ? query.OrderBy(x => x.AreaNombre) : query.OrderByDescending(x => x.AreaNombre),
                "Anio" => ascending ? query.OrderBy(x => x.Anio) : query.OrderByDescending(x => x.Anio),
                "FechaInicio" => ascending ? query.OrderBy(x => x.FechaInicio) : query.OrderByDescending(x => x.FechaInicio),
                "FechaFin" => ascending ? query.OrderBy(x => x.FechaFin) : query.OrderByDescending(x => x.FechaFin),
                _ => ascending ? query.OrderByDescending(x => x.PkidCalendarioInventario) : query.OrderBy(x => x.PkidCalendarioInventario)
            };
        }

        private static PagedResult<CalendarioInventarioResponse> Success(List<CalendarioInventarioResponse> items, string message, int total)
        {
            return new PagedResult<CalendarioInventarioResponse>
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
