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
                .Map(dest => dest.FechaResguardo, src => src.FechaResguardo.ToDateTime(TimeOnly.MinValue));
            config.NewConfig<VwResguardo, ResguardoResponse>()
                .Map(dest => dest.FechaResguardo, src => src.FechaResguardo.ToDateTime(TimeOnly.MinValue));
            config.NewConfig<ResguardoResponse, ResguardoDto>().IgnoreNullValues(true);
            config.NewConfig<ResguardoDto, Resguardo>()
                .Ignore(dest => dest.PkidResguardo)
                .Map(dest => dest.FechaResguardo, src => DateOnly.FromDateTime(src.FechaResguardo));

            config.NewConfig<ResguardoDetalle, ResguardoDetalleResponse>();
            config.NewConfig<VwResguardoDetalle, ResguardoDetalleResponse>();
            config.NewConfig<ResguardoDetalleResponse, ResguardoDetalleDto>().IgnoreNullValues(true);
            config.NewConfig<ResguardoDetalleDto, ResguardoDetalle>()
                .Ignore(dest => dest.PkidResguardoDetalle);
        }
    }
}
