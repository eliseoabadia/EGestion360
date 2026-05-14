using Mapster;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoInversionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoInversion, TipoInversionDto>().TwoWays();
            config.NewConfig<TipoInversion, TipoInversionResponse>().TwoWays();
            config.NewConfig<TipoInversionResponse, TipoInversionDto>()
                .Ignore(dest => dest.PkidTipoInversion)
                .IgnoreNullValues(true);
        }
    }
}
