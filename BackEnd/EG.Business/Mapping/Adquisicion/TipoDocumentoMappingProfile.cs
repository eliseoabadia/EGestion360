using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class TipoDocumentoMappingProfile : Profile
    {
        public TipoDocumentoMappingProfile()
        {
            CreateMap<TipoDocumento, TipoDocumentoDto>().ReverseMap();
            CreateMap<TipoDocumento, TipoDocumentoResponse>();
            CreateMap<TipoDocumentoResponse, TipoDocumentoDto>()
                .ForMember(dest => dest.PkidTipoDocumento, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}