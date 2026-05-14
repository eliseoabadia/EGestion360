using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class ActividadInstitucionalMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<ActividadInstitucional, ActividadInstitucionalDto>().TwoWays();
            config.NewConfig<ActividadInstitucional, ActividadInstitucionalResponse>();
            config.NewConfig<ActividadInstitucionalResponse, ActividadInstitucionalDto>()
                .Ignore(dest => dest.PkidActividadInstitucional)
                .IgnoreNullValues(true);
        }
    }
}
