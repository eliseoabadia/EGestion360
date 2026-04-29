using AutoMapper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class TipoPolizaMappingProfile : Profile
    {
        public TipoPolizaMappingProfile()
        {
            CreateMap<TipoPoliza, TipoPolizaDto>().ReverseMap();
            CreateMap<TipoPoliza, TipoPolizaResponse>();
            CreateMap<TipoPolizaResponse, TipoPolizaDto>()
                .ForMember(dest => dest.PkidTipoPoliza, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
