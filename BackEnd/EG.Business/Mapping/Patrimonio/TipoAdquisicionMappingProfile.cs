using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class TipoAdquisicionMappingProfile : Profile
    {
        public TipoAdquisicionMappingProfile()
        {
            CreateMap<TipoAdquisicion, TipoAdquisicionDto>().ReverseMap();
            CreateMap<TipoAdquisicionResponse, TipoAdquisicionDto>()
                .ForMember(dest => dest.PkidTipoAdq, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
