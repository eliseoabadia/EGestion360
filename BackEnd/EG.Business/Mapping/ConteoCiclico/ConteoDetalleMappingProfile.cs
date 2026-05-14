using Mapster;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico;

public class ConteoDetalleMappingProfile : IRegister
{
    public void Register(TypeAdapterConfig config){
        config.NewConfig<ConteoDetalle, ConteoDetalleDto>().TwoWays();

        config.NewConfig<VwBien, BienResponse>()
            .Map(dest => dest.PkidBien, src => src.PkidBien)
            .Map(dest => dest.Clave, src => src.Clave)
            .Map(dest => dest.ClaveAnt, src => src.ClaveAnt)
            .Map(dest => dest.Descripcion, src => src.Descripcion)
            .Map(dest => dest.Modelo, src => src.Modelo)
            .Map(dest => dest.Serie, src => src.Serie)
            .Map(dest => dest.Costo, src => src.Costo)
            .Map(dest => dest.FechaAdq, src => src.FechaAdq)
            .Map(dest => dest.Factura, src => src.Factura)
            .Map(dest => dest.Ubicacion, src => src.Ubicacion)
            .Map(dest => dest.Estatus, src => src.Estatus)
            .Map(dest => dest.Activo, src => src.Activo)
            .Map(dest => dest.GrupoBienDescripcion, src => src.GrupoBienDescripcion)
            .Map(dest => dest.GrupoBienClave, src => src.GrupoBienClave)
            .Map(dest => dest.TipoBienCodigoClave, src => src.TipoBienCodigoClave)
            .Map(dest => dest.TipoBienDescripcion, src => src.TipoBienDescripcion)
            .Map(dest => dest.MarcaDescripcion, src => src.MarcaDescripcion)
            .Map(dest => dest.EstadoBienDescripcionGeneral, src => src.EstadoBienDescripcionGeneral);
    }
}
