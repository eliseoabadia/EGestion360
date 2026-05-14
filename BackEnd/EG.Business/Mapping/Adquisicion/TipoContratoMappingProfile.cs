using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class TipoContratoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoContrato, TipoContratoDto>().TwoWays();
            config.NewConfig<TipoContrato, TipoContratoResponse>();
            config.NewConfig<TipoContratoResponse, TipoContratoDto>()
                .Ignore(dest => dest.PkidTipoContrato)
                .IgnoreNullValues(true);
        }
    }
}