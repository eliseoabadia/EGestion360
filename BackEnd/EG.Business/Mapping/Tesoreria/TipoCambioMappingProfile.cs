using Mapster;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoCambioMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoCambio, TipoCambioDto>().TwoWays();
            config.NewConfig<VwTipoCambio, TipoCambioResponse>();
            config.NewConfig<TipoCambio, TipoCambioResponse>()
                .Map(dest => dest.MonedaDescripcion, src => src.FkidTipoMonedaTesNavigation != null ? src.FkidTipoMonedaTesNavigation.Descripcion : string.Empty)
                .Map(dest => dest.MonedaCodigo, src => src.FkidTipoMonedaTesNavigation != null ? src.FkidTipoMonedaTesNavigation.CodigoIso4217 : string.Empty);
            config.NewConfig<TipoCambioResponse, TipoCambioDto>()
                .Ignore(dest => dest.PkidTipoCambio)
                .IgnoreNullValues(true);
        }
    }
}
