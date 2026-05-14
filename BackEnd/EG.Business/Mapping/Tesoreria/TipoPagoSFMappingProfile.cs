using Mapster;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoPagoSFMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoPagoSf, TipoPagoSFDto>().TwoWays();
            config.NewConfig<TipoPagoSf, TipoPagoSFResponse>().TwoWays();
            config.NewConfig<TipoPagoSFResponse, TipoPagoSFDto>()
                .Ignore(dest => dest.PkidTipoPagoSf)
                .IgnoreNullValues(true);
        }
    }
}
