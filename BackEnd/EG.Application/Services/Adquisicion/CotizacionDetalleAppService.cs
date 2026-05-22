using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
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
    }
}
