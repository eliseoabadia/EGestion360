using Mapster;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class TipoPatrimonioMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoPatrimonio, TipoPatrimonioDto>().TwoWays();
            config.NewConfig<TipoPatrimonio, TipoPatrimonioResponse>().TwoWays();
            config.NewConfig<TipoPatrimonioResponse, TipoPatrimonioDto>()
                .Ignore(dest => dest.PkidTipoPatrimonio)
                .IgnoreNullValues(true);
        }
    }
}
