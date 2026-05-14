using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class RamoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Ramo, RamoDto>().TwoWays();
            config.NewConfig<Ramo, RamoResponse>();
            config.NewConfig<RamoResponse, RamoDto>()
                .Ignore(dest => dest.PkidRamo)
                .IgnoreNullValues(true);
        }
    }
}
