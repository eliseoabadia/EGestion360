using Mapster;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico;

public class ConteoMappingProfile : IRegister
{
    public void Register(TypeAdapterConfig config){
        // Entity ↔ DTO
        config.NewConfig<Conteo, ConteoDto>().TwoWays();

        // Vista → Response
        config.NewConfig<VwConteo, ConteoResponse>();

        // Response → DTO
        config.NewConfig<ConteoResponse, ConteoDto>()
            .Map(dest => dest.FkidTipoBienAlma, src => src.IdTipoBien ?? 0)
            .Map(dest => dest.FkidPeriodoConteoAlma, src => src.IdPeriodoConteo)
            .IgnoreNullValues(true);
    }
}
