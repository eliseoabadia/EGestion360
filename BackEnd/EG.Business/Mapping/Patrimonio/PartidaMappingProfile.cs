using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class PartidaMappingProfile : Profile
    {
        public PartidaMappingProfile()
        {
            CreateMap<Partidum, PartidaDto>().ReverseMap();
            CreateMap<Partidum, PartidaResponse>()
                .ForMember(dest => dest.ConceptoDescripcion, opt => opt.MapFrom(src => src.FkidConceptoSisNavigation != null ? src.FkidConceptoSisNavigation.Descripcion : null));
            CreateMap<PartidaResponse, PartidaDto>();
        }
    }
}
