using Mapster;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoCambioMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoCambio, TipoCambioDto>().TwoWays();
            config.NewConfig<VwTipoCambio, TipoCambioResponse>();
            config.NewConfig<TipoCambio, TipoCambioResponse>();
            config.NewConfig<TipoCambioResponse, TipoCambioDto>()
                .Ignore(dest => dest.PkidTipoCambio)
                .IgnoreNullValues(true);
        }
    }
}
