using Mapster;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoPagoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoPago, TipoPagoDto>().TwoWays();
            config.NewConfig<TipoPago, TipoPagoResponse>().TwoWays();
            config.NewConfig<TipoPagoResponse, TipoPagoDto>()
                .Ignore(dest => dest.PkidTipoPago)
                .IgnoreNullValues(true);
        }
    }
}
