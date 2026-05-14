using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General.Catalgos.ClavePrograma
{
    public class ClaveProgramaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // Mapeo bidireccional entre entidad y DTO
            config.NewConfig<Gf, GfDto>().TwoWays();

            // Mapeo bidireccional entre entidad y Response
            config.NewConfig<Gf, GfResponse>().TwoWays();

            // Mapeo directo entre DTO y Response (si alguna vez lo necesitas)
            config.NewConfig<GfDto, GfResponse>().TwoWays();
        }
    }
}
