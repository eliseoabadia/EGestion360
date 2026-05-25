using EG.Domain.DTOs.Requests.PresupuestoComprometido;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.PresupuestoComprometido
{
    public class PresupuestoComprometidoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<AutorizacionSuficiencium, AutorizacionSuficienciaDto>().TwoWays();
            config.NewConfig<VwAutorizacionSuficiencium, AutorizacionSuficienciaResponse>().TwoWays();
            config.NewConfig<AutorizacionSuficienciaResponse, AutorizacionSuficienciaDto>().TwoWays();

            config.NewConfig<AutorizacionSuficienciaDetalle, AutorizacionSuficienciaDetalleDto>().TwoWays();
            config.NewConfig<VwAutorizacionSuficienciaDetalle, AutorizacionSuficienciaDetalleResponse>().TwoWays();
            config.NewConfig<AutorizacionSuficienciaDetalleResponse, AutorizacionSuficienciaDetalleDto>().TwoWays();
        }
    }
}
