using AutoMapper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class ConceptoMappingProfile : Profile
    {
        public ConceptoMappingProfile()
        {
            CreateMap<Concepto, ConceptoDto>().ReverseMap();
            CreateMap<Concepto, ConceptoResponse>();
            CreateMap<ConceptoResponse, ConceptoDto>()
                .ForMember(dest => dest.PkidConcepto, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
