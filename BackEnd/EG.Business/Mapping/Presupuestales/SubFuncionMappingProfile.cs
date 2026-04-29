using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class SubFuncionMappingProfile : Profile
    {
        public SubFuncionMappingProfile()
        {
            CreateMap<Sf, SubFuncionDto>().ReverseMap();
            CreateMap<Sf, SubFuncionResponse>();
            CreateMap<SubFuncionResponse, SubFuncionDto>()
                .ForMember(dest => dest.PkidSf, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
