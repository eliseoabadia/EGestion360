using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class SolicitudSuficienciaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<SolicitudSuficiencium, SolicitudSuficienciaResponse>();
            config.NewConfig<VwSolicitudSuficiencium, SolicitudSuficienciaResponse>();
            config.NewConfig<SolicitudSuficienciaResponse, SolicitudSuficienciaDto>().IgnoreNullValues(true);

            config.NewConfig<SolicitudSuficienciaDto, SolicitudSuficiencium>()
                .Ignore(dest => dest.PkidSolicitudSuficiencia);
        }
    }
}
