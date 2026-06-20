using EG.Domain.DTOs.Requests.PresupuestoModificado;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.PresupuestoModificado
{
    public class PresupuestoModificadoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<EgreAdecuacion, EgreAdecuacionDto>().TwoWays();
            config.NewConfig<VwEgresoAdecuacion, EgreAdecuacionResponse>().TwoWays();
            config.NewConfig<EgreAdecuacionResponse, EgreAdecuacionDto>().TwoWays();

            config.NewConfig<EgreAdecuacionDetalle, EgreAdecuacionDetalleDto>().TwoWays();
            config.NewConfig<VwEgresoAdecuacionDetalle, EgreAdecuacionDetalleResponse>().TwoWays();
            config.NewConfig<EgreAdecuacionDetalleResponse, EgreAdecuacionDetalleDto>().TwoWays();

            config.NewConfig<TipoAdecuacion, TipoAdecuacionDto>().TwoWays();
            config.NewConfig<TipoAdecuacion, TipoAdecuacionResponse>().TwoWays();
            config.NewConfig<TipoAdecuacionResponse, TipoAdecuacionDto>().TwoWays();

            config.NewConfig<EstatusAdecuacion, EstatusAdecuacionDto>().TwoWays();
            config.NewConfig<EstatusAdecuacion, EstatusAdecuacionResponse>().TwoWays();
            config.NewConfig<EstatusAdecuacionResponse, EstatusAdecuacionDto>().TwoWays();

            config.NewConfig<TipoMovimiento, TipoMovimientoDto>().TwoWays();
            config.NewConfig<TipoMovimiento, TipoMovimientoResponse>().TwoWays();
            config.NewConfig<TipoMovimientoResponse, TipoMovimientoDto>().TwoWays();

            config.NewConfig<VwEgresoDisponible, EgresoDisponibleResponse>().TwoWays();
            config.NewConfig<EgresoDisponibleResponse, EgresoDisponibleDto>().TwoWays();

            config.NewConfig<IngreAdecuacion, IngreAdecuacionDto>().TwoWays();
            config.NewConfig<VwIngresoAdecuacion, IngreAdecuacionResponse>().TwoWays();
            config.NewConfig<IngreAdecuacionResponse, IngreAdecuacionDto>().TwoWays();

            config.NewConfig<IngreAdecuacionDetalle, IngreAdecuacionDetalleDto>().TwoWays();
            config.NewConfig<VwIngresoAdecuacionDetalle, IngreAdecuacionDetalleResponse>().TwoWays();
            config.NewConfig<IngreAdecuacionDetalleResponse, IngreAdecuacionDetalleDto>().TwoWays();

            config.NewConfig<VwIngresoDisponible, IngresoDisponibleResponse>().TwoWays();
            config.NewConfig<IngresoDisponibleResponse, IngresoDisponibleDto>().TwoWays();
        }
    }
}
