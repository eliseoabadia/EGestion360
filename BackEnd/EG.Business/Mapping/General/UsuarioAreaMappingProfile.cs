using Mapster;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General;

public class UsuarioAreaMappingProfile : IRegister
{
    public void Register(TypeAdapterConfig config){
        config.NewConfig<VwUsuarioPersonaArea, UsuarioAreaResponse>()
            .Map(dest => dest.PkidArea, src => src.PkidArea ?? 0)
            .Map(dest => dest.UsuarioAreaDescripcion, src => src.UsuarioAreaDescripcion ?? string.Empty);
    }
}
