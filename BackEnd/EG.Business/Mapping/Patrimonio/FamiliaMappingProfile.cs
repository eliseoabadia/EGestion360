using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class FamiliaMappingProfile : Profile
    {
        public FamiliaMappingProfile()
        {
            CreateMap<Familium, FamiliaDto>().ReverseMap();
            CreateMap<Familium, FamiliaResponse>();
            CreateMap<FamiliaResponse, FamiliaDto>()
                .ForMember(dest => dest.PkidFamilia, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
