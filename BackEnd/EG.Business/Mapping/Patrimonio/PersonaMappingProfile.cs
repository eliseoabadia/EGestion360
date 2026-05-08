using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class PersonaMappingProfile : Profile
    {
        public PersonaMappingProfile()
        {
            CreateMap<Persona, PersonaDto>().ReverseMap();
            CreateMap<Persona, PersonaResponse>().ReverseMap();
            CreateMap<PersonaResponse, PersonaDto>()
                .ForMember(dest => dest.PkidPersona, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}