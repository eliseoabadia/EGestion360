using Mapster;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico;

public class ConteoDetalleEscaneoMappingProfile : IRegister
{
    public void Register(TypeAdapterConfig config){
        // Entity ↔ DTO (using ConteoDto for simplicity since ConteoDetalleEscaneo shares write model)
        config.NewConfig<ConteoDetalleEscaneo, ConteoDto>().TwoWays();

        // Vista → Response
        config.NewConfig<VwConteoDetalleEscaneo, ConteoDetalleEscaneoResponse>();
    }
}
