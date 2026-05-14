using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class PaaaspartidumMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Paaaspartidum, PaaaspartidumResponse>()
                .Map(dest => dest.FkidPaaas, src => src.FkidPaaasOrco)
                .Map(dest => dest.FkidPaaasOrco, src => src.FkidPaaasOrco)
                .Map(dest => dest.ClavePartida, src => src.FkidPartidaContaNavigation != null ? src.FkidPartidaContaNavigation.Clave : src.FkidPartidaConta.ToString())
                .Map(dest => dest.Descripcion, src => src.FkidPartidaContaNavigation != null ? src.FkidPartidaContaNavigation.Descripcion : string.Empty)
                .Map(dest => dest.Observaciones, src => src.Observaciones ?? string.Empty)
                .Map(dest => dest.Monto, src => 0m)
                .Map(dest => dest.Cantidad, src => src.Paaasdetalles.Count(d => d.Activo))
                .Map(dest => dest.Unidad, src => string.Empty)
                .TwoWays();

            config.NewConfig<VwPaaaspartidum, PaaaspartidumResponse>()
                .Map(dest => dest.FkidPaaas, src => src.FkidPaaasOrco)
                .Map(dest => dest.FkidPaaasOrco, src => src.FkidPaaasOrco)
                .Map(dest => dest.ClavePartida, src => src.PartidaClave ?? string.Empty)
                .Map(dest => dest.Descripcion, src => src.PartidaDescripcion ?? string.Empty)
                .Map(dest => dest.Observaciones, src => src.Observaciones ?? string.Empty)
                .Map(dest => dest.Monto, src => 0m)
                .Map(dest => dest.Cantidad, src => 0)
                .Map(dest => dest.Unidad, src => string.Empty);

            config.NewConfig<PaaaspartidaDto, Paaaspartidum>()
                .Ignore(dest => dest.PkidPaaaspartida)
                .Ignore(dest => dest.FechaCreacion)
                .Ignore(dest => dest.UsuarioCreacion)
                .Ignore(dest => dest.FechaModificacion)
                .Ignore(dest => dest.UsuarioModificacion)
                .Ignore(dest => dest.FkidEmpresaSisNavigation)
                .Ignore(dest => dest.FkidPaaasOrcoNavigation)
                .Ignore(dest => dest.FkidPartidaContaNavigation)
                .Ignore(dest => dest.Paaasdetalles);
        }
    }
}
