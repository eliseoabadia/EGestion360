using EG.Application.Interfaces.Almacen;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Almacen
{
    public class SolicitudSalidaAppService : ISolicitudSalidaAppService
    {
        private readonly GenericService<SolicitudSalidum, SolicitudSalidaDto, SolicitudSalidaResponse> _service;
        private readonly GenericService<VwSolicitudSalidum, SolicitudSalidaDto, SolicitudSalidaResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public SolicitudSalidaAppService(
            GenericService<SolicitudSalidum, SolicitudSalidaDto, SolicitudSalidaResponse> service,
            GenericService<VwSolicitudSalidum, SolicitudSalidaDto, SolicitudSalidaResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<SolicitudSalidaResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            await ApplyAggregateFlagsAsync(items);
            return Success(items, "Solicitudes de salida obtenidas correctamente", items.Count);
        }

        public async Task<PagedResult<SolicitudSalidaResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidSolicitudSalida");
            if (item == null)
            {
                return Failure<SolicitudSalidaResponse>($"Solicitud de salida con ID {id} no encontrada.", "NOT_FOUND");
            }

            await ApplyAggregateFlagsAsync(new List<SolicitudSalidaResponse> { item });

            return new PagedResult<SolicitudSalidaResponse>
            {
                Success = true,
                Message = "Solicitud de salida encontrada",
                Code = "SUCCESS",
                Data = item,
                Items = new List<SolicitudSalidaResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<SolicitudSalidaResponse>> CreateAsync(SolicitudSalidaResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, isCreate: true);
            if (validation != null)
            {
                return validation;
            }

            var entity = new SolicitudSalidum();
            ApplyValues(entity, response);
            entity.Activo = true;
            entity.Autorizado = false;
            entity.FechaAutorizacion = null;
            entity.UsuarioAutorizacion = null;
            entity.FechaCreacion = DateTime.Now;
            entity.UsuarioCreacion = usuarioActual;

            try
            {
                _context.SolicitudSalida.Add(entity);
                await _context.SaveChangesAsync();
                var result = await GetByIdAsync(entity.PkidSolicitudSalida);
                result.Message = "Solicitud de salida registrada correctamente.";
                return result;
            }
            catch (Exception ex)
            {
                return Failure<SolicitudSalidaResponse>($"Error al registrar solicitud de salida: {GetError(ex)}");
            }
        }

        public async Task<PagedResult<SolicitudSalidaResponse>> UpdateAsync(int id, SolicitudSalidaResponse response, int usuarioActual)
        {
            var current = await _context.SolicitudSalida
                .Include(x => x.FkidEstatusSolicitudSalidaAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidSolicitudSalida == id && x.Activo);

            if (current == null)
            {
                return Failure<SolicitudSalidaResponse>($"Solicitud de salida con ID {id} no encontrada.", "NOT_FOUND");
            }

            if (IsLocked(current))
            {
                return Failure<SolicitudSalidaResponse>("La solicitud ya fue autorizada o esta en estatus final y no puede modificarse.", "LOCKED");
            }

            response.PkidSolicitudSalida = id;
            var validation = await NormalizeAndValidateAsync(response, isCreate: false);
            if (validation != null)
            {
                return validation;
            }

            response.Folio = string.IsNullOrWhiteSpace(response.Folio) ? current.Folio ?? string.Empty : response.Folio;
            ApplyValues(current, response);
            current.FechaModificacion = DateTime.Now;
            current.UsuarioModificacion = usuarioActual;

            try
            {
                await _context.SaveChangesAsync();
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = "Solicitud de salida actualizada correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<SolicitudSalidaResponse>($"Error al actualizar solicitud de salida: {GetError(ex)}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await _context.SolicitudSalida
                .Include(x => x.FkidEstatusSolicitudSalidaAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidSolicitudSalida == id && x.Activo);

            if (current == null)
            {
                return BoolFailure($"Solicitud de salida con ID {id} no encontrada.", "NOT_FOUND");
            }

            if (IsLocked(current))
            {
                return BoolFailure("La solicitud ya fue autorizada o esta en estatus final y no puede eliminarse.", "LOCKED");
            }

            var tieneDetalles = await _context.DetalleSolicitudSalida
                .AnyAsync(x => x.FkidSolicitudSalidaAlma == id && x.Activo);
            if (tieneDetalles)
            {
                return BoolFailure("Elimina primero los bienes solicitados antes de borrar la solicitud.", "HAS_CHILDREN");
            }

            current.Activo = false;
            current.FechaModificacion = DateTime.Now;
            current.UsuarioModificacion = _userContext.GetCurrentUserId();
            await _context.SaveChangesAsync();

            return new PagedResult<bool>
            {
                Success = true,
                Message = "Solicitud de salida eliminada correctamente.",
                Code = "SUCCESS",
                Data = true,
                Items = new List<bool> { true },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<SolicitudSalidaResponse>> AutorizarAsync(int id, int usuarioActual)
        {
            var current = await _context.SolicitudSalida
                .Include(x => x.FkidEstatusSolicitudSalidaAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidSolicitudSalida == id && x.Activo);

            if (current == null)
            {
                return Failure<SolicitudSalidaResponse>($"Solicitud de salida con ID {id} no encontrada.", "NOT_FOUND");
            }

            if (IsLocked(current))
            {
                return Failure<SolicitudSalidaResponse>("La solicitud ya fue autorizada o esta en estatus final.", "LOCKED");
            }

            var tieneDetalles = await _context.DetalleSolicitudSalida
                .AnyAsync(x => x.FkidSolicitudSalidaAlma == id && x.Activo);
            if (!tieneDetalles)
            {
                return Failure<SolicitudSalidaResponse>("Agrega al menos un bien antes de autorizar la solicitud.");
            }

            var estatusAutorizadoId = await GetAuthorizedStatusIdAsync();

            current.Autorizado = true;
            current.FechaAutorizacion = DateTime.Now;
            current.UsuarioAutorizacion = usuarioActual;
            if (estatusAutorizadoId.HasValue)
            {
                current.FkidEstatusSolicitudSalidaAlma = estatusAutorizadoId.Value;
            }

            current.FechaModificacion = DateTime.Now;
            current.UsuarioModificacion = usuarioActual;
            await _context.SaveChangesAsync();

            var result = await GetByIdAsync(id);
            result.Message = "Solicitud de salida autorizada correctamente.";
            return result;
        }

        public async Task<PagedResult<SolicitudSalidaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (AlmacenPagedFilter.TryGetInt(request, "FkidEmpresaSis", out var empresaId))
                {
                    query = query.Where(x => x.FkidEmpresaSis == empresaId);
                }

                if (AlmacenPagedFilter.TryGetInt(request, "FkidAreaSolicitaSis", out var areaSolicitaId))
                {
                    query = query.Where(x => x.FkidAreaSolicitaSis == areaSolicitaId);
                }

                if (AlmacenPagedFilter.TryGetInt(request, "FkidAreaEntregaSis", out var areaEntregaId))
                {
                    query = query.Where(x => x.FkidAreaEntregaSis == areaEntregaId);
                }

                if (AlmacenPagedFilter.TryGetInt(request, "FkidEstatusSolicitudSalidaAlma", out var estatusId))
                {
                    query = query.Where(x => x.FkidEstatusSolicitudSalidaAlma == estatusId);
                }

                if (AlmacenPagedFilter.TryGetBool(request, "Autorizado", out var autorizado))
                {
                    query = query.Where(x => x.Autorizado == autorizado);
                }

                if (TryGetYearFilter(request, out var anio))
                {
                    var start = new DateOnly(anio, 1, 1);
                    var end = start.AddYears(1);
                    query = query.Where(x => x.FechaSolicitud >= start && x.FechaSolicitud < end);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Folio != null && x.Folio.Contains(filtro)) ||
                        (x.Solicitante != null && x.Solicitante.Contains(filtro)) ||
                        (x.Justificacion != null && x.Justificacion.Contains(filtro)) ||
                        (x.AreaSolicitaNombre != null && x.AreaSolicitaNombre.Contains(filtro)) ||
                        (x.AreaEntregaNombre != null && x.AreaEntregaNombre.Contains(filtro)) ||
                        (x.EstatusDescripcion != null && x.EstatusDescripcion.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);
                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();
                var responses = items.Adapt<List<SolicitudSalidaResponse>>();
                await ApplyAggregateFlagsAsync(responses);

                return Success(responses, "Solicitudes de salida obtenidas correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<SolicitudSalidaResponse>($"Error al obtener solicitudes de salida: {GetError(ex)}");
            }
        }

        private async Task<PagedResult<SolicitudSalidaResponse>?> NormalizeAndValidateAsync(SolicitudSalidaResponse response, bool isCreate)
        {
            _service.ApplyCurrentEmpresaIfPresent(response);

            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<SolicitudSalidaResponse>("Debe existir una empresa seleccionada.");
            }

            if (!response.FkidAreaSolicitaSis.HasValue || response.FkidAreaSolicitaSis.Value <= 0)
            {
                return Failure<SolicitudSalidaResponse>("Debe seleccionar el area solicitante.");
            }

            if (!response.FkidAreaEntregaSis.HasValue || response.FkidAreaEntregaSis.Value <= 0)
            {
                return Failure<SolicitudSalidaResponse>("Debe seleccionar el area que entrega.");
            }

            if (string.IsNullOrWhiteSpace(response.Solicitante))
            {
                return Failure<SolicitudSalidaResponse>("Debe capturar el solicitante.");
            }

            if (string.IsNullOrWhiteSpace(response.Justificacion))
            {
                return Failure<SolicitudSalidaResponse>("Debe capturar la justificacion.");
            }

            response.FechaSolicitud = response.FechaSolicitud == default ? DateTime.Today : response.FechaSolicitud;
            response.Folio = string.IsNullOrWhiteSpace(response.Folio)
                ? await BuildFolioAsync(response)
                : response.Folio.Trim();
            response.FkidEstatusSolicitudSalidaAlma = response.FkidEstatusSolicitudSalidaAlma <= 0
                ? await GetInitialStatusIdAsync()
                : response.FkidEstatusSolicitudSalidaAlma;
            response.Observaciones ??= string.Empty;
            response.Activo = true;

            return null;
        }

        private async Task<int> GetInitialStatusIdAsync()
        {
            var status = await _context.EstatusSolicitudSalida
                .Where(x => x.Activo)
                .OrderBy(x => x.Orden)
                .FirstOrDefaultAsync();
            return status?.PkidEstatusSolicitudSalida ?? 1;
        }

        private async Task<string> BuildFolioAsync(SolicitudSalidaResponse response)
        {
            var year = response.FechaSolicitud == default ? DateTime.Today.Year : response.FechaSolicitud.Year;
            var start = new DateOnly(year, 1, 1);
            var end = start.AddYears(1);
            var next = await _context.SolicitudSalida.CountAsync(x =>
                x.FkidEmpresaSis == response.FkidEmpresaSis &&
                x.FechaSolicitud >= start &&
                x.FechaSolicitud < end) + 1;
            return $"SAL-{year}-{next:00000}";
        }

        private async Task<int?> GetAuthorizedStatusIdAsync()
        {
            var status = await _context.EstatusSolicitudSalida
                .Where(x => x.Activo && !x.EsFinal && x.Descripcion.ToUpper().Contains("AUTORIZ"))
                .OrderBy(x => x.Orden)
                .FirstOrDefaultAsync();

            return status?.PkidEstatusSolicitudSalida;
        }

        private static void ApplyValues(SolicitudSalidum entity, SolicitudSalidaResponse response)
        {
            entity.FkidEmpresaSis = response.FkidEmpresaSis;
            entity.FkidAreaSolicitaSis = response.FkidAreaSolicitaSis;
            entity.FkidAreaEntregaSis = response.FkidAreaEntregaSis;
            entity.FkidEstatusSolicitudSalidaAlma = response.FkidEstatusSolicitudSalidaAlma;
            entity.Folio = response.Folio ?? string.Empty;
            entity.FechaSolicitud = DateOnly.FromDateTime(response.FechaSolicitud == default ? DateTime.Today : response.FechaSolicitud);
            entity.FechaRequerida = response.FechaRequerida.HasValue ? DateOnly.FromDateTime(response.FechaRequerida.Value) : null;
            entity.Solicitante = response.Solicitante ?? string.Empty;
            entity.Justificacion = response.Justificacion ?? string.Empty;
            entity.Observaciones = response.Observaciones ?? string.Empty;
        }

        private async Task ApplyAggregateFlagsAsync(IList<SolicitudSalidaResponse> items)
        {
            if (items.Count == 0)
            {
                return;
            }

            var ids = items.Select(x => x.PkidSolicitudSalida).ToList();
            var statusIds = items.Select(x => x.FkidEstatusSolicitudSalidaAlma).Distinct().ToList();
            var finalStatus = await _context.EstatusSolicitudSalida
                .Where(x => statusIds.Contains(x.PkidEstatusSolicitudSalida))
                .Select(x => new { x.PkidEstatusSolicitudSalida, x.EsFinal })
                .ToListAsync();
            var totals = await _context.DetalleSolicitudSalida
                .Where(x => ids.Contains(x.FkidSolicitudSalidaAlma) && x.Activo)
                .GroupBy(x => x.FkidSolicitudSalidaAlma)
                .Select(g => new
                {
                    SolicitudId = g.Key,
                    Count = g.Count(),
                    Solicitado = g.Sum(x => x.CantidadSolicitada),
                    Autorizado = g.Sum(x => x.CantidadAutorizada ?? 0m),
                    Entregado = g.Sum(x => x.CantidadEntregada ?? 0m),
                    Pendiente = g.Sum(x => x.CantidadPendiente)
                })
                .ToListAsync();

            foreach (var item in items)
            {
                item.EsFinal = finalStatus.FirstOrDefault(x => x.PkidEstatusSolicitudSalida == item.FkidEstatusSolicitudSalidaAlma)?.EsFinal ?? false;
                var total = totals.FirstOrDefault(x => x.SolicitudId == item.PkidSolicitudSalida);
                if (total != null)
                {
                    item.TotalDetalles = total.Count;
                    item.TotalSolicitado = total.Solicitado;
                    item.TotalAutorizado = total.Autorizado;
                    item.TotalEntregado = total.Entregado;
                    item.TotalPendiente = total.Pendiente;
                }
            }
        }

        private static bool IsLocked(SolicitudSalidum entity) =>
            entity.Autorizado || entity.FkidEstatusSolicitudSalidaAlmaNavigation?.EsFinal == true;

        private static bool TryGetYearFilter(PagedRequest request, out int anio)
        {
            if (!AlmacenPagedFilter.TryGetInt(request, "Anio", out anio) &&
                !AlmacenPagedFilter.TryGetInt(request, "Year", out anio) &&
                !AlmacenPagedFilter.TryGetInt(request, "IdAnio", out anio) &&
                !AlmacenPagedFilter.TryGetInt(request, "idAnio", out anio))
            {
                return false;
            }

            return anio >= 2000 && anio <= 2100;
        }

        private static IQueryable<VwSolicitudSalidum> ApplySort(IQueryable<VwSolicitudSalidum> query, string? sortLabel, string? sortDirection)
        {
            var desc = sortDirection?.Contains("Desc", StringComparison.OrdinalIgnoreCase) == true;
            return sortLabel switch
            {
                "Folio" => desc ? query.OrderByDescending(x => x.Folio) : query.OrderBy(x => x.Folio),
                "FechaSolicitud" => desc ? query.OrderByDescending(x => x.FechaSolicitud) : query.OrderBy(x => x.FechaSolicitud),
                "Solicitante" => desc ? query.OrderByDescending(x => x.Solicitante) : query.OrderBy(x => x.Solicitante),
                "EstatusDescripcion" => desc ? query.OrderByDescending(x => x.EstatusDescripcion) : query.OrderBy(x => x.EstatusDescripcion),
                _ => query.OrderByDescending(x => x.FechaSolicitud).ThenByDescending(x => x.PkidSolicitudSalida)
            };
        }

        private static PagedResult<T> Success<T>(IList<T> items, string message, int total)
        {
            return new PagedResult<T>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Items = items,
                TotalCount = total
            };
        }

        private static PagedResult<T> Failure<T>(string message, string code = "ERROR")
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

        private static string GetError(Exception ex) => ex.InnerException?.Message ?? ex.Message;
    }
}
