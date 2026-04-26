using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class TipoGarantiaMappingProfile : Profile
    {
        public TipoGarantiaMappingProfile()
        {
            CreateMap<TipoGarantium, TipoGarantiaDto>().ReverseMap();
            CreateMap<TipoGarantium, TipoGarantiaResponse>();
            CreateMap<TipoGarantiaResponse, TipoGarantiaDto>()
                .ForMember(dest => dest.PkidTipoGarantia, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}