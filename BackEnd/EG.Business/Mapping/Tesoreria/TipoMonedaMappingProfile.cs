using Mapster;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoMonedaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoMonedum, TipoMonedaDto>().TwoWays();
            config.NewConfig<TipoMonedum, TipoMonedaResponse>()
                .Map(dest => dest.PaisNombre, src => src.FkidPaisSisNavigation != null ? src.FkidPaisSisNavigation.Nombre : string.Empty)
                .TwoWays();
            config.NewConfig<TipoMonedaResponse, TipoMonedaDto>()
                .Ignore(dest => dest.PkidTipoMoneda)
                .IgnoreNullValues(true);
        }
    }
}
