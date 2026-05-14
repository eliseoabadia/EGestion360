using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class TipoGarantiaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoGarantium, TipoGarantiaDto>().TwoWays();
            config.NewConfig<TipoGarantium, TipoGarantiaResponse>();
            config.NewConfig<TipoGarantiaResponse, TipoGarantiaDto>()
                .Ignore(dest => dest.PkidTipoGarantia)
                .IgnoreNullValues(true);
        }
    }
}