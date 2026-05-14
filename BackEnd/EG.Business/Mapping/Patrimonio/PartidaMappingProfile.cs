using Mapster;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class PartidaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Partidum, PartidaDto>().TwoWays();
            config.NewConfig<Partidum, PartidaResponse>()
                .Map(dest => dest.ConceptoDescripcion, src => src.FkidConceptoSisNavigation != null ? src.FkidConceptoSisNavigation.Descripcion : null);
            config.NewConfig<PartidaResponse, PartidaDto>();
        }
    }
}
