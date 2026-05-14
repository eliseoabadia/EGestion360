using Mapster;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoDoctoClcMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoDoctoClc, TipoDoctoClcDto>().TwoWays();
            config.NewConfig<TipoDoctoClc, TipoDoctoClcResponse>().TwoWays();
            config.NewConfig<TipoDoctoClcResponse, TipoDoctoClcDto>()
                .Ignore(dest => dest.PkidTipoDoctoClc)
                .IgnoreNullValues(true);
        }
    }
}
