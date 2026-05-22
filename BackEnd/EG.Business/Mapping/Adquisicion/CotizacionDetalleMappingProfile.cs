using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class CotizacionDetalleMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<CotizacionDetalle, CotizacionDetalleResponse>();
            config.NewConfig<VwCotizacionDetalle, CotizacionDetalleResponse>();
            config.NewConfig<CotizacionDetalleResponse, CotizacionDetalleDto>().IgnoreNullValues(true);

            config.NewConfig<CotizacionDetalleDto, CotizacionDetalle>()
                .Ignore(dest => dest.PkidCotizacionDetalle);
        }
    }
}
