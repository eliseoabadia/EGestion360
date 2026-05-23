using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class SolicitudSuficienciaDetalleMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<SolicitudSuficienciaDetalle, SolicitudSuficienciaDetalleResponse>();
            config.NewConfig<VwSolicitudSuficienciaDetalle, SolicitudSuficienciaDetalleResponse>();
            config.NewConfig<SolicitudSuficienciaDetalleResponse, SolicitudSuficienciaDetalleDto>().IgnoreNullValues(true);

            config.NewConfig<SolicitudSuficienciaDetalleDto, SolicitudSuficienciaDetalle>()
                .Ignore(dest => dest.PkidSolicitudSuficienciaDetalle)
                .Ignore(dest => dest.Total);
        }
    }
}
