using AutoMapper;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class FuncionMappingProfile : Profile
    {
        public FuncionMappingProfile()
        {
            CreateMap<Fn, FuncionDto>().ReverseMap();
            CreateMap<Fn, FuncionResponse>();
            CreateMap<FuncionResponse, FuncionDto>()
                .ForMember(dest => dest.PkidFn, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
