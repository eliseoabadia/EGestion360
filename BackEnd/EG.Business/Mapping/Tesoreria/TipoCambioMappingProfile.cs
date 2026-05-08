using AutoMapper;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoCambioMappingProfile : Profile
    {
        public TipoCambioMappingProfile()
        {
            CreateMap<TipoCambio, TipoCambioDto>().ReverseMap();
            CreateMap<VwTipoCambio, TipoCambioResponse>();
            CreateMap<TipoCambio, TipoCambioResponse>();
            CreateMap<TipoCambioResponse, TipoCambioDto>()
                .ForMember(dest => dest.PkidTipoCambio, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
