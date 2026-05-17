using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class EgresoAutorizadoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<EgresoAutorizado, EgresoAutorizadoResponse>();
            config.NewConfig<VwEgresoAutorizado, EgresoAutorizadoResponse>();
            config.NewConfig<EgresoAutorizadoResponse, EgresoAutorizadoDto>().IgnoreNullValues(true);

            config.NewConfig<EgresoAutorizadoDto, EgresoAutorizado>()
                .Ignore(dest => dest.PkidEgresoAutorizado)
                .Ignore(dest => dest.Total);
        }
    }
}
