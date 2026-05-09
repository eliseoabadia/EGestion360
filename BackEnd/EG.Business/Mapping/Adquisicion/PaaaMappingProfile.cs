using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class PaaaMappingProfile : Profile
    {
        public PaaaMappingProfile()
        {
            CreateMap<Paaa, PaaaDto>().ReverseMap();

            CreateMap<VwPaaa, PaaaResponse>();

            CreateMap<PaaaResponse, PaaaDto>()
                .ForMember(dest => dest.PkidPaaas, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
