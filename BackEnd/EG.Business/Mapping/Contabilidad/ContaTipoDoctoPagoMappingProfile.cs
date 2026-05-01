using AutoMapper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class ContaTipoDoctoPagoMappingProfile : Profile
    {
        public ContaTipoDoctoPagoMappingProfile()
        {
            // Entity ↔ DTO
            CreateMap<TipoDoctoPago, ContaTipoDoctoPagoDto>().ReverseMap();
            
            // Response → DTO
            CreateMap<ContaTipoDoctoPagoResponse, ContaTipoDoctoPagoDto>()
                .ForMember(dest => dest.PkidTipoDoctoPago, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
