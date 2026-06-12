using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class CotizacionDetalleAppService
        : AdquisicionCrudAppService<CotizacionDetalle, VwCotizacionDetalle, CotizacionDetalleDto, CotizacionDetalleResponse>,
            ICotizacionDetalleAppService
    {
        public CotizacionDetalleAppService(
            GenericService<CotizacionDetalle, CotizacionDetalleDto, CotizacionDetalleResponse> service,
            GenericService<VwCotizacionDetalle, CotizacionDetalleDto, CotizacionDetalleResponse> serviceView)
            : base(
                service,
                serviceView,
                "PkidCotizacionDetalle",
                "Detalle de cotizacion",
                (dto, id) => dto.PkidCotizacionDetalle = id)
        {
        }

        public override async Task<PagedResult<CotizacionDetalleResponse>> CreateAsync(
            CotizacionDetalleResponse response,
            int usuarioActual)
        {
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
            if (ExistsDuplicate(response.FkidCotizacionOrco, response.FkidRequisicionDetalleOrco, id))
            {
                return DuplicateResult("Ya existe otro renglon activo con el mismo bien en esta cotizacion.");
            }

            return await base.UpdateAsync(id, response, usuarioActual);
        }

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
