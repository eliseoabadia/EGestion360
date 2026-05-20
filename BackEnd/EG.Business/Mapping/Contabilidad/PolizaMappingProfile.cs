using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.Contabilidad
{
    public class PolizaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Poliza, PolizaDto>().TwoWays();
            config.NewConfig<Poliza, PolizaResponse>();
            config.NewConfig<VwPoliza, PolizaResponse>();
            config.NewConfig<PolizaResponse, PolizaDto>()
                .Ignore(dest => dest.PkidPoliza)
                .IgnoreNullValues(true);
        }
    }
}
