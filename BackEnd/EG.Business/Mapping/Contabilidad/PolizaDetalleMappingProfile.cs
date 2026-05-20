using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.Contabilidad
{
    public class PolizaDetalleMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<PolizaDetalle, PolizaDetalleDto>().TwoWays();
            config.NewConfig<PolizaDetalle, PolizaDetalleResponse>();
            config.NewConfig<VwPolizaDetalle, PolizaDetalleResponse>();
            config.NewConfig<PolizaDetalleResponse, PolizaDetalleDto>()
                .Ignore(dest => dest.PkidPolizaDetalle)
                .IgnoreNullValues(true);
        }
    }
}
