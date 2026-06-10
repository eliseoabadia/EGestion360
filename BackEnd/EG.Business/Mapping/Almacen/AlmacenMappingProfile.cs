using Mapster;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Almacen
{
    public class AlmacenMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // MotivoES
            config.NewConfig<Motivo, MotivoEsResponse>().TwoWays();
            config.NewConfig<Motivo, MotivoEsDto>().TwoWays();

            // Unidades
            config.NewConfig<Unidade, UnidadeResponse>().TwoWays();
            config.NewConfig<Unidade, UnidadeDto>().TwoWays();

            // EstatusSolicitud
            config.NewConfig<EstatusSolicitud, EstatusSolicitudResponse>().TwoWays();
            config.NewConfig<EstatusSolicitud, EstatusSolicitudDto>().TwoWays();

            config.NewConfig<EG.Infraestructure.Models.Almacen, AlmacenResponse>()
                .Map(dest => dest.FechaEntrada, src => src.FechaEntrada.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaCaducidad, src => src.FechaCaducidad.HasValue ? src.FechaCaducidad.Value.ToDateTime(TimeOnly.MinValue) : (DateTime?)null);
            config.NewConfig<VwAlmacen, AlmacenResponse>()
                .Map(dest => dest.FechaEntrada, src => src.FechaEntrada.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaCaducidad, src => src.FechaCaducidad.HasValue ? src.FechaCaducidad.Value.ToDateTime(TimeOnly.MinValue) : (DateTime?)null);
            config.NewConfig<AlmacenResponse, AlmacenDto>().IgnoreNullValues(true);
            config.NewConfig<AlmacenDto, EG.Infraestructure.Models.Almacen>()
                .Ignore(dest => dest.PkidAlmacen)
                .Map(dest => dest.FechaEntrada, src => DateOnly.FromDateTime(src.FechaEntrada))
                .Map(dest => dest.FechaCaducidad, src => src.FechaCaducidad.HasValue ? DateOnly.FromDateTime(src.FechaCaducidad.Value) : (DateOnly?)null);

            config.NewConfig<SolicitudSalidum, SolicitudSalidaResponse>()
                .Map(dest => dest.FechaSolicitud, src => src.FechaSolicitud.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaRequerida, src => src.FechaRequerida.HasValue ? src.FechaRequerida.Value.ToDateTime(TimeOnly.MinValue) : (DateTime?)null);
            config.NewConfig<VwSolicitudSalidum, SolicitudSalidaResponse>()
                .Map(dest => dest.FechaSolicitud, src => src.FechaSolicitud.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaRequerida, src => src.FechaRequerida.HasValue ? src.FechaRequerida.Value.ToDateTime(TimeOnly.MinValue) : (DateTime?)null);
            config.NewConfig<SolicitudSalidaResponse, SolicitudSalidaDto>().IgnoreNullValues(true);
            config.NewConfig<SolicitudSalidaDto, SolicitudSalidum>()
                .Ignore(dest => dest.PkidSolicitudSalida)
                .Map(dest => dest.FechaSolicitud, src => DateOnly.FromDateTime(src.FechaSolicitud))
                .Map(dest => dest.FechaRequerida, src => src.FechaRequerida.HasValue ? DateOnly.FromDateTime(src.FechaRequerida.Value) : (DateOnly?)null);

            config.NewConfig<DetalleSolicitudSalidum, DetalleSolicitudSalidaResponse>();
            config.NewConfig<VwDetalleSolicitudSalidum, DetalleSolicitudSalidaResponse>();
            config.NewConfig<DetalleSolicitudSalidaResponse, DetalleSolicitudSalidaDto>().IgnoreNullValues(true);
            config.NewConfig<DetalleSolicitudSalidaDto, DetalleSolicitudSalidum>()
                .Ignore(dest => dest.PkidDetalleSolicitudSalida);

            config.NewConfig<EstatusSolicitudSalidum, EstatusSolicitudSalidaResponse>();
            config.NewConfig<EstatusSolicitudSalidaResponse, EstatusSolicitudSalidaDto>().IgnoreNullValues(true);
            config.NewConfig<EstatusSolicitudSalidaDto, EstatusSolicitudSalidum>()
                .Ignore(dest => dest.PkidEstatusSolicitudSalida);

            // PeriodoConteo
            config.NewConfig<PeriodoConteo, PeriodoConteoResponse>().TwoWays();
            config.NewConfig<PeriodoConteo, PeriodoConteoDto>().TwoWays();
        }
    }
}
