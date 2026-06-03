using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class OrdenCompraDetalleAppService
        : AdquisicionCrudAppService<OrdenCompraDetalle, VwOrdenCompraDetalle, OrdenCompraDetalleDto, OrdenCompraDetalleResponse>,
            IOrdenCompraDetalleAppService
    {
        private readonly EGestionContext _context;

        public OrdenCompraDetalleAppService(
            GenericService<OrdenCompraDetalle, OrdenCompraDetalleDto, OrdenCompraDetalleResponse> service,
            GenericService<VwOrdenCompraDetalle, OrdenCompraDetalleDto, OrdenCompraDetalleResponse> serviceView,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidOrdenCompraDetalle",
                "Detalle de orden de compra",
                (dto, id) => dto.PkidOrdenCompraDetalle = id)
        {
            _context = context;
        }

        public override async Task<PagedResult<OrdenCompraDetalleResponse>> CreateAsync(
            OrdenCompraDetalleResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, null);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var spResult = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                response.PkidOrdenCompraDetalle = spResult.GetId() ?? 0;
                var result = await GetByIdAsync(response.PkidOrdenCompraDetalle);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return Failure($"Error al crear detalle de orden de compra: {ex.Message}");
            }
        }

        public override async Task<PagedResult<OrdenCompraDetalleResponse>> UpdateAsync(
            int id,
            OrdenCompraDetalleResponse response,
            int usuarioActual)
        {
            var validation = await NormalizeAndValidateAsync(response, id);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                var spResult = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (Exception ex)
            {
                return Failure($"Error al actualizar detalle de orden de compra: {ex.Message}");
            }
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var detalle = await _context.OrdenCompraDetalles
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidOrdenCompraDetalle == id && x.Activo);

            if (detalle == null)
            {
                return BoolFailure($"Detalle de orden de compra con ID {id} no encontrado.", "NOT_FOUND");
            }

            if (await IsOrdenLockedAsync(detalle.FkidOrdenCompraOrco))
            {
                return BoolFailure("La orden de compra ya fue autorizada. No se pueden eliminar detalles.", "LOCKED");
            }

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoOrdenCompraDetalle]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdOrdenCompraDetalle", id));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = spResult.Mensaje,
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return BoolFailure($"Error al eliminar detalle de orden de compra: {ex.Message}");
            }
        }

        private async Task<PagedResult<OrdenCompraDetalleResponse>?> NormalizeAndValidateAsync(
            OrdenCompraDetalleResponse response,
            int? currentId)
        {
            if (response.FkidOrdenCompraOrco <= 0)
            {
                return Failure("Debe existir una orden de compra seleccionada.");
            }

            if (await IsOrdenLockedAsync(response.FkidOrdenCompraOrco))
            {
                return Failure("La orden de compra ya fue autorizada. No se pueden modificar detalles.", "LOCKED");
            }

            if (response.FkidCotizacionDetalleOrco.HasValue && response.FkidCotizacionDetalleOrco.Value > 0)
            {
                var cotizacionDetalle = await _context.CotizacionDetalles
                    .Include(x => x.FkidRequisicionDetalleOrcoNavigation)
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidCotizacionDetalle == response.FkidCotizacionDetalleOrco.Value && x.Activo);

                if (cotizacionDetalle == null)
                {
                    return Failure("El detalle de cotizacion seleccionado no existe o esta inactivo.");
                }

                ApplyFromRequisicionDetalle(response, cotizacionDetalle.FkidRequisicionDetalleOrcoNavigation);
                response.FkidRequisicionDetalleOrco = cotizacionDetalle.FkidRequisicionDetalleOrco;

                if (cotizacionDetalle.PrecioUnitario.HasValue && cotizacionDetalle.PrecioUnitario.Value > 0)
                {
                    if (response.PrecioUnitario <= 0)
                    {
                        response.PrecioUnitario = cotizacionDetalle.PrecioUnitario.Value;
                    }

                    if (response.PrecioUnitario > cotizacionDetalle.PrecioUnitario.Value)
                    {
                        return Failure("El precio unitario de la orden de compra rebasa el precio unitario cotizado.");
                    }
                }
            }

            if (response.FkidRequisicionDetalleOrco.HasValue && response.FkidRequisicionDetalleOrco.Value > 0)
            {
                var requisicionDetalle = await _context.RequisicionDetalles
                    .AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidRequisicionDetalle == response.FkidRequisicionDetalleOrco.Value && x.Activo);

                if (requisicionDetalle == null)
                {
                    return Failure("El detalle de requisicion seleccionado no existe o esta inactivo.");
                }

                ApplyFromRequisicionDetalle(response, requisicionDetalle);

                if (response.CantidadSolicitada <= 0)
                {
                    response.CantidadSolicitada = requisicionDetalle.Cantidad;
                }

                var cantidadYaOrdenada = await _context.OrdenCompraDetalles
                    .Where(x =>
                        x.FkidRequisicionDetalleOrco == response.FkidRequisicionDetalleOrco.Value &&
                        x.Activo &&
                        x.PkidOrdenCompraDetalle != (currentId ?? 0))
                    .SumAsync(x => x.CantidadSolicitada);

                if (response.CantidadSolicitada + cantidadYaOrdenada > requisicionDetalle.Cantidad)
                {
                    return Failure("La cantidad de la orden de compra rebasa la cantidad de la requisicion.");
                }
            }

            if (response.CantidadSolicitada <= 0)
            {
                return Failure("La cantidad de la orden de compra debe ser mayor a cero.");
            }

            if (response.FkidTipoBienAlma <= 0)
            {
                return Failure("Debe seleccionar un bien o servicio.");
            }

            if (response.FkidUnidadesAlma <= 0)
            {
                return Failure("Debe seleccionar una unidad de medida.");
            }

            if (response.PrecioUnitario < 0)
            {
                return Failure("El precio unitario no puede ser negativo.");
            }

            response.Observaciones ??= string.Empty;
            response.CantidadRecibida = Math.Max(0, response.CantidadRecibida);

            return null;
        }

        private static void ApplyFromRequisicionDetalle(
            OrdenCompraDetalleResponse response,
            RequisicionDetalle? requisicionDetalle)
        {
            if (requisicionDetalle == null)
            {
                return;
            }

            response.FkidTipoBienAlma = requisicionDetalle.FkidTipoBienAlma;
            if (requisicionDetalle.FkidUnidadesAlma.HasValue)
            {
                response.FkidUnidadesAlma = requisicionDetalle.FkidUnidadesAlma.Value;
            }
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            OrdenCompraDetalleResponse response,
            int usuarioActual)
        {
            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoOrdenCompraDetalle]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdOrdenCompraDetalle", id),
                StoredProcedureExecutor.Param("@FKIdOrdenCompra_ORCO", response.FkidOrdenCompraOrco),
                StoredProcedureExecutor.Param("@FKIdRequisicionDetalle_ORCO", response.FkidRequisicionDetalleOrco),
                StoredProcedureExecutor.Param("@FKIdCotizacionDetalle_ORCO", response.FkidCotizacionDetalleOrco),
                StoredProcedureExecutor.Param("@FKIdTipoBien_ALMA", response.FkidTipoBienAlma),
                StoredProcedureExecutor.Param("@FKIdUnidades_ALMA", response.FkidUnidadesAlma),
                StoredProcedureExecutor.Param("@CantidadSolicitada", response.CantidadSolicitada),
                StoredProcedureExecutor.Param("@CantidadRecibida", response.CantidadRecibida),
                StoredProcedureExecutor.Param("@PrecioUnitario", response.PrecioUnitario),
                StoredProcedureExecutor.Param("@Iva", response.Iva),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));
        }

        private async Task<bool> IsOrdenLockedAsync(int ordenCompraId)
        {
            return await _context.OrdenCompras
                .AnyAsync(x => x.PkidOrdenCompra == ordenCompraId && x.Activo && x.FkidEstatusOrdenCompraOrco > 1);
        }

        private static PagedResult<OrdenCompraDetalleResponse> Failure(string message, string code = "ERROR")
        {
            return new PagedResult<OrdenCompraDetalleResponse>
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
