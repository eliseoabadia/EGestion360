using AutoMapper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class TipoDetallePolizaMappingProfile : Profile
    {
        public TipoDetallePolizaMappingProfile()
        {
            CreateMap<TipoDetallePoliza, TipoDetallePolizaDto>().ReverseMap();
            CreateMap<TipoDetallePoliza, TipoDetallePolizaResponse>();
            CreateMap<TipoDetallePolizaResponse, TipoDetallePolizaDto>()
                .ForMember(dest => dest.PkidTipoDetallePoliza, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
