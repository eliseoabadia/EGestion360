using AutoMapper;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoSolicitudCLCMappingProfile : Profile
    {
        public TipoSolicitudCLCMappingProfile()
        {
            CreateMap<TipoSolicitudClc, TipoSolicitudCLCDto>().ReverseMap();
            CreateMap<TipoSolicitudClc, TipoSolicitudCLCResponse>().ReverseMap();
            CreateMap<TipoSolicitudCLCResponse, TipoSolicitudCLCDto>()
                .ForMember(dest => dest.PkidTipoSolicitudClc, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
