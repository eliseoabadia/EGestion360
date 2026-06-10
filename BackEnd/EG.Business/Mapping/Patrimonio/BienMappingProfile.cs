using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.Patrimonio
{
    public class BienMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Bien, BienResponse>();
            config.NewConfig<VwBien, BienResponse>();
            config.NewConfig<BienResponse, BienDto>().IgnoreNullValues(true);
            config.NewConfig<BienDto, Bien>().Ignore(dest => dest.PkidBien);

            config.NewConfig<Resguardo, ResguardoResponse>()
                .Map(dest => dest.FechaResguardo, src => src.Fecha.ToDateTime(TimeOnly.MinValue));
            config.NewConfig<VwResguardo, ResguardoResponse>()
                .Map(dest => dest.FechaResguardo, src => src.FechaResguardo.ToDateTime(TimeOnly.MinValue));
            config.NewConfig<ResguardoResponse, ResguardoDto>().IgnoreNullValues(true);
            config.NewConfig<ResguardoDto, Resguardo>()
                .Ignore(dest => dest.PkidResguardo)
                .Map(dest => dest.Fecha, src => DateOnly.FromDateTime(src.FechaResguardo));

            config.NewConfig<ResguardoDetalle, ResguardoDetalleResponse>();
            config.NewConfig<VwResguardoDetalle, ResguardoDetalleResponse>();
            config.NewConfig<ResguardoDetalleResponse, ResguardoDetalleDto>().IgnoreNullValues(true);
            config.NewConfig<ResguardoDetalleDto, ResguardoDetalle>()
                .Ignore(dest => dest.PkidResguardoDetalle);

            config.NewConfig<Baja, BajaResponse>()
                .Map(dest => dest.FechaSolicitud, src => src.FechaSolicitud.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaBaja, src => src.FechaBaja.HasValue ? src.FechaBaja.Value.ToDateTime(TimeOnly.MinValue) : (DateTime?)null)
                .Map(dest => dest.FechaReferencia, src => src.FechaReferencia.HasValue ? src.FechaReferencia.Value.ToDateTime(TimeOnly.MinValue) : (DateTime?)null);
            config.NewConfig<VwBaja, BajaResponse>()
                .Map(dest => dest.FechaSolicitud, src => src.FechaSolicitud.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaBaja, src => src.FechaBaja.HasValue ? src.FechaBaja.Value.ToDateTime(TimeOnly.MinValue) : (DateTime?)null)
                .Map(dest => dest.FechaReferencia, src => src.FechaReferencia.HasValue ? src.FechaReferencia.Value.ToDateTime(TimeOnly.MinValue) : (DateTime?)null);
            config.NewConfig<BajaResponse, BajaDto>().IgnoreNullValues(true);
            config.NewConfig<BajaDto, Baja>()
                .Ignore(dest => dest.PkidBaja)
                .Map(dest => dest.FechaSolicitud, src => DateOnly.FromDateTime(src.FechaSolicitud))
                .Map(dest => dest.FechaBaja, src => src.FechaBaja.HasValue ? DateOnly.FromDateTime(src.FechaBaja.Value) : (DateOnly?)null)
                .Map(dest => dest.FechaReferencia, src => src.FechaReferencia.HasValue ? DateOnly.FromDateTime(src.FechaReferencia.Value) : (DateOnly?)null);

            config.NewConfig<TipoBaja, TipoBajaResponse>();
            config.NewConfig<TipoBajaResponse, TipoBajaDto>().IgnoreNullValues(true);
            config.NewConfig<TipoBajaDto, TipoBaja>().Ignore(dest => dest.PkidTipoBaja);

            config.NewConfig<EstatusBaja, EstatusBajaResponse>();
            config.NewConfig<EstatusBajaResponse, EstatusBajaDto>().IgnoreNullValues(true);
            config.NewConfig<EstatusBajaDto, EstatusBaja>().Ignore(dest => dest.PkidEstatusBaja);

            config.NewConfig<VwBienesDisponiblesBaja, BienDisponibleBajaResponse>();

            config.NewConfig<CalendarioInventario, CalendarioInventarioResponse>()
                .Map(dest => dest.FechaInicio, src => src.FechaInicio.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaFin, src => src.FechaFin.ToDateTime(TimeOnly.MinValue));
            config.NewConfig<VwCalendarioInventario, CalendarioInventarioResponse>()
                .Map(dest => dest.FechaInicio, src => src.FechaInicio.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaFin, src => src.FechaFin.ToDateTime(TimeOnly.MinValue));
            config.NewConfig<CalendarioInventarioResponse, CalendarioInventarioDto>().IgnoreNullValues(true);
            config.NewConfig<CalendarioInventarioDto, CalendarioInventario>()
                .Ignore(dest => dest.PkidCalendarioInventario)
                .Map(dest => dest.FechaInicio, src => DateOnly.FromDateTime(src.FechaInicio))
                .Map(dest => dest.FechaFin, src => DateOnly.FromDateTime(src.FechaFin));

            config.NewConfig<Inventario, InventarioResponse>()
                .Map(dest => dest.FechaInventario, src => src.FechaInventario.ToDateTime(TimeOnly.MinValue));
            config.NewConfig<VwInventario, InventarioResponse>()
                .Map(dest => dest.FechaInventario, src => src.FechaInventario.ToDateTime(TimeOnly.MinValue));
            config.NewConfig<InventarioResponse, InventarioDto>().IgnoreNullValues(true);
            config.NewConfig<InventarioDto, Inventario>()
                .Ignore(dest => dest.PkidInventario)
                .Map(dest => dest.FechaInventario, src => DateOnly.FromDateTime(src.FechaInventario));

            config.NewConfig<InventarioDetalle, InventarioDetalleResponse>();
            config.NewConfig<VwInventarioDetalle, InventarioDetalleResponse>();
            config.NewConfig<InventarioDetalleResponse, InventarioDetalleDto>().IgnoreNullValues(true);
            config.NewConfig<InventarioDetalleDto, InventarioDetalle>()
                .Ignore(dest => dest.PkidInventarioDetalle);

            config.NewConfig<EstatusInventario, EstatusInventarioResponse>();
            config.NewConfig<EstatusInventarioResponse, EstatusInventarioDto>().IgnoreNullValues(true);
            config.NewConfig<EstatusInventarioDto, EstatusInventario>()
                .Ignore(dest => dest.PkidEstatusInventario);
        }
    }
}
