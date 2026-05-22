using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class CotizacionAppService
        : AdquisicionCrudAppService<Cotizacion, VwCotizacion, CotizacionDto, CotizacionResponse>,
            ICotizacionAppService
    {
        public CotizacionAppService(
            GenericService<Cotizacion, CotizacionDto, CotizacionResponse> service,
            GenericService<VwCotizacion, CotizacionDto, CotizacionResponse> serviceView)
            : base(
                service,
                serviceView,
                "PkidCotizacion",
                "Cotizacion",
                (dto, id) => dto.PkidCotizacion = id)
        {
        }
    }
}
