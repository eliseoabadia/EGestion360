using Mapster;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class ContaTipoDoctoPagoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // Entity ↔ DTO
            config.NewConfig<TipoDoctoPago, ContaTipoDoctoPagoDto>().TwoWays();
            
            // Response → DTO
            config.NewConfig<ContaTipoDoctoPagoResponse, ContaTipoDoctoPagoDto>()
                .Ignore(dest => dest.PkidTipoDoctoPago)
                .IgnoreNullValues(true);
        }
    }
}
