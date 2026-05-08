using AutoMapper;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoInversionMappingProfile : Profile
    {
        public TipoInversionMappingProfile()
        {
            CreateMap<TipoInversion, TipoInversionDto>().ReverseMap();
            CreateMap<TipoInversion, TipoInversionResponse>().ReverseMap();
            CreateMap<TipoInversionResponse, TipoInversionDto>()
                .ForMember(dest => dest.PkidTipoInversion, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
