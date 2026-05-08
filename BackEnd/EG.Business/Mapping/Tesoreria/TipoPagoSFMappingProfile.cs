using AutoMapper;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoPagoSFMappingProfile : Profile
    {
        public TipoPagoSFMappingProfile()
        {
            CreateMap<TipoPagoSf, TipoPagoSFDto>().ReverseMap();
            CreateMap<TipoPagoSf, TipoPagoSFResponse>().ReverseMap();
            CreateMap<TipoPagoSFResponse, TipoPagoSFDto>()
                .ForMember(dest => dest.PkidTipoPagoSf, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
