using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class GrupoBienMappingProfile : Profile
    {
        public GrupoBienMappingProfile()
        {
            CreateMap<GrupoBien, GrupoBienDto>().ReverseMap();
            CreateMap<GrupoBienResponse, GrupoBienDto>()
                .ForMember(dest => dest.PkidGrupoBien, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
