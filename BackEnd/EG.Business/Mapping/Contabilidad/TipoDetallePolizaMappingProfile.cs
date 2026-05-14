using Mapster;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class TipoDetallePolizaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoDetallePoliza, TipoDetallePolizaDto>().TwoWays();
            config.NewConfig<TipoDetallePoliza, TipoDetallePolizaResponse>();
            config.NewConfig<TipoDetallePolizaResponse, TipoDetallePolizaDto>()
                .Ignore(dest => dest.PkidTipoDetallePoliza)
                .IgnoreNullValues(true);
        }
    }
}
