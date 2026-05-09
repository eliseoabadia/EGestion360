using AutoMapper;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General;

public class UsuarioAreaMappingProfile : Profile
{
    public UsuarioAreaMappingProfile()
    {
        CreateMap<VwUsuarioPersonaArea, UsuarioAreaResponse>()
            .ForMember(dest => dest.PkidArea, opt => opt.MapFrom(src => src.PkidArea ?? 0))
            .ForMember(dest => dest.UsuarioAreaDescripcion, opt => opt.MapFrom(src => src.UsuarioAreaDescripcion ?? string.Empty));
    }
}
