using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class EgresoProyectadoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<EgresoProyectado, EgresoProyectadoResponse>();
            config.NewConfig<VwEgresoProyectado, EgresoProyectadoResponse>();
            config.NewConfig<EgresoProyectadoResponse, EgresoProyectadoDto>().IgnoreNullValues(true);

            config.NewConfig<EgresoProyectadoDto, EgresoProyectado>()
                .Ignore(dest => dest.PkidEgresoProyectado)
                .Ignore(dest => dest.Total);
        }
    }
}
