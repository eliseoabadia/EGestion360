using AutoMapper;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoPagoMappingProfile : Profile
    {
        public TipoPagoMappingProfile()
        {
            CreateMap<TipoPago, TipoPagoDto>().ReverseMap();
            CreateMap<TipoPago, TipoPagoResponse>().ReverseMap();
            CreateMap<TipoPagoResponse, TipoPagoDto>()
                .ForMember(dest => dest.PkidTipoPago, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
