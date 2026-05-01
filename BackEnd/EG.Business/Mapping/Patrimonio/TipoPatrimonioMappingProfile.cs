using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class TipoPatrimonioMappingProfile : Profile
    {
        public TipoPatrimonioMappingProfile()
        {
            CreateMap<TipoPatrimonio, TipoPatrimonioDto>().ReverseMap();
            CreateMap<TipoPatrimonioResponse, TipoPatrimonioDto>()
                .ForMember(dest => dest.PkidTipoPatrimonio, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
