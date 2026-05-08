using AutoMapper;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoMonedaMappingProfile : Profile
    {
        public TipoMonedaMappingProfile()
        {
            CreateMap<TipoMonedum, TipoMonedaDto>().ReverseMap();
            CreateMap<TipoMonedum, TipoMonedaResponse>().ReverseMap();
            CreateMap<TipoMonedaResponse, TipoMonedaDto>()
                .ForMember(dest => dest.PkidTipoMoneda, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
