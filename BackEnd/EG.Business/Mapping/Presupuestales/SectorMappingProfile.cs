using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class SectorMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Sector, SectorDto>().TwoWays();
            config.NewConfig<Sector, SectorResponse>();
            config.NewConfig<SectorResponse, SectorDto>()
                .Ignore(dest => dest.PkidSector)
                .IgnoreNullValues(true);
        }
    }
}
