using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class CotizacionDetalleAppService
        : AdquisicionCrudAppService<CotizacionDetalle, VwCotizacionDetalle, CotizacionDetalleDto, CotizacionDetalleResponse>,
            ICotizacionDetalleAppService
    {
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public CotizacionDetalleAppService(
            GenericService<CotizacionDetalle, CotizacionDetalleDto, CotizacionDetalleResponse> service,
            GenericService<VwCotizacionDetalle, CotizacionDetalleDto, CotizacionDetalleResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
            : base(
                service,
                serviceView,
                "PkidCotizacionDetalle",
                "Detalle de cotizacion",
                (dto, id) => dto.PkidCotizacionDetalle = id)
        {
            _context = context;
            _userContext = userContext;
        }

        public override async Task<PagedResult<CotizacionDetalleResponse>> CreateAsync(
            CotizacionDetalleResponse response,
            int usuarioActual)
        {
            var validation = await ValidateAsync(response);
            if (validation != null)
            {
                return validation;
            }

            if (ExistsDuplicate(response.FkidCotizacionOrco, response.FkidRequisicionDetalleOrco))
            {
                return DuplicateResult("El bien seleccionado ya esta agregado en esta cotizacion.");
            }

            return await base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<CotizacionDetalleResponse>> UpdateAsync(
            int id,
            CotizacionDetalleResponse response,
            int usuarioActual)
        {
            var validation = await ValidateAsync(response, id);
            if (validation != null)
            {
                return validation;
            }

            if (ExistsDuplicate(response.FkidCotizacionOrco, response.FkidRequisicionDetalleOrco, id))
            {
                return DuplicateResult("Ya existe otro renglon activo con el mismo bien en esta cotizacion.");
            }

            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var detalle = await _context.CotizacionDetalles
                .AsNoTracking()
                .Include(x => x.FkidCotizacionOrcoNavigation)
                .ThenInclude(x => x.FkidRequisicionOrcoNavigation)
                .FirstOrDefaultAsync(x => x.PkidCotizacionDetalle == id && x.Activo);

            if (detalle == null ||
                detalle.FkidCotizacionOrcoNavigation == null ||
                !detalle.FkidCotizacionOrcoNavigation.Activo ||
                detalle.FkidCotizacionOrcoNavigation.FkidRequisicionOrcoNavigation.FkidEmpresaSis !=
                    RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext))
            {
                return Failure<bool>("El bien cotizado no existe o no pertenece a la empresa actual.", "NOT_FOUND");
            }

            if (await HasDownstreamSuficienciaAsync(detalle.FkidCotizacionOrco))
            {
                return Failure<bool>("El bien cotizado ya forma parte de una suficiencia y no puede eliminarse.", "LOCKED");
            }

            if (await _context.OrdenCompraDetalles.AsNoTracking()
                    .AnyAsync(x => x.Activo && x.FkidCotizacionDetalleOrco == id))
            {
                return Failure<bool>("El bien cotizado ya se utilizó en una orden de compra y no puede eliminarse.", "LOCKED");
            }

            return await base.DeleteAsync(id);
        }

        private async Task<PagedResult<CotizacionDetalleResponse>?> ValidateAsync(
            CotizacionDetalleResponse response,
            int? currentDetalleId = null)
        {
            if (response == null)
            {
                return Failure<CotizacionDetalleResponse>("El detalle de cotización no contiene datos.", "VALIDATION");
            }

            if (response.FkidCotizacionOrco <= 0)
            {
                return Failure<CotizacionDetalleResponse>("Debe seleccionar una cotización.", "VALIDATION");
            }

            if (response.FkidRequisicionDetalleOrco <= 0)
            {
                return Failure<CotizacionDetalleResponse>("Debe seleccionar un bien requisitado.", "VALIDATION");
            }

            if (response.PrecioUnitario.GetValueOrDefault() <= 0m)
            {
                return Failure<CotizacionDetalleResponse>("El precio unitario debe ser mayor a cero.", "INVALID_AMOUNT");
            }

            var empresaId = RequisicionWorkflowGuard.GetCurrentEmpresaId(_userContext);
            var cotizacion = await _context.Cotizacions
                .AsNoTracking()
                .Include(x => x.FkidRequisicionOrcoNavigation)
                .FirstOrDefaultAsync(x =>
                    x.PkidCotizacion == response.FkidCotizacionOrco &&
                    x.Activo &&
                    x.FkidRequisicionOrcoNavigation.Activo &&
                    x.FkidRequisicionOrcoNavigation.FkidEmpresaSis == empresaId &&
                    x.FkidRequisicionOrcoNavigation.FkidAnioSis == _userContext.GetCurrentAnioPresupuestalId());

            if (cotizacion == null)
            {
                return Failure<CotizacionDetalleResponse>(
                    "La cotización no existe o no pertenece a la empresa y ejercicio activos.",
                    "NOT_FOUND");
            }

            if (await HasDownstreamSuficienciaAsync(cotizacion.PkidCotizacion))
            {
                return Failure<CotizacionDetalleResponse>(
                    "La cotización ya forma parte de una suficiencia y sus bienes no pueden modificarse.",
                    "LOCKED");
            }

            var requisicionDetalle = await _context.RequisicionDetalles
                .AsNoTracking()
                .AnyAsync(x =>
                    x.PkidRequisicionDetalle == response.FkidRequisicionDetalleOrco &&
                    x.Activo &&
                    x.FkidRequisicionOrco == cotizacion.FkidRequisicionOrco);

            if (!requisicionDetalle)
            {
                return Failure<CotizacionDetalleResponse>(
                    "El bien seleccionado no pertenece a la requisición de esta cotización.",
                    "RELATIONSHIP_MISMATCH");
            }

            if (currentDetalleId.HasValue &&
                await _context.OrdenCompraDetalles.AsNoTracking()
                    .AnyAsync(x => x.Activo && x.FkidCotizacionDetalleOrco == currentDetalleId.Value))
            {
                return Failure<CotizacionDetalleResponse>(
                    "El bien cotizado ya se utilizó en una orden de compra y no puede modificarse.",
                    "LOCKED");
            }

            return null;
        }

        private Task<bool> HasDownstreamSuficienciaAsync(int cotizacionId) =>
            _context.Cotizacions.AsNoTracking()
                .Where(x => x.PkidCotizacion == cotizacionId)
                .AnyAsync(x => _context.SolicitudSuficiencia.Any(s =>
                    s.Activo && s.FkidRequisicionOrco == x.FkidRequisicionOrco));

        private bool ExistsDuplicate(int cotizacionId, int requisicionDetalleId, int? excludeId = null)
        {
            return _service.GetQueryWithIncludes()
                .Any(x =>
                    x.FkidCotizacionOrco == cotizacionId &&
                    x.FkidRequisicionDetalleOrco == requisicionDetalleId &&
                    (!excludeId.HasValue || x.PkidCotizacionDetalle != excludeId.Value));
        }

        private static PagedResult<CotizacionDetalleResponse> DuplicateResult(string message)
        {
            return new PagedResult<CotizacionDetalleResponse>
            {
                Success = false,
                Message = message,
                Code = "DUPLICATE",
                TotalCount = 0
            };
        }

    }
}
