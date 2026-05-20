using Mapster;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class TipoDetallePolizaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoDetallePoliza, TipoDetallePolizaDto>()
                .Map(dest => dest.PkidTipoDetallePoliza, src => src.PkIdTipoDetallePoliza);

            config.NewConfig<TipoDetallePolizaDto, TipoDetallePoliza>()
                .Map(dest => dest.PkIdTipoDetallePoliza, src => src.PkidTipoDetallePoliza);

            config.NewConfig<TipoDetallePoliza, TipoDetallePolizaResponse>()
                .Map(dest => dest.PkidTipoDetallePoliza, src => src.PkIdTipoDetallePoliza);

            config.NewConfig<TipoDetallePolizaResponse, TipoDetallePolizaDto>()
                .Ignore(dest => dest.PkidTipoDetallePoliza)
                .IgnoreNullValues(true);
        }
    }
}
