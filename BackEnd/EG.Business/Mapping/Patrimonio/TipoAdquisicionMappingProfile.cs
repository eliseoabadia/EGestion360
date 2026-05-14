using Mapster;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class TipoAdquisicionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoAdquisicion, TipoAdquisicionDto>().TwoWays();
            config.NewConfig<TipoAdquisicion, TipoAdquisicionResponse>().TwoWays();
            config.NewConfig<TipoAdquisicionResponse, TipoAdquisicionDto>()
                .Ignore(dest => dest.PkidTipoAdq)
                .IgnoreNullValues(true);
        }
    }
}
