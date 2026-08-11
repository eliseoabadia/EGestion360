using EG.Application.Interfaces.Almacen;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;
using System.Data;

namespace EG.Application.Services.Almacen
{
    public class AlmacenAppService : IAlmacenAppService
    {
        private readonly GenericService<EG.Infraestructure.Models.Almacen, AlmacenDto, AlmacenResponse> _service;
        private readonly GenericService<VwAlmacen, AlmacenDto, AlmacenResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public AlmacenAppService(
            GenericService<EG.Infraestructure.Models.Almacen, AlmacenDto, AlmacenResponse> service,
            GenericService<VwAlmacen, AlmacenDto, AlmacenResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<AlmacenResponse>> GetAllAsync()
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var items = (await _serviceView.GetAllAsync()).Where(x => x.FkidEmpresaSis == empresaId).ToList();
            return Success(items, "Movimientos de almacen obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<AlmacenResponse>> GetByIdAsync(int id)
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var item = await _serviceView.GetQueryWithIncludes()
                .FirstOrDefaultAsync(x => x.PkidAlmacen == id && x.FkidEmpresaSis == empresaId);
            if (item == null)
            {
                return Failure<AlmacenResponse>($"Movimiento de almacen con ID {id} no encontrado.", "NOT_FOUND");
            }

            var response = item.Adapt<AlmacenResponse>();
            var entity = await _context.Almacens.AsNoTracking().FirstOrDefaultAsync(x => x.PkidAlmacen == id && x.FkidEmpresaSis == empresaId);
            if (entity != null)
            {
                response.FkidDetalleOrdenCompraOrco = entity.FkidDetalleOrdenCompraOrco;
            }

            return new PagedResult<AlmacenResponse>
            {
                Success = true,
                Message = "Movimiento de almacen encontrado",
                Code = "SUCCESS",
                Data = response,
                Items = new List<AlmacenResponse> { response },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<AlmacenResponse>> CreateAsync(AlmacenResponse response, int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, isCreate: true);
            if (validation != null)
            {
                return validation;
            }

            var entity = new EG.Infraestructure.Models.Almacen();
            ApplyValues(entity, response);
            entity.Activo = true;
            entity.FechaCreacion = DateTime.Now;
            entity.UsuarioCreacion = usuarioActual;
            entity.InventarioCerrado = false;
            entity.EsContabilizado = false;

            try
            {
                var strategy = _context.Database.CreateExecutionStrategy();
                return await strategy.ExecuteAsync(async () =>
                {
                    await using var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable);
                await AdjustOrderReceiptAsync(response.FkidDetalleOrdenCompraOrco, response.Cantidad, usuarioActual);
                _context.Almacens.Add(entity);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                await NotifyPendingReceiptAsync(response.FkidDetalleOrdenCompraOrco, usuarioActual);
                var result = await GetByIdAsync(entity.PkidAlmacen);
                result.Message = "Movimiento de almacen registrado correctamente.";
                return result;
                });
            }
            catch (Exception ex)
            {
                return Failure<AlmacenResponse>($"Error al registrar movimiento de almacen: {GetError(ex)}");
            }
        }

        public async Task<PagedResult<AlmacenResponse>> UpdateAsync(int id, AlmacenResponse response, int usuarioActual)
        {
            var current = await _context.Almacens.FirstOrDefaultAsync(x => x.PkidAlmacen == id && x.Activo && x.FkidEmpresaSis == _userContext.GetCurrentEmpresaId());
            if (current == null)
            {
                return Failure<AlmacenResponse>($"Movimiento de almacen con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (!current.AplicaAlmacen && current.Cantidad < 0)
            {
                return Failure<AlmacenResponse>("Las salidas por ajuste son historicas; registra un ajuste contrario para corregirlas.", "LOCKED");
            }

            if (IsLocked(current))
            {
                return Failure<AlmacenResponse>("El movimiento ya esta cerrado o contabilizado y no puede modificarse.", "LOCKED");
            }

            response.PkidAlmacen = id;
            if (response.FkidDetalleOrdenCompraOrco != current.FkidDetalleOrdenCompraOrco)
                return Failure<AlmacenResponse>("No se puede cambiar la orden origen de una entrada; elimina la entrada y registrala nuevamente.", "LOCKED");
            var validation = await NormalizeAndValidateAsync(response, isCreate: false);
            if (validation != null)
            {
                return validation;
            }

            var cantidadAnterior = current.Cantidad;
            ApplyValues(current, response);
            current.UsuarioModificacion = usuarioActual;
            current.FechaModificacion = DateTime.Now;

            try
            {
                await using var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable);
                var delta = response.Cantidad - cantidadAnterior;
                await AdjustOrderReceiptAsync(response.FkidDetalleOrdenCompraOrco, delta, usuarioActual);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
                var refreshed = await GetByIdAsync(id);
                refreshed.Message = "Movimiento de almacen actualizado correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<AlmacenResponse>($"Error al actualizar movimiento de almacen: {GetError(ex)}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var current = await _context.Almacens.FirstOrDefaultAsync(x => x.PkidAlmacen == id && x.Activo && x.FkidEmpresaSis == _userContext.GetCurrentEmpresaId());
            if (current == null)
            {
                return BoolFailure($"Movimiento de almacen con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (!current.AplicaAlmacen && current.Cantidad < 0)
            {
                return BoolFailure("Las salidas por ajuste son historicas; registra un ajuste contrario para corregirlas.", "LOCKED");
            }

            if (IsLocked(current))
            {
                return BoolFailure("El movimiento ya esta cerrado o contabilizado y no puede eliminarse.", "LOCKED");
            }

            await using (var transaction = await _context.Database.BeginTransactionAsync(IsolationLevel.Serializable))
            {
                await AdjustOrderReceiptAsync(current.FkidDetalleOrdenCompraOrco, -current.Cantidad, _userContext.GetCurrentUserId());
                current.Activo = false;
                current.UsuarioModificacion = _userContext.GetCurrentUserId();
                current.FechaModificacion = DateTime.Now;
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();
            }

            return new PagedResult<bool>
            {
                Success = true,
                Message = "Movimiento de almacen eliminado correctamente.",
                Code = "SUCCESS",
                Data = true,
                Items = new List<bool> { true },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<AlmacenResponse>> CreateSalidaAjusteAsync(int origenId, AlmacenResponse response, int usuarioActual)
        {
            if (origenId <= 0)
            {
                return Failure<AlmacenResponse>("Debe seleccionar una existencia origen.", "INVALID_SOURCE");
            }

            var origen = await _context.Almacens
                .FirstOrDefaultAsync(x => x.PkidAlmacen == origenId && x.Activo && x.FkidEmpresaSis == _userContext.GetCurrentEmpresaId());
            if (origen == null)
            {
                return Failure<AlmacenResponse>("La existencia origen no existe o no esta activa.", "NOT_FOUND");
            }

            if (!origen.AplicaAlmacen || origen.Cantidad <= 0)
            {
                return Failure<AlmacenResponse>("La existencia origen no tiene saldo disponible para ajustar.", "NO_STOCK");
            }

            if (IsLocked(origen))
            {
                return Failure<AlmacenResponse>("La existencia origen esta cerrada o contabilizada y no puede ajustarse.", "LOCKED");
            }

            var cantidad = Math.Abs(response.Cantidad);
            if (cantidad <= 0)
            {
                return Failure<AlmacenResponse>("La cantidad de salida debe ser mayor a cero.");
            }

            if (cantidad > origen.Cantidad)
            {
                return Failure<AlmacenResponse>($"La salida por ajuste rebasa la existencia disponible ({origen.Cantidad:0.####}).", "NO_STOCK");
            }

            if (!response.FkidMotivoEsAlma.HasValue || response.FkidMotivoEsAlma.Value <= 0)
            {
                return Failure<AlmacenResponse>("Debe seleccionar un motivo de salida.");
            }

            var motivoValido = await _context.MotivoEs.AnyAsync(x =>
                x.PkidMotivoEs == response.FkidMotivoEsAlma.Value &&
                x.Activo &&
                x.AplicaSalida);
            if (!motivoValido)
            {
                return Failure<AlmacenResponse>("El motivo seleccionado no aplica para salidas de almacen.");
            }

            var fechaSalida = response.FechaEntrada == default ? DateTime.Today : response.FechaEntrada;
            var costoUnitario = GetUnitCost(origen, response.CostoUnitario);
            var importeSalida = Math.Round(cantidad * costoUnitario, 4);

            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                origen.Cantidad -= cantidad;
                if (costoUnitario > 0)
                {
                    origen.CostoUnitario ??= costoUnitario;
                    origen.Costo = Math.Round(origen.Cantidad * costoUnitario, 4);
                }

                origen.FechaModificacion = DateTime.Now;
                origen.UsuarioModificacion = usuarioActual;

                var movimiento = new EG.Infraestructure.Models.Almacen
                {
                    FkidEmpresaSis = origen.FkidEmpresaSis,
                    FkidAnioSis = origen.FkidAnioSis,
                    FkidAreaSis = origen.FkidAreaSis,
                    FkidTipoBienAlma = origen.FkidTipoBienAlma,
                    FkidUnidadesAlma = origen.FkidUnidadesAlma,
                    FkidMotivoEsAlma = response.FkidMotivoEsAlma,
                    FkidDetalleOrdenCompraOrco = origen.FkidDetalleOrdenCompraOrco,
                    Clave = await BuildSalidaClaveAsync(origen),
                    Cantidad = -cantidad,
                    CostoUnitario = costoUnitario,
                    Costo = -importeSalida,
                    Factura = Truncate(response.Factura, 50),
                    Remision = Truncate(string.IsNullOrWhiteSpace(response.Remision) ? $"Origen {origen.Clave}" : response.Remision, 50),
                    Lote = Truncate(string.IsNullOrWhiteSpace(response.Lote) ? origen.Lote : response.Lote, 50),
                    FechaEntrada = DateOnly.FromDateTime(fechaSalida),
                    FechaCaducidad = origen.FechaCaducidad,
                    AplicaAlmacen = false,
                    InventarioCerrado = false,
                    EsContabilizado = false,
                    Activo = true,
                    FechaCreacion = DateTime.Now,
                    UsuarioCreacion = usuarioActual
                };

                _context.Almacens.Add(movimiento);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                var result = await GetByIdAsync(movimiento.PkidAlmacen);
                result.Message = "Salida por ajuste registrada correctamente.";
                return result;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return Failure<AlmacenResponse>($"Error al registrar salida por ajuste: {GetError(ex)}");
            }
        }

        public async Task<PagedResult<AlmacenResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                if (AlmacenPagedFilter.TryGetInt(request, "FkidDetalleOrdenCompraOrco", out var detalleOrdenId))
                {
                    return await GetByDetalleOrdenAsync(request, detalleOrdenId);
                }

                if (!AlmacenPagedFilter.TryGetInt(request, "FkidAnioSis", out var anioId) || anioId <= 0)
                {
                    return Failure<AlmacenResponse>("Debe seleccionar un ejercicio presupuestal.", "YEAR_REQUIRED");
                }

                if (AlmacenPagedFilter.TryGetBool(request, "VistaExistencias", out var vistaExistencias) && vistaExistencias)
                {
                    return await GetExistenciasRegistradasAsync(request, anioId);
                }

                var empresaId = _userContext.GetCurrentEmpresaId();
                var query = _serviceView.GetQueryWithIncludes()
                    .Where(x => x.FkidEmpresaSis == empresaId && x.FkidAnioSis == anioId);

                if (AlmacenPagedFilter.TryGetInt(request, "FkidAreaSis", out var areaId))
                {
                    query = query.Where(x => x.FkidAreaSis == areaId);
                }

                if (AlmacenPagedFilter.TryGetInt(request, "FkidTipoBienAlma", out var tipoBienId))
                {
                    query = query.Where(x => x.FkidTipoBienAlma == tipoBienId);
                }

                if (AlmacenPagedFilter.TryGetBool(request, "AplicaAlmacen", out var aplicaAlmacen))
                {
                    query = query.Where(x => x.AplicaAlmacen == aplicaAlmacen);
                }

                if (AlmacenPagedFilter.TryGetString(request, "TipoMovimiento", out var tipoMovimiento))
                {
                    query = tipoMovimiento.ToUpperInvariant().Replace("_", string.Empty).Replace(" ", string.Empty) switch
                    {
                        "SALIDAAJUSTE" => query.Where(x => !x.AplicaAlmacen && x.Cantidad < 0),
                        "EXISTENCIA" => query.Where(x => x.AplicaAlmacen && x.Cantidad > 0),
                        "ENTRADA" or "ENTRADAAJUSTE" => query.Where(x => x.AplicaAlmacen && x.Cantidad > 0),
                        "SALIDA" => query.Where(x => x.Cantidad < 0),
                        _ => query
                    };
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Clave != null && x.Clave.Contains(filtro)) ||
                        (x.TipoBienClave != null && x.TipoBienClave.Contains(filtro)) ||
                        (x.TipoBienDescripcion != null && x.TipoBienDescripcion.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)) ||
                        (x.MotivoDescripcion != null && x.MotivoDescripcion.Contains(filtro)) ||
                        (x.Factura != null && x.Factura.Contains(filtro)) ||
                        (x.Remision != null && x.Remision.Contains(filtro)) ||
                        (x.Lote != null && x.Lote.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);
                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

                return Success(items.Adapt<List<AlmacenResponse>>(), "Movimientos de almacen obtenidos correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<AlmacenResponse>($"Error al obtener movimientos de almacen: {GetError(ex)}");
            }
        }

        private async Task<PagedResult<AlmacenResponse>> GetByDetalleOrdenAsync(PagedRequest request, int detalleOrdenId)
        {
            var query = _context.Almacens
                .AsNoTracking()
                .Include(x => x.FkidEmpresaSisNavigation)
                .Include(x => x.FkidAreaSisNavigation)
                .Include(x => x.FkidTipoBienAlmaNavigation)
                .ThenInclude(x => x.FkidUnidadesAlmaNavigation)
                .Include(x => x.FkidMotivoEsAlmaNavigation)
                .Where(x => x.Activo && x.FkidDetalleOrdenCompraOrco == detalleOrdenId && x.FkidEmpresaSis == _userContext.GetCurrentEmpresaId());

            if (AlmacenPagedFilter.TryGetInt(request, "FkidAnioSis", out var anioId) && anioId > 0)
            {
                query = query.Where(x => x.FkidAnioSis == anioId);
            }

            var filtro = request.Filtro?.Trim();
            if (!string.IsNullOrWhiteSpace(filtro))
            {
                query = query.Where(x =>
                    (x.Clave != null && x.Clave.Contains(filtro)) ||
                    (x.Factura != null && x.Factura.Contains(filtro)) ||
                    (x.Remision != null && x.Remision.Contains(filtro)) ||
                    (x.Lote != null && x.Lote.Contains(filtro)) ||
                    (x.FkidTipoBienAlmaNavigation != null && x.FkidTipoBienAlmaNavigation.Descripcion.Contains(filtro)));
            }

            var total = await query.CountAsync();
            var page = Math.Max(1, request.Page);
            var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
            var entities = await query
                .OrderByDescending(x => x.FechaEntrada)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .ToListAsync();
            var items = entities.Select(ToResponse).ToList();

            return Success(items, "Entradas de orden de compra obtenidas correctamente", total);
        }

        private async Task NotifyPendingReceiptAsync(int? orderDetailId, int currentUserId)
        {
            if (!orderDetailId.HasValue)
                return;

            try
            {
                var detail = await _context.OrdenCompraDetalles
                    .AsNoTracking()
                    .Include(x => x.FkidOrdenCompraOrcoNavigation)
                    .FirstOrDefaultAsync(x => x.PkidOrdenCompraDetalle == orderDetailId.Value && x.Activo);

                if (detail == null || detail.CantidadRecibida >= detail.CantidadSolicitada)
                    return;

                var recipientId = detail.FkidOrdenCompraOrcoNavigation.UsuarioCreacion;
                if (recipientId <= 0)
                    return;

                var pending = detail.CantidadSolicitada - detail.CantidadRecibida;
                var users = new DataTable();
                users.Columns.Add("Fk_IdUsuarioDestino", typeof(int));
                users.Rows.Add(recipientId);
                var notificationId = new OutputParameter<long?>();
                var orderId = detail.FkidOrdenCompraOrco;
                await _context.Procedures.sp_NotificacionCrearAsync(
                    "RECEPCION_PARCIAL", currentUserId, "Almacen", "Recepcion_Pedidos",
                    "RecepcionParcial", "OrdenCompra", orderId,
                    $"Recepcion parcial de la orden {orderId}",
                    $"La entrega quedo incompleta. Cantidad recibida: {detail.CantidadRecibida:N2}; pendiente: {pending:N2}.",
                    "/Almacen/Recepcion_Pedidos", $"{{\"ordenCompraId\":{orderId},\"detalleId\":{detail.PkidOrdenCompraDetalle},\"pendiente\":{pending}}}",
                    users, currentUserId, notificationId);
            }
            catch
            {
                // Una notificacion no debe revertir una recepcion valida.
            }
        }

        private async Task<PagedResult<AlmacenResponse>> GetExistenciasRegistradasAsync(PagedRequest request, int anioId)
        {
            var empresaId = _userContext.GetCurrentEmpresaId();
            var movimientos = await _context.Almacens.AsNoTracking()
                .Where(x => x.Activo && x.AplicaAlmacen && x.FkidEmpresaSis == empresaId && x.FkidAnioSis == anioId)
                .GroupBy(x => new { x.FkidTipoBienAlma, x.FkidUnidadesAlma })
                .Select(g => new { g.Key.FkidTipoBienAlma, g.Key.FkidUnidadesAlma, Cantidad = g.Sum(x => x.Cantidad), Costo = g.Sum(x => x.Costo ?? 0m) })
                .ToListAsync();

            var cierres = await _context.CierreInventarios.AsNoTracking()
                .Where(x => x.Activo && x.FkidEmpresaSis == empresaId && x.FkidAnioSis == anioId)
                .GroupBy(x => new { x.FkidTipoBienAlma, x.FkidUnidadesAlma })
                .Select(g => new { g.Key.FkidTipoBienAlma, g.Key.FkidUnidadesAlma, Cantidad = g.Sum(x => x.Existencias), Costo = g.Sum(x => x.CostoExistencias ?? 0m) })
                .ToListAsync();

            var totales = movimientos.Concat(cierres)
                .GroupBy(x => new { x.FkidTipoBienAlma, x.FkidUnidadesAlma })
                .Select(g => new { g.Key.FkidTipoBienAlma, g.Key.FkidUnidadesAlma, Cantidad = g.Sum(x => x.Cantidad), Costo = g.Sum(x => x.Costo) })
                .ToList();
            var ids = totales.Select(x => x.FkidTipoBienAlma).Distinct().ToList();
            var tipos = await _context.TipoBiens.AsNoTracking()
                .Include(x => x.FkidPartidaContaNavigation)
                .Include(x => x.FkidUnidadesAlmaNavigation)
                .Where(x => ids.Contains(x.PkidTipoBien))
                .ToDictionaryAsync(x => x.PkidTipoBien);

            var items = totales.Select(x =>
            {
                tipos.TryGetValue(x.FkidTipoBienAlma, out var tipo);
                var costoUnitario = x.Cantidad == 0 ? 0m : Math.Round(x.Costo / x.Cantidad, 4);
                var minimo = tipo?.ExistenciaMinima;
                var maximo = tipo?.ExistenciaMaxima;
                var estado = x.Cantidad <= 0 ? "Sin existencia" : minimo.HasValue && x.Cantidad <= minimo ? "Mínimo" : maximo.HasValue && x.Cantidad > maximo ? "Máximo excedido" : "Disponible";
                return new AlmacenResponse
                {
                    FkidEmpresaSis = empresaId, FkidAnioSis = anioId, FkidTipoBienAlma = x.FkidTipoBienAlma, FkidUnidadesAlma = x.FkidUnidadesAlma,
                    Clave = tipo?.CodigoClave ?? string.Empty, TipoBienClave = tipo?.CodigoClave ?? string.Empty, TipoBienDescripcion = tipo?.Descripcion ?? string.Empty,
                    UnidadDescripcion = tipo?.FkidUnidadesAlmaNavigation?.Descripcion ?? string.Empty, Cantidad = x.Cantidad, Costo = x.Costo, CostoUnitario = costoUnitario,
                    Cucop = tipo?.CucopPlus ?? string.Empty, Cabms = tipo?.Cabms ?? string.Empty, PartidaClave = tipo?.FkidPartidaContaNavigation?.Clave ?? string.Empty,
                    ExistenciaMinima = minimo, ExistenciaMaxima = maximo, EstadoExistencia = estado, Activo = true, AplicaAlmacen = true
                };
            });

            var filtro = request.Filtro?.Trim();
            if (!string.IsNullOrWhiteSpace(filtro))
                items = items.Where(x => x.Clave.Contains(filtro, StringComparison.OrdinalIgnoreCase) || x.TipoBienDescripcion.Contains(filtro, StringComparison.OrdinalIgnoreCase) || x.Cucop.Contains(filtro, StringComparison.OrdinalIgnoreCase) || x.Cabms.Contains(filtro, StringComparison.OrdinalIgnoreCase));
            items = request.SortLabel switch
            {
                "Cantidad" => items.OrderByDescending(x => x.Cantidad),
                "Costo" => items.OrderByDescending(x => x.Costo),
                _ => items.OrderBy(x => x.TipoBienDescripcion)
            };
            var list = items.ToList();
            var page = Math.Max(1, request.Page);
            var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
            return Success(list.Skip((page - 1) * pageSize).Take(pageSize).ToList(), "Existencias registradas obtenidas correctamente", list.Count);
        }

        private async Task<PagedResult<AlmacenResponse>?> NormalizeAndValidateAsync(AlmacenResponse response, bool isCreate)
        {
            response.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
            response.FkidAnioSis = _userContext.GetCurrentAnioPresupuestalId();

            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<AlmacenResponse>("Debe existir una empresa seleccionada.");
            }

            if (response.FkidTipoBienAlma <= 0)
            {
                return Failure<AlmacenResponse>("Debe seleccionar un bien o servicio.");
            }

            var tipoBien = await _context.TipoBiens
                .AsNoTracking()
                .Where(x => x.PkidTipoBien == response.FkidTipoBienAlma && x.Activo)
                .Select(x => new { x.FkidUnidadesAlma })
                .FirstOrDefaultAsync();

            if (tipoBien == null)
            {
                return Failure<AlmacenResponse>("El bien o servicio seleccionado no existe o esta inactivo.");
            }

            if (!response.FkidAnioSis.HasValue || response.FkidAnioSis.Value <= 0)
            {
                return Failure<AlmacenResponse>("Debe seleccionar un ejercicio presupuestal.", "YEAR_REQUIRED");
            }

            var anio = await _context.Anios.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidAnio == response.FkidAnioSis.Value && x.Activo);
            if (anio == null)
            {
                return Failure<AlmacenResponse>("El ejercicio presupuestal seleccionado no existe o está inactivo.");
            }

            if (response.FkidUnidadesAlma is not > 0)
            {
                response.FkidUnidadesAlma = tipoBien.FkidUnidadesAlma;
            }

            if (response.Cantidad <= 0)
            {
                return Failure<AlmacenResponse>("La cantidad debe ser mayor a cero.");
            }

            if (response.CostoUnitario.HasValue && response.CostoUnitario.Value < 0)
            {
                return Failure<AlmacenResponse>("El costo unitario no puede ser negativo.");
            }

            response.FechaEntrada = response.FechaEntrada == default ? DateTime.Today : response.FechaEntrada;
            if (response.FechaEntrada.Year != anio.Clave)
            {
                return Failure<AlmacenResponse>("La fecha de entrada debe pertenecer al ejercicio presupuestal seleccionado.");
            }

            if (response.FkidDetalleOrdenCompraOrco is not > 0)
                return Failure<AlmacenResponse>("La entrada debe estar vinculada a un detalle de orden de compra.", "ORDER_DETAIL_REQUIRED");

            var ordenDetalle = await _context.OrdenCompraDetalles.AsNoTracking()
                .Where(x =>
                    x.PkidOrdenCompraDetalle == response.FkidDetalleOrdenCompraOrco.Value && x.Activo &&
                    x.FkidOrdenCompraOrcoNavigation.Activo &&
                    x.FkidOrdenCompraOrcoNavigation.FkidEstatusOrdenCompraOrco >= 2 &&
                    x.FkidOrdenCompraOrcoNavigation.FkidEmpresaSis == response.FkidEmpresaSis &&
                    x.FkidOrdenCompraOrcoNavigation.FkidRequisicionOrcoNavigation.FkidAnioSis == response.FkidAnioSis)
                .Select(x => new
                {
                    x.FkidTipoBienAlma,
                    x.FkidUnidadesAlma,
                    x.CantidadSolicitada,
                    x.CantidadRecibida,
                    PartidaClave = x.FkidTipoBienAlmaNavigation.FkidPartidaContaNavigation.Clave
                })
                .FirstOrDefaultAsync();
            if (ordenDetalle == null)
                return Failure<AlmacenResponse>("La orden no existe, no esta autorizada o no pertenece a la empresa y ejercicio activos.", "INVALID_ORDER");
            if (ordenDetalle.FkidTipoBienAlma != response.FkidTipoBienAlma || ordenDetalle.FkidUnidadesAlma != response.FkidUnidadesAlma)
                return Failure<AlmacenResponse>("El bien y la unidad deben coincidir con el detalle de la orden.", "ORDER_DETAIL_MISMATCH");
            if (!string.IsNullOrWhiteSpace(ordenDetalle.PartidaClave) && ordenDetalle.PartidaClave.StartsWith("5", StringComparison.Ordinal))
                return Failure<AlmacenResponse>("Los bienes del capitulo 5000 deben recibirse desde Patrimonio para generar su inventario individual.", "PATRIMONIAL_RECEIPT_REQUIRED");
            if (isCreate && response.Cantidad > ordenDetalle.CantidadSolicitada - ordenDetalle.CantidadRecibida)
                return Failure<AlmacenResponse>("La cantidad excede el saldo pendiente de la orden.", "OVER_RECEIPT");
            response.Costo ??= Math.Round(response.Cantidad * (response.CostoUnitario ?? 0m), 4);
            response.Clave = string.IsNullOrWhiteSpace(response.Clave)
                ? await BuildClaveAsync(response)
                : response.Clave.Trim();
            response.Factura ??= string.Empty;
            response.Remision ??= string.Empty;
            response.Lote ??= string.Empty;
            response.AplicaAlmacen = true;
            response.Activo = true;

            return null;
        }

        private async Task AdjustOrderReceiptAsync(int? detalleOrdenId, decimal delta, int usuarioActual)
        {
            if (detalleOrdenId is not > 0 || delta == 0)
                return;
            var detalle = await _context.OrdenCompraDetalles
                .Include(x => x.FkidOrdenCompraOrcoNavigation)
                .ThenInclude(x => x.FkidRequisicionOrcoNavigation)
                .FirstOrDefaultAsync(x => x.PkidOrdenCompraDetalle == detalleOrdenId.Value && x.Activo);
            if (detalle == null || !detalle.FkidOrdenCompraOrcoNavigation.Activo ||
                detalle.FkidOrdenCompraOrcoNavigation.FkidEstatusOrdenCompraOrco < 2 ||
                detalle.FkidOrdenCompraOrcoNavigation.FkidEmpresaSis != _userContext.GetCurrentEmpresaId() ||
                detalle.FkidOrdenCompraOrcoNavigation.FkidRequisicionOrcoNavigation.FkidAnioSis != _userContext.GetCurrentAnioPresupuestalId())
                throw new InvalidOperationException("El detalle de orden no pertenece al contexto operativo activo.");
            var nuevaCantidad = detalle.CantidadRecibida + delta;
            if (nuevaCantidad < 0 || nuevaCantidad > detalle.CantidadSolicitada)
                throw new InvalidOperationException("La recepcion excede la cantidad solicitada o deja un saldo recibido negativo.");
            detalle.CantidadRecibida = nuevaCantidad;
            detalle.FechaModificacion = DateTime.Now;
            detalle.UsuarioModificacion = usuarioActual;
        }

        private async Task<string> BuildClaveAsync(AlmacenResponse response)
        {
            var tipo = await _context.TipoBiens.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidTipoBien == response.FkidTipoBienAlma);
            var prefix = string.IsNullOrWhiteSpace(tipo?.CodigoClave) ? "ALM" : tipo.CodigoClave.Trim();
            prefix = prefix.Length <= 12 ? prefix : prefix[..12];
            return $"{prefix}-{Guid.NewGuid():N}"[..Math.Min(30, prefix.Length + 33)].ToUpperInvariant();
        }

        private Task<string> BuildSalidaClaveAsync(EG.Infraestructure.Models.Almacen origen)
        {
            var clave = $"SA-{origen.PkidAlmacen}-{Guid.NewGuid():N}";
            return Task.FromResult(clave[..Math.Min(30, clave.Length)].ToUpperInvariant());
        }

        private static decimal GetUnitCost(EG.Infraestructure.Models.Almacen entity, decimal? fallback = null)
        {
            if (entity.CostoUnitario.GetValueOrDefault() > 0)
            {
                return entity.CostoUnitario.Value;
            }

            if (fallback.GetValueOrDefault() > 0)
            {
                return fallback.Value;
            }

            if (entity.Costo.GetValueOrDefault() > 0 && entity.Cantidad > 0)
            {
                return Math.Round(entity.Costo!.Value / entity.Cantidad, 4);
            }

            return 0m;
        }

        private static string Truncate(string? value, int maxLength)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                return string.Empty;
            }

            var trimmed = value.Trim();
            return trimmed.Length <= maxLength ? trimmed : trimmed[..maxLength];
        }

        private static void ApplyValues(EG.Infraestructure.Models.Almacen entity, AlmacenResponse response)
        {
            entity.FkidEmpresaSis = response.FkidEmpresaSis;
            entity.FkidAnioSis = response.FkidAnioSis;
            entity.FkidAreaSis = response.FkidAreaSis;
            entity.FkidTipoBienAlma = response.FkidTipoBienAlma;
            entity.FkidUnidadesAlma = response.FkidUnidadesAlma;
            entity.FkidMotivoEsAlma = response.FkidMotivoEsAlma;
            entity.FkidDetalleOrdenCompraOrco = response.FkidDetalleOrdenCompraOrco;
            entity.Clave = response.Clave ?? string.Empty;
            entity.Cantidad = response.Cantidad;
            entity.CostoUnitario = response.CostoUnitario;
            entity.Costo = response.Costo ?? Math.Round(response.Cantidad * (response.CostoUnitario ?? 0m), 4);
            entity.Factura = response.Factura ?? string.Empty;
            entity.Remision = response.Remision ?? string.Empty;
            entity.Lote = response.Lote ?? string.Empty;
            entity.FechaEntrada = DateOnly.FromDateTime(response.FechaEntrada == default ? DateTime.Today : response.FechaEntrada);
            entity.FechaCaducidad = response.FechaCaducidad.HasValue ? DateOnly.FromDateTime(response.FechaCaducidad.Value) : null;
            entity.AplicaAlmacen = response.AplicaAlmacen;
        }

        private static AlmacenResponse ToResponse(EG.Infraestructure.Models.Almacen entity)
        {
            return new AlmacenResponse
            {
                PkidAlmacen = entity.PkidAlmacen,
                FkidEmpresaSis = entity.FkidEmpresaSis,
                FkidAnioSis = entity.FkidAnioSis,
                EmpresaNombre = entity.FkidEmpresaSisNavigation?.Nombre ?? string.Empty,
                FkidAreaSis = entity.FkidAreaSis,
                AreaNombre = entity.FkidAreaSisNavigation?.Nombre ?? string.Empty,
                FkidTipoBienAlma = entity.FkidTipoBienAlma,
                TipoBienClave = entity.FkidTipoBienAlmaNavigation?.CodigoClave ?? string.Empty,
                TipoBienDescripcion = entity.FkidTipoBienAlmaNavigation?.Descripcion ?? string.Empty,
                FkidUnidadesAlma = entity.FkidUnidadesAlma,
                UnidadDescripcion = entity.FkidTipoBienAlmaNavigation?.FkidUnidadesAlmaNavigation?.Descripcion ?? string.Empty,
                FkidMotivoEsAlma = entity.FkidMotivoEsAlma,
                MotivoDescripcion = entity.FkidMotivoEsAlmaNavigation?.Descripcion ?? string.Empty,
                FkidDetalleOrdenCompraOrco = entity.FkidDetalleOrdenCompraOrco,
                Clave = entity.Clave ?? string.Empty,
                Cantidad = entity.Cantidad,
                CostoUnitario = entity.CostoUnitario,
                Costo = entity.Costo,
                Factura = entity.Factura ?? string.Empty,
                Remision = entity.Remision ?? string.Empty,
                Lote = entity.Lote ?? string.Empty,
                FechaEntrada = entity.FechaEntrada.ToDateTime(TimeOnly.MinValue),
                FechaCaducidad = entity.FechaCaducidad?.ToDateTime(TimeOnly.MinValue),
                AplicaAlmacen = entity.AplicaAlmacen,
                InventarioCerrado = entity.InventarioCerrado,
                EsContabilizado = entity.EsContabilizado,
                Activo = entity.Activo,
                FechaCreacion = entity.FechaCreacion,
                UsuarioCreacion = entity.UsuarioCreacion,
                FechaModificacion = entity.FechaModificacion,
                UsuarioModificacion = entity.UsuarioModificacion
            };
        }

        private static bool IsLocked(EG.Infraestructure.Models.Almacen entity) =>
            entity.InventarioCerrado || entity.EsContabilizado;

        private static IQueryable<VwAlmacen> ApplySort(IQueryable<VwAlmacen> query, string? sortLabel, string? sortDirection)
        {
            var desc = sortDirection?.Contains("Desc", StringComparison.OrdinalIgnoreCase) == true;
            return sortLabel switch
            {
                "Clave" => desc ? query.OrderByDescending(x => x.Clave) : query.OrderBy(x => x.Clave),
                "TipoBienDescripcion" => desc ? query.OrderByDescending(x => x.TipoBienDescripcion) : query.OrderBy(x => x.TipoBienDescripcion),
                "Cantidad" => desc ? query.OrderByDescending(x => x.Cantidad) : query.OrderBy(x => x.Cantidad),
                "Costo" => desc ? query.OrderByDescending(x => x.Costo) : query.OrderBy(x => x.Costo),
                "FechaEntrada" => desc ? query.OrderByDescending(x => x.FechaEntrada) : query.OrderBy(x => x.FechaEntrada),
                _ => query.OrderByDescending(x => x.FechaEntrada).ThenByDescending(x => x.PkidAlmacen)
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
