using AutoMapper;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoDoctoClcMappingProfile : Profile
    {
        public TipoDoctoClcMappingProfile()
        {
            CreateMap<TipoDoctoClc, TipoDoctoClcDto>().ReverseMap();
            CreateMap<TipoDoctoClc, TipoDoctoClcResponse>().ReverseMap();
            CreateMap<TipoDoctoClcResponse, TipoDoctoClcDto>()
                .ForMember(dest => dest.PkidTipoDoctoClc, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
