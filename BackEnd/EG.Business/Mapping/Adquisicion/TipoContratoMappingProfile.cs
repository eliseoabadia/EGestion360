using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class TipoContratoMappingProfile : Profile
    {
        public TipoContratoMappingProfile()
        {
            CreateMap<TipoContrato, TipoContratoDto>().ReverseMap();
            CreateMap<TipoContrato, TipoContratoResponse>();
            CreateMap<TipoContratoResponse, TipoContratoDto>()
                .ForMember(dest => dest.PkidTipoContrato, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}