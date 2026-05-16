using Mapster;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General;

public class UsuarioAreaMappingProfile : IRegister
{
    public void Register(TypeAdapterConfig config){
        config.NewConfig<VwUsuarioPersonaArea, UsuarioAreaResponse>()
            .Map(dest => dest.PkidPersona, src => src.PkidPersona ?? 0)
            .Map(dest => dest.PersonaClave, src => src.PersonaClave ?? string.Empty)
            .Map(dest => dest.PersonaNombre, src => src.PersonaNombre ?? string.Empty)
            .Map(dest => dest.PersonaPaterno, src => src.PersonaPaterno ?? string.Empty)
            .Map(dest => dest.PersonaMaterno, src => src.PersonaMaterno ?? string.Empty)
            .Map(dest => dest.EsSolicitante, src => src.EsSolicitante ?? false)
            .Map(dest => dest.PkidArea, src => src.PkidArea ?? 0)
            .Map(dest => dest.UsuarioAreaDescripcion, src => src.UsuarioAreaDescripcion ?? string.Empty);
    }
}
