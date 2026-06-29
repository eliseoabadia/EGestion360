using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.Adquisicion
{
    public class OrdenCompraMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<OrdenCompra, OrdenCompraResponse>()
                .Map(dest => dest.FechaOrdenCompra, src => src.FechaOrdenCompra.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaRequerida, src => ToDateTime(src.FechaRequerida))
                .Map(dest => dest.FechaEntrega, src => ToDateTime(src.FechaEntrega))
                .Map(dest => dest.FechaVigencia, src => ToDateTime(src.FechaVigencia))
                .Map(dest => dest.FechaCancelacion, src => ToDateTime(src.FechaCancelacion));

            config.NewConfig<VwOrdenCompra, OrdenCompraResponse>()
                .Map(dest => dest.FechaOrdenCompra, src => src.FechaOrdenCompra.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaRequerida, src => ToDateTime(src.FechaRequerida))
                .Map(dest => dest.FechaEntrega, src => ToDateTime(src.FechaEntrega))
                .Map(dest => dest.FechaVigencia, src => ToDateTime(src.FechaVigencia))
                .Map(dest => dest.FechaCancelacion, src => ToDateTime(src.FechaCancelacion));

            config.NewConfig<OrdenCompraResponse, OrdenCompraDto>().IgnoreNullValues(true);

            config.NewConfig<OrdenCompraDto, OrdenCompra>()
                .Ignore(dest => dest.PkidOrdenCompra)
                .Map(dest => dest.FechaOrdenCompra, src => DateOnly.FromDateTime(src.FechaOrdenCompra))
                .Map(dest => dest.FechaRequerida, src => ToDateOnly(src.FechaRequerida))
                .Map(dest => dest.FechaEntrega, src => ToDateOnly(src.FechaEntrega))
                .Map(dest => dest.FechaVigencia, src => ToDateOnly(src.FechaVigencia))
                .Map(dest => dest.FechaCancelacion, src => ToDateOnly(src.FechaCancelacion));

            config.NewConfig<OrdenCompraDetalle, OrdenCompraDetalleResponse>();
            config.NewConfig<VwOrdenCompraDetalle, OrdenCompraDetalleResponse>();
            config.NewConfig<OrdenCompraDetalleResponse, OrdenCompraDetalleDto>().IgnoreNullValues(true);
            config.NewConfig<OrdenCompraDetalleDto, OrdenCompraDetalle>()
                .Ignore(dest => dest.PkidOrdenCompraDetalle)
                .Ignore(dest => dest.CantidadPendiente)
                .Ignore(dest => dest.Importe)
                .Ignore(dest => dest.TotalDetalle);

            config.NewConfig<OrdenCompraPartidum, OrdenCompraPartidaResponse>();
            config.NewConfig<VwOrdenCompraPartidum, OrdenCompraPartidaResponse>();
            config.NewConfig<OrdenCompraPartidaResponse, OrdenCompraPartidaDto>().IgnoreNullValues(true);
            config.NewConfig<OrdenCompraPartidaDto, OrdenCompraPartidum>()
                .Ignore(dest => dest.PkidOrdenCompraPartida);

            config.NewConfig<VwOrdenCompraFromClasificacionBien, ClasificacionBienesMueblesResponse>()
                .Map(dest => dest.FechaOrdenCompra, src => src.FechaOrdenCompra.ToDateTime(TimeOnly.MinValue))
                .Map(dest => dest.FechaVigencia, src => ToDateTime(src.FechaVigencia));
            config.NewConfig<ClasificacionBienesMueblesResponse, ClasificacionBienesMueblesDto>().IgnoreNullValues(true);
        }

        private static DateTime? ToDateTime(DateOnly? value) =>
            value?.ToDateTime(TimeOnly.MinValue);

        private static DateOnly? ToDateOnly(DateTime? value) =>
            value.HasValue ? DateOnly.FromDateTime(value.Value) : null;
    }
}
