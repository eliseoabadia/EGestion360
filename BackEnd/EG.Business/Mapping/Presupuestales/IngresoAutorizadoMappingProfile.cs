using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.Presupuestales
{
    public class IngresoAutorizadoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<IngresoAutorizado, IngresoAutorizadoResponse>();
            config.NewConfig<VwIngresoAutorizado, IngresoAutorizadoResponse>();
            config.NewConfig<IngresoAutorizadoResponse, IngresoAutorizadoDto>().IgnoreNullValues(true);
            config.NewConfig<IngresoAutorizadoDto, IngresoAutorizado>()
                .Ignore(dest => dest.PkidIngresoAutorizado)
                .Ignore(dest => dest.Total);
        }
    }
}
