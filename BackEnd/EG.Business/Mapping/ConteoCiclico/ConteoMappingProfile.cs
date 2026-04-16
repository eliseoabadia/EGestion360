using AutoMapper;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico;

public class ConteoMappingProfile : Profile
{
    public ConteoMappingProfile()
    {
        // Entity ↔ DTO
        CreateMap<Conteo, ConteoDto>().ReverseMap()
            .ForMember(dest => dest.FkidPeriodoConteoAlmaNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidTipoBienAlmaNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.UsuarioCreacionNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.UsuarioModificacionNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.ConteoDetalleEscaneos, opt => opt.Ignore())
            .ForMember(dest => dest.ConteoDetalles, opt => opt.Ignore());

        // Vista → Response
        CreateMap<VwConteo, ConteoResponse>();

        // Response → DTO
        CreateMap<ConteoResponse, ConteoDto>()
            .ForMember(dest => dest.FkidTipoBienAlma, opt => opt.MapFrom(src => src.IdTipoBien ?? 0))
            .ForMember(dest => dest.FkidPeriodoConteoAlma, opt => opt.MapFrom(src => src.IdPeriodoConteo))
            .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
    }
}
