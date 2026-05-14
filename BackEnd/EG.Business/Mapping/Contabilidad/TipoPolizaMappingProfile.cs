using Mapster;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class TipoPolizaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoPoliza, TipoPolizaDto>().TwoWays();
            config.NewConfig<TipoPoliza, TipoPolizaResponse>();
            config.NewConfig<TipoPolizaResponse, TipoPolizaDto>()
                .Ignore(dest => dest.PkidTipoPoliza)
                .IgnoreNullValues(true);
        }
    }
}
