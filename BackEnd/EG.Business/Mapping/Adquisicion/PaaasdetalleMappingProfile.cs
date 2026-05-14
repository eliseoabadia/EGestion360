using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class PaaasdetalleMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Paaasdetalle, PaaasdetalleResponse>()
                .Map(dest => dest.TipoBienCodigoClave, src => src.FkidTipoBienAlmaNavigation != null ? src.FkidTipoBienAlmaNavigation.CodigoClave : string.Empty)
                .Map(dest => dest.TipoBienDescripcion, src => src.FkidTipoBienAlmaNavigation != null ? src.FkidTipoBienAlmaNavigation.CodigoClave + " - " + src.FkidTipoBienAlmaNavigation.Descripcion : string.Empty)
                .Map(dest => dest.Unidad, src => src.FkidUnidadesAlmaNavigation != null ? src.FkidUnidadesAlmaNavigation.Descripcion : string.Empty)
                .TwoWays();

            config.NewConfig<VwPaaasdetalle, PaaasdetalleResponse>()
                .Map(dest => dest.TipoBienCodigoClave, src => src.TipoBienCodigoClave ?? string.Empty)
                .Map(dest => dest.TipoBienDescripcion, src => src.BienClaveNombre ?? string.Empty)
                .Map(dest => dest.Unidad, src => src.UnidadMedida ?? string.Empty);

            config.NewConfig<PaaasdetalleDto, Paaasdetalle>()
                .Ignore(dest => dest.PkidPaaasdetalle)
                .Ignore(dest => dest.FechaCreacion)
                .Ignore(dest => dest.UsuarioCreacion)
                .Ignore(dest => dest.FechaModificacion)
                .Ignore(dest => dest.UsuarioModificacion)
                .Ignore(dest => dest.EstudioMercadoDetalles)
                .Ignore(dest => dest.FkidEmpresaSisNavigation)
                .Ignore(dest => dest.FkidPaaaspartidaOrcoNavigation)
                .Ignore(dest => dest.FkidTipoBienAlmaNavigation)
                .Ignore(dest => dest.FkidUnidadesAlmaNavigation);
        }
    }
}
