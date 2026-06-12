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
    public class DetalleSolicitudSalidaAppService : IDetalleSolicitudSalidaAppService
    {
        private readonly GenericService<DetalleSolicitudSalidum, DetalleSolicitudSalidaDto, DetalleSolicitudSalidaResponse> _service;
        private readonly GenericService<VwDetalleSolicitudSalidum, DetalleSolicitudSalidaDto, DetalleSolicitudSalidaResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public DetalleSolicitudSalidaAppService(
            GenericService<DetalleSolicitudSalidum, DetalleSolicitudSalidaDto, DetalleSolicitudSalidaResponse> service,
            GenericService<VwDetalleSolicitudSalidum, DetalleSolicitudSalidaDto, DetalleSolicitudSalidaResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<DetalleSolicitudSalidaResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            return Success(items, "Detalle de solicitud de salida obtenido correctamente", items.Count);
        }

        public async Task<PagedResult<DetalleSolicitudSalidaResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidDetalleSolicitudSalida");
            if (item == null)
            {
                return Failure<DetalleSolicitudSalidaResponse>($"Detalle de solicitud con ID {id} no encontrado.", "NOT_FOUND");
            }

            return new PagedResult<DetalleSolicitudSalidaResponse>
            {
                Success = true,
                Message = "Detalle de solicitud encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<DetalleSolicitudSalidaResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<DetalleSolicitudSalidaResponse>> CreateAsync(DetalleSolicitudSalidaResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, currentId: null);
            if (validation != null)
            {
                return validation;
            }

            var entity = new DetalleSolicitudSalidum();
            ApplyValues(entity, response);
            entity.Activo = true;
            entity.FechaCreacion = DateTime.Now;
            entity.UsuarioCreacion = usuarioActual;

            try
            {
                _context.DetalleSolicitudSalida.Add(entity);
                await _context.SaveChangesAsync();
                var result = await GetByIdAsync(entity.PkidDetalleSolicitudSalida);
                result.Message = "Bien agregado a la solicitud correctamente.";
                return result;
            }
            catch (Exception ex)
            {
                return Failure<DetalleSolicitudSalidaResponse>($"Error al agregar bien a la solicitud: {GetError(ex)}");
            }
        }

        public async Task<PagedResult<DetalleSolicitudSalidaResponse>> UpdateAsync(int id, DetalleSolicitudSalidaResponse response, int usuarioActual)
        {
            var current = await _context.DetalleSolicitudSalida
                .Include(x => x.FkidSolicitudSalidaAlmaNavigation)
                .ThenInclude(x => x.FkidEstatusSolicitudSalidaAlmaNavigation)
                .Include(x => x.FkidAlmacenAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidDetalleSolicitudSalida == id && x.Activo);

            if (current == null)
            {
                return Failure<DetalleSolicitudSalidaResponse>($"Detalle de solicitud con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (IsParentLocked(current.FkidSolicitudSalidaAlmaNavigation))
            {
                return Failure<DetalleSolicitudSalidaResponse>("La solicitud ya fue autorizada o esta en estatus final y no puede modificarse.", "LOCKED");
            }

            response.PkidDetalleSolicitudSalida = id;
            response.FkidSolicitudSalidaAlma = current.FkidSolicitudSalidaAlma;
            var validation = await NormalizeAndValidateAsync(response, currentId: id);
            if (validation != null)
            {
                return validation;
            }

            ApplyValues(current, response);
            current.FechaModificacion = DateTime.Now;
            current.UsuarioModificacion = usuarioActual;

            try
            {
                await _context.SaveChangesAsync();
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = "Detalle de solicitud actualizado correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<DetalleSolicitudSalidaResponse>($"Error al actualizar detalle de solicitud: {GetError(ex)}");
            }
        }

        public async Task<PagedResult<DetalleSolicitudSalidaResponse>> ActualizarEntregaAsync(
            int id,
            DetalleSolicitudSalidaResponse response,
            int usuarioActual)
        {
            var current = await _context.DetalleSolicitudSalida
                .Include(x => x.FkidSolicitudSalidaAlmaNavigation)
                .ThenInclude(x => x.FkidEstatusSolicitudSalidaAlmaNavigation)
                .Include(x => x.FkidAlmacenAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidDetalleSolicitudSalida == id && x.Activo);

            if (current == null)
            {
                return Failure<DetalleSolicitudSalidaResponse>($"Detalle de solicitud con ID {id} no encontrado.", "NOT_FOUND");
            }

            var solicitud = current.FkidSolicitudSalidaAlmaNavigation;
            if (!solicitud.Autorizado)
            {
                return Failure<DetalleSolicitudSalidaResponse>("La solicitud debe estar autorizada antes de registrar entregas.", "NOT_AUTHORIZED");
            }

            if (solicitud.FkidEstatusSolicitudSalidaAlmaNavigation?.EsFinal == true)
            {
                return Failure<DetalleSolicitudSalidaResponse>("La solicitud ya esta en estatus final y no puede recibir mas entregas.", "LOCKED");
            }

            var cantidadEntregada = response.CantidadEntregada ?? current.CantidadEntregada ?? 0m;
            var cantidadAutorizada = current.CantidadAutorizada ?? current.CantidadSolicitada;
            if (cantidadEntregada < 0)
            {
                return Failure<DetalleSolicitudSalidaResponse>("La cantidad entregada no puede ser negativa.");
            }

            if (cantidadEntregada > cantidadAutorizada)
            {
                return Failure<DetalleSolicitudSalidaResponse>("La cantidad entregada no puede exceder la cantidad autorizada.");
            }

            var almacen = current.FkidAlmacenAlmaNavigation;
            if (almacen == null)
            {
                return Failure<DetalleSolicitudSalidaResponse>("El detalle no tiene una existencia de almacen asociada para surtir.", "NO_STOCK_SOURCE");
            }

            if (!almacen.Activo || !almacen.AplicaAlmacen)
            {
                return Failure<DetalleSolicitudSalidaResponse>("La existencia asociada no esta disponible para suministro.", "STOCK_NOT_AVAILABLE");
            }

            if (almacen.InventarioCerrado || almacen.EsContabilizado)
            {
                return Failure<DetalleSolicitudSalidaResponse>("La existencia asociada esta cerrada o contabilizada y no puede surtirse.", "STOCK_LOCKED");
            }

            var cantidadAnterior = current.CantidadEntregada ?? 0m;
            var diferenciaSalida = cantidadEntregada - cantidadAnterior;
            if (diferenciaSalida > 0 && almacen.Cantidad < diferenciaSalida)
            {
                return Failure<DetalleSolicitudSalidaResponse>($"La cantidad por surtir rebasa la existencia disponible ({almacen.Cantidad:0.####}).");
            }

            try
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();

                if (diferenciaSalida != 0)
                {
                    almacen.Cantidad -= diferenciaSalida;
                    almacen.FechaModificacion = DateTime.Now;
                    almacen.UsuarioModificacion = usuarioActual;
                }

                current.CantidadEntregada = cantidadEntregada;
                current.CantidadPendiente = Math.Max(0m, cantidadAutorizada - cantidadEntregada);
                current.Observaciones = response.Observaciones ?? current.Observaciones ?? string.Empty;
                current.FechaModificacion = DateTime.Now;
                current.UsuarioModificacion = usuarioActual;

                await _context.SaveChangesAsync();
                await UpdateSolicitudStatusAfterDeliveryAsync(solicitud.PkidSolicitudSalida, usuarioActual);
                await transaction.CommitAsync();

                var refreshed = await GetByIdAsync(id);
                refreshed.Message = "Entrega actualizada correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<DetalleSolicitudSalidaResponse>($"Error al actualizar entrega: {GetError(ex)}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await _context.DetalleSolicitudSalida
                .Include(x => x.FkidSolicitudSalidaAlmaNavigation)
                .ThenInclude(x => x.FkidEstatusSolicitudSalidaAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidDetalleSolicitudSalida == id && x.Activo);

            if (current == null)
            {
                return BoolFailure($"Detalle de solicitud con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (IsParentLocked(current.FkidSolicitudSalidaAlmaNavigation))
            {
                return BoolFailure("La solicitud ya fue autorizada o esta en estatus final y no puede eliminar bienes.", "LOCKED");
            }

            current.Activo = false;
            current.FechaModificacion = DateTime.Now;
            current.UsuarioModificacion = _userContext.GetCurrentUserId();
            await _context.SaveChangesAsync();

            return new PagedResult<bool>
            {
                Success = true,
                Message = "Bien eliminado de la solicitud correctamente.",
                Code = "SUCCESS",
                Data = true,
                Items = new List<bool> { true },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<DetalleSolicitudSalidaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (AlmacenPagedFilter.TryGetInt(request, "FkidSolicitudSalidaAlma", out var solicitudId))
                {
                    query = query.Where(x => x.FkidSolicitudSalidaAlma == solicitudId);
                }

                if (AlmacenPagedFilter.TryGetInt(request, "FkidAlmacenAlma", out var almacenId))
                {
                    query = query.Where(x => x.FkidAlmacenAlma == almacenId);
                }

                if (AlmacenPagedFilter.TryGetInt(request, "FkidTipoBienAlma", out var tipoBienId))
                {
                    query = query.Where(x => x.FkidTipoBienAlma == tipoBienId);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.SolicitudFolio != null && x.SolicitudFolio.Contains(filtro)) ||
                        (x.AlmacenClave != null && x.AlmacenClave.Contains(filtro)) ||
                        (x.TipoBienClave != null && x.TipoBienClave.Contains(filtro)) ||
                        (x.TipoBienDescripcion != null && x.TipoBienDescripcion.Contains(filtro)) ||
                        (x.UnidadDescripcion != null && x.UnidadDescripcion.Contains(filtro)) ||
                        (x.Observaciones != null && x.Observaciones.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);
                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

                return Success(items.Adapt<List<DetalleSolicitudSalidaResponse>>(), "Detalle de solicitud obtenido correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<DetalleSolicitudSalidaResponse>($"Error al obtener detalle de solicitud: {GetError(ex)}");
            }
        }

        private async Task<PagedResult<DetalleSolicitudSalidaResponse>?> NormalizeAndValidateAsync(
            DetalleSolicitudSalidaResponse response,
            int? currentId)
        {
            if (response.FkidSolicitudSalidaAlma <= 0)
            {
                return Failure<DetalleSolicitudSalidaResponse>("Debe seleccionar una solicitud de salida.");
            }

            var solicitud = await _context.SolicitudSalida
                .AsNoTracking()
                .Include(x => x.FkidEstatusSolicitudSalidaAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidSolicitudSalida == response.FkidSolicitudSalidaAlma && x.Activo);

            if (solicitud == null)
            {
                return Failure<DetalleSolicitudSalidaResponse>("La solicitud seleccionada no existe o esta inactiva.");
            }

            if (IsParentLocked(solicitud))
            {
                return Failure<DetalleSolicitudSalidaResponse>("La solicitud ya fue autorizada o esta en estatus final.", "LOCKED");
            }

            if (response.CantidadSolicitada < 1)
            {
                return Failure<DetalleSolicitudSalidaResponse>("La cantidad solicitada debe ser mayor o igual a 1.");
            }

            if (response.FkidAlmacenAlma.HasValue && response.FkidAlmacenAlma.Value > 0)
            {
                var almacen = await _context.Almacens
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidAlmacen == response.FkidAlmacenAlma.Value && x.Activo && x.FkidEmpresaSis == solicitud.FkidEmpresaSis);

                if (almacen == null)
                {
                    return Failure<DetalleSolicitudSalidaResponse>("La existencia seleccionada no existe o no pertenece a la empresa activa.");
                }

                response.FkidTipoBienAlma = almacen.FkidTipoBienAlma;
                response.FkidUnidadesAlma ??= almacen.FkidUnidadesAlma;

                var cantidadComprometida = await _context.DetalleSolicitudSalida
                    .Where(x =>
                        x.Activo &&
                        x.FkidAlmacenAlma == response.FkidAlmacenAlma.Value &&
                        x.PkidDetalleSolicitudSalida != (currentId ?? 0) &&
                        !x.FkidSolicitudSalidaAlmaNavigation.Autorizado)
                    .SumAsync(x => x.CantidadAutorizada ?? x.CantidadSolicitada);

                var disponible = almacen.Cantidad - cantidadComprometida;
                if (response.CantidadSolicitada > disponible)
                {
                    return Failure<DetalleSolicitudSalidaResponse>($"La cantidad solicitada rebasa la existencia disponible ({disponible:0.####}).");
                }
            }

            if (response.FkidTipoBienAlma <= 0)
            {
                return Failure<DetalleSolicitudSalidaResponse>("Debe seleccionar el bien o servicio.");
            }

            if (!response.FkidAlmacenAlma.HasValue || response.FkidAlmacenAlma.Value <= 0)
            {
                var disponibleTipoBien = await GetAvailableByTipoBienAsync(solicitud, response, currentId);
                if (response.CantidadSolicitada > disponibleTipoBien)
                {
                    return Failure<DetalleSolicitudSalidaResponse>($"La cantidad solicitada rebasa la existencia disponible del bien ({disponibleTipoBien:0.####}).");
                }
            }

            var duplicate = await _context.DetalleSolicitudSalida.AnyAsync(x =>
                x.Activo &&
                x.PkidDetalleSolicitudSalida != (currentId ?? 0) &&
                x.FkidSolicitudSalidaAlma == response.FkidSolicitudSalidaAlma &&
                x.FkidTipoBienAlma == response.FkidTipoBienAlma &&
                x.FkidUnidadesAlma == response.FkidUnidadesAlma);
            if (duplicate)
            {
                return Failure<DetalleSolicitudSalidaResponse>("Este bien ya existe en la solicitud con la misma unidad.");
            }

            response.CantidadAutorizada ??= response.CantidadSolicitada;
            response.CantidadEntregada ??= 0m;
            if (response.CantidadAutorizada.Value < 0 || response.CantidadEntregada.Value < 0)
            {
                return Failure<DetalleSolicitudSalidaResponse>("Las cantidades autorizadas o entregadas no pueden ser negativas.");
            }

            if (response.CantidadEntregada.Value > response.CantidadAutorizada.Value)
            {
                return Failure<DetalleSolicitudSalidaResponse>("La cantidad entregada no puede exceder la cantidad autorizada.");
            }

            response.CantidadPendiente = Math.Max(0m, response.CantidadAutorizada.Value - response.CantidadEntregada.Value);
            response.Observaciones ??= string.Empty;
            response.Activo = true;

            return null;
        }

        private static void ApplyValues(DetalleSolicitudSalidum entity, DetalleSolicitudSalidaResponse response)
        {
            entity.FkidSolicitudSalidaAlma = response.FkidSolicitudSalidaAlma;
            entity.FkidAlmacenAlma = response.FkidAlmacenAlma;
            entity.FkidTipoBienAlma = response.FkidTipoBienAlma;
            entity.FkidUnidadesAlma = response.FkidUnidadesAlma;
            entity.CantidadSolicitada = response.CantidadSolicitada;
            entity.CantidadAutorizada = response.CantidadAutorizada;
            entity.CantidadEntregada = response.CantidadEntregada;
            entity.CantidadPendiente = response.CantidadPendiente;
            entity.Observaciones = response.Observaciones ?? string.Empty;
        }

        private async Task<decimal> GetAvailableByTipoBienAsync(
            SolicitudSalidum solicitud,
            DetalleSolicitudSalidaResponse response,
            int? currentId)
        {
            var existencia = await _context.Almacens
                .AsNoTracking()
                .Where(x =>
                    x.Activo &&
                    x.AplicaAlmacen &&
                    !x.InventarioCerrado &&
                    !x.EsContabilizado &&
                    x.FkidEmpresaSis == solicitud.FkidEmpresaSis &&
                    x.FkidTipoBienAlma == response.FkidTipoBienAlma)
                .SumAsync(x => x.Cantidad);

            var comprometida = await _context.DetalleSolicitudSalida
                .AsNoTracking()
                .Where(x =>
                    x.Activo &&
                    x.PkidDetalleSolicitudSalida != (currentId ?? 0) &&
                    x.FkidTipoBienAlma == response.FkidTipoBienAlma &&
                    x.FkidSolicitudSalidaAlmaNavigation.FkidEmpresaSis == solicitud.FkidEmpresaSis &&
                    !x.FkidSolicitudSalidaAlmaNavigation.Autorizado)
                .SumAsync(x => x.CantidadAutorizada ?? x.CantidadSolicitada);

            return Math.Max(0m, existencia - comprometida);
        }

        private async Task UpdateSolicitudStatusAfterDeliveryAsync(int solicitudId, int usuarioActual)
        {
            var solicitud = await _context.SolicitudSalida
                .Include(x => x.FkidEstatusSolicitudSalidaAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidSolicitudSalida == solicitudId && x.Activo);

            if (solicitud == null || !solicitud.Autorizado || solicitud.FkidEstatusSolicitudSalidaAlmaNavigation?.EsFinal == true)
            {
                return;
            }

            var tienePendientes = await _context.DetalleSolicitudSalida
                .AsNoTracking()
                .Where(x => x.Activo && x.FkidSolicitudSalidaAlma == solicitudId)
                .AnyAsync(x => x.CantidadPendiente > 0);

            var statusId = tienePendientes
                ? await GetAuthorizedStatusIdAsync()
                : await GetDeliveredStatusIdAsync();
            if (!statusId.HasValue || solicitud.FkidEstatusSolicitudSalidaAlma == statusId.Value)
            {
                return;
            }

            solicitud.FkidEstatusSolicitudSalidaAlma = statusId.Value;
            solicitud.FechaModificacion = DateTime.Now;
            solicitud.UsuarioModificacion = usuarioActual;
            await _context.SaveChangesAsync();
        }

        private async Task<int?> GetAuthorizedStatusIdAsync()
        {
            var status = await _context.EstatusSolicitudSalida
                .Where(x => x.Activo && !x.EsFinal && x.Descripcion.ToUpper().Contains("AUTORIZ"))
                .OrderBy(x => x.Orden)
                .FirstOrDefaultAsync();

            return status?.PkidEstatusSolicitudSalida;
        }

        private async Task<int?> GetDeliveredStatusIdAsync()
        {
            var status = await _context.EstatusSolicitudSalida
                .Where(x => x.Activo && x.EsFinal && x.Descripcion.ToUpper().Contains("SURT"))
                .OrderBy(x => x.Orden)
                .FirstOrDefaultAsync();

            if (status != null)
            {
                return status.PkidEstatusSolicitudSalida;
            }

            status = await _context.EstatusSolicitudSalida
                .Where(x => x.Activo && x.EsFinal)
                .OrderBy(x => x.Orden)
                .FirstOrDefaultAsync();

            return status?.PkidEstatusSolicitudSalida;
        }

        private static bool IsParentLocked(SolicitudSalidum solicitud) =>
            solicitud.Autorizado || solicitud.FkidEstatusSolicitudSalidaAlmaNavigation?.EsFinal == true;

        private static IQueryable<VwDetalleSolicitudSalidum> ApplySort(
            IQueryable<VwDetalleSolicitudSalidum> query,
            string? sortLabel,
            string? sortDirection)
        {
            var desc = sortDirection?.Contains("Desc", StringComparison.OrdinalIgnoreCase) == true;
            return sortLabel switch
            {
                "TipoBienDescripcion" => desc ? query.OrderByDescending(x => x.TipoBienDescripcion) : query.OrderBy(x => x.TipoBienDescripcion),
                "CantidadSolicitada" => desc ? query.OrderByDescending(x => x.CantidadSolicitada) : query.OrderBy(x => x.CantidadSolicitada),
                "CantidadPendiente" => desc ? query.OrderByDescending(x => x.CantidadPendiente) : query.OrderBy(x => x.CantidadPendiente),
                _ => query.OrderBy(x => x.TipoBienDescripcion).ThenBy(x => x.PkidDetalleSolicitudSalida)
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
