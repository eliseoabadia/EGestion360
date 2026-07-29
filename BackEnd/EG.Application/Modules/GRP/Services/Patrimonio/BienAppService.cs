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
            var companyId = _userContext.GetCurrentEmpresaId();
            var items = (await _serviceView.GetQueryWithIncludes()
                .Where(x => x.Activo && x.FkidEmpresaSis == companyId).ToListAsync()).Adapt<List<BienResponse>>();
            await ApplyEntityKeysAsync(items);
            return Success(items, "Bienes obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<BienResponse>> GetByIdAsync(int id)
        {
            var companyId = _userContext.GetCurrentEmpresaId();
            var view = await _serviceView.GetQueryWithIncludes()
                .FirstOrDefaultAsync(x => x.PkidBien == id && x.Activo && x.FkidEmpresaSis == companyId);
            if (view == null)
            {
                return Failure<BienResponse>($"Bien con ID {id} no encontrado.", "NOT_FOUND");
            }

            var item = view.Adapt<BienResponse>();
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
            response.FkidEmpresaSis = _userContext.GetCurrentEmpresaId();
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
            var companyId = _userContext.GetCurrentEmpresaId();
            var current = await _context.Biens.AsNoTracking().FirstOrDefaultAsync(x => x.PkidBien == id && x.Activo && x.FkidEmpresaSis == companyId);
            if (current == null)
            {
                return Failure<BienResponse>($"Bien con ID {id} no encontrado.", "NOT_FOUND");
            }

            var lockReason = await GetLockReasonAsync(current.PkidBien);
            if (lockReason.Length > 0) return Failure<BienResponse>(lockReason, "BIEN_LOCKED");

            response.FkidEmpresaSis = companyId;
            response.FkidTipoBienAlma = current.FkidTipoBienAlma;
            response.FkidPartidaConta = current.FkidPartidaConta;
            response.FechaAdq = current.FechaAdq;
            response.EsContabilizado = current.EsContabilizado;

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
            await Task.CompletedTask;
            return new PagedResult<bool>
            {
                Success = false,
                Message = "Los bienes no se eliminan directamente; utilice el proceso formal de baja.",
                Code = "USE_BAJA",
                Data = false,
                TotalCount = 0
            };
        }

        public async Task<PagedResult<BienResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var companyId = _userContext.GetCurrentEmpresaId();
                var query = _serviceView.GetQueryWithIncludes().Where(x => x.Activo && x.FkidEmpresaSis == companyId);

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

        public async Task<PagedResult<BienResponse>> GenerarDesdeDetalleOrdenCompraAsync(
            int detalleOrdenCompraId,
            int usuarioActual)
        {
            var companyId = _userContext.GetCurrentEmpresaId();
            var detalle = await _context.OrdenCompraDetalles
                .AsNoTracking()
                .Include(x => x.FkidOrdenCompraOrcoNavigation)
                .Include(x => x.FkidTipoBienAlmaNavigation)
                .FirstOrDefaultAsync(x => x.PkidOrdenCompraDetalle == detalleOrdenCompraId && x.Activo);

            if (detalle == null)
            {
                return Failure<BienResponse>("El detalle de orden de compra no existe o esta inactivo.", "NOT_FOUND");
            }

            if (detalle.FkidOrdenCompraOrcoNavigation?.FkidEmpresaSis != companyId || detalle.FkidOrdenCompraOrcoNavigation.FkidEstatusOrdenCompraOrco < 2)
            {
                return Failure<BienResponse>("La orden no pertenece a la empresa actual o aun no esta autorizada para surtirse.", "INVALID_ORDER_STATUS");
            }

            var cantidadObjetivo = detalle.CantidadRecibida;
            var objetivo = Convert.ToInt32(Math.Truncate(cantidadObjetivo));

            if (objetivo <= 0)
            {
                return Failure<BienResponse>("Primero debe registrar una cantidad recibida para generar bienes.");
            }

            var existentes = await _context.Biens
                .AsNoTracking()
                .CountAsync(x => x.FkidDetalleOrdenCompraOrco == detalleOrdenCompraId && x.Activo);
            var faltantes = Math.Max(0, objetivo - existentes);

            if (faltantes == 0)
            {
                return new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Los bienes de este detalle ya estan generados.",
                    Code = "SUCCESS",
                    Items = new List<BienResponse>(),
                    TotalCount = existentes
                };
            }

            var orden = detalle.FkidOrdenCompraOrcoNavigation;
            var requisicion = orden == null
                ? null
                : await _context.Requisicions
                    .AsNoTracking()
                    .Include(x => x.FkidEgresoAutorizadoPresNavigation)
                    .FirstOrDefaultAsync(x => x.PkidRequisicion == orden.FkidRequisicionOrco && x.Activo);

            var precioUnitario = detalle.PrecioUnitario > 0
                ? detalle.PrecioUnitario
                : objetivo > 0
                    ? (detalle.TotalDetalle ?? detalle.Importe ?? 0m) / objetivo
                    : 0m;

            if (precioUnitario <= 0)
            {
                return Failure<BienResponse>("El detalle no tiene precio unitario valido para generar bienes.");
            }

            var response = new BienResponse
            {
                FkidEmpresaSis = companyId,
                FkidGrupoBienAlma = detalle.FkidTipoBienAlmaNavigation?.FkidGrupoBienAlma,
                FkidTipoBienAlma = detalle.FkidTipoBienAlma,
                FkidProveedorSis = orden?.FkidProveedorSis,
                FkidPartidaConta = detalle.FkidTipoBienAlmaNavigation?.FkidPartidaConta
                    ?? requisicion?.FkidEgresoAutorizadoPresNavigation?.FkidPartidaConta,
                FkidDetalleOrdenCompraOrco = detalleOrdenCompraId,
                FkidAreaSis = requisicion?.FkidAreaSis,
                FkidEstadoBienAlma = 3,
                FkidTipoPatrimonioAlma = 1,
                Descripcion = detalle.FkidTipoBienAlmaNavigation?.Descripcion
                    ?? detalle.Observaciones
                    ?? $"Bien de detalle {detalleOrdenCompraId}",
                Requisicion = requisicion?.PkidRequisicion.ToString() ?? string.Empty,
                Costo = precioUnitario,
                ValorActual = precioUnitario,
                FechaAdq = orden?.FechaOrdenCompra.ToDateTime(TimeOnly.MinValue) ?? DateTime.Today,
                Notas = $"Generado desde orden de compra {orden?.NumeroOrdenCompra ?? detalle.FkidOrdenCompraOrco.ToString()}",
                Modelo = string.Empty,
                Serie = string.Empty,
                Factura = string.Empty,
                Referencia = orden?.NumeroOrdenCompra ?? string.Empty,
                Ubicacion = string.Empty,
                Aadquisicion = string.Empty,
                Rango = string.Empty,
                Resolucion = string.Empty,
                Estatus = string.Empty,
                Caracteristicas = string.Empty,
                Localizado = true,
                EsContabilizado = false,
                VerificacionesDias = 365,
                MantenimientoDias = 180,
                Mantenimiento = true,
                Calibracion = true,
                Activo = true
            };

            try
            {
                await using var transaction = await _context.Database.BeginTransactionAsync();
                for (var index = 0; index < faltantes; index++)
                {
                    await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                }

                await _context.Database.ExecuteSqlInterpolatedAsync(
                    $"EXEC [ALMA].[SP_CerrarRecepcionPatrimonial] @DetalleOrdenCompraId={detalleOrdenCompraId}, @EmpresaId={companyId}, @UsuarioId={usuarioActual}");
                await transaction.CommitAsync();

                return new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = faltantes == 1
                        ? "Se genero 1 bien desde la orden de compra."
                        : $"Se generaron {faltantes} bienes desde la orden de compra.",
                    Code = "SUCCESS",
                    Items = new List<BienResponse>(),
                    TotalCount = existentes + faltantes
                };
            }
            catch (Exception ex)
            {
                return Failure<BienResponse>($"Error al generar bienes desde la orden de compra: {ex.Message}");
            }
        }

        public async Task<PagedResult<BienResponse>> RegistrarRecepcionAsync(
            int detalleOrdenCompraId,
            decimal cantidadRecibida,
            int usuarioActual)
        {
            var companyId = _userContext.GetCurrentEmpresaId();
            var detalle = await _context.OrdenCompraDetalles
                .Include(x => x.FkidOrdenCompraOrcoNavigation)
                .FirstOrDefaultAsync(x => x.PkidOrdenCompraDetalle == detalleOrdenCompraId && x.Activo);

            if (detalle == null)
            {
                return Failure<BienResponse>("El detalle de orden de compra no existe o esta inactivo.", "NOT_FOUND");
            }

            var orden = detalle.FkidOrdenCompraOrcoNavigation;
            if (orden == null || orden.FkidEmpresaSis != companyId)
            {
                return Failure<BienResponse>("La orden de compra no pertenece a la empresa activa.", "FORBIDDEN");
            }

            if (orden.FkidEstatusOrdenCompraOrco < 2)
            {
                return Failure<BienResponse>("La orden debe estar autorizada antes de registrar su recepcion.", "INVALID_ORDER_STATUS");
            }

            if (cantidadRecibida < 0 || cantidadRecibida > detalle.CantidadSolicitada)
            {
                return Failure<BienResponse>($"La cantidad recibida debe estar entre 0 y {detalle.CantidadSolicitada:0.####}.");
            }

            if (cantidadRecibida != decimal.Truncate(cantidadRecibida))
            {
                return Failure<BienResponse>("Los bienes muebles deben recibirse en unidades completas.");
            }

            var bienesGenerados = await _context.Biens
                .AsNoTracking()
                .CountAsync(x => x.FkidDetalleOrdenCompraOrco == detalleOrdenCompraId && x.Activo);
            if (cantidadRecibida < bienesGenerados)
            {
                return Failure<BienResponse>($"No puede reducir la recepcion por debajo de los {bienesGenerados} bienes ya generados.");
            }

            detalle.CantidadRecibida = cantidadRecibida;
            detalle.FechaModificacion = DateTime.Now;
            detalle.UsuarioModificacion = usuarioActual;
            await _context.SaveChangesAsync();

            return new PagedResult<BienResponse>
            {
                Success = true,
                Code = "SUCCESS",
                Message = $"Recepcion registrada: {cantidadRecibida:0.####} de {detalle.CantidadSolicitada:0.####}.",
                Items = new List<BienResponse>(),
                TotalCount = bienesGenerados
            };
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

            if (!await _context.TipoBiens.AsNoTracking().AnyAsync(x => x.PkidTipoBien == response.FkidTipoBienAlma && x.Activo &&
                x.FkidPartidaContaNavigation.Activo && x.FkidPartidaContaNavigation.Clave.StartsWith("5")))
            {
                return Failure<BienResponse>("El tipo de bien no existe, esta inactivo o no pertenece al capitulo 5000.");
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
                "[ALMA].[SP_MantenimientoBienEmpresa]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdBien", id),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", _userContext.GetCurrentEmpresaId()),
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
                    x.FkidEmpresaSis,
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
                item.FkidEmpresaSis = key.FkidEmpresaSis;
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
                item.MotivoBloqueo = await GetLockReasonAsync(item.PkidBien);
                item.BloqueadoOperacion = item.MotivoBloqueo.Length > 0;
                item.TieneBajaActiva = await _context.Bajas.AsNoTracking()
                    .AnyAsync(x => x.FkidBienAlma == item.PkidBien && x.Activo);
            }
        }

        private async Task<string> GetLockReasonAsync(int id)
        {
            var state = await _context.Biens.AsNoTracking().Where(x => x.PkidBien == id)
                .Select(x => new { Resguardado = x.EstaResguardado == true, Contabilizado = x.EsContabilizado == true })
                .FirstOrDefaultAsync();
            if (state == null) return "El bien no existe.";
            if (state.Contabilizado) return "El bien ya esta contabilizado.";
            if (state.Resguardado) return "El bien tiene un resguardo activo.";
            if (await _context.Bajas.AsNoTracking().AnyAsync(x => x.FkidBienAlma == id && x.Activo))
                return "El bien tiene un proceso de baja activo.";
            return string.Empty;
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
