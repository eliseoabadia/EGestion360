using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class CotizacionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Cotizacion, CotizacionResponse>();
            config.NewConfig<VwCotizacion, CotizacionResponse>();
            config.NewConfig<CotizacionResponse, CotizacionDto>().IgnoreNullValues(true);

            config.NewConfig<CotizacionDto, Cotizacion>()
                .Ignore(dest => dest.PkidCotizacion);
        }
    }
}
