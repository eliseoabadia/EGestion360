using Mapster;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General;

public class UsuarioAreaMappingProfile : IRegister
{
    public void Register(TypeAdapterConfig config){
        config.NewConfig<VwUsuarioPersonaArea, UsuarioAreaResponse>()
            .Map(dest => dest.PkidPersonaArea, src => src.PkidPersonaArea)
            .Map(dest => dest.PkidPersona, src => src.PkidPersona ?? 0)
            .Map(dest => dest.PersonaClave, src => src.PersonaClave ?? string.Empty)
            .Map(dest => dest.PersonaNombre, src => src.PersonaNombre ?? string.Empty)
            .Map(dest => dest.PersonaPaterno, src => src.PersonaPaterno ?? string.Empty)
            .Map(dest => dest.PersonaMaterno, src => src.PersonaMaterno ?? string.Empty)
            .Map(dest => dest.IsAdscrito, src => src.IsAdscrito ?? false)
            .Map(dest => dest.EsSolicitante, src => src.EsSolicitante ?? false)
            .Map(dest => dest.EsAutorizador, src => src.EsAutorizador ?? false)
            .Map(dest => dest.PkidArea, src => src.PkidArea ?? 0)
            .Map(dest => dest.AreaClave, src => src.AreaClave ?? string.Empty)
            .Map(dest => dest.AreaNombre, src => src.AreaNombre ?? string.Empty)
            .Map(dest => dest.Activo, src => src.AreaActivo ?? false)
            .Map(dest => dest.UsuarioAreaDescripcion, src => src.UsuarioAreaDescripcion ?? string.Empty);
    }
}
