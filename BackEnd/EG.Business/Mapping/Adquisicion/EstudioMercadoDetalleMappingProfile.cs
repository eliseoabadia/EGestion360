using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.Adquisicion
{
    public class EstudioMercadoDetalleMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<EstudioMercadoDetalle, EstudioMercadoDetalleDto>().TwoWays();
            config.NewConfig<EstudioMercadoDetalle, EstudioMercadoDetalleResponse>();
            config.NewConfig<VwEstudioMercadoDetalle, EstudioMercadoDetalleResponse>();
            config.NewConfig<EstudioMercadoDetalleResponse, EstudioMercadoDetalleDto>()
                .Ignore(dest => dest.PkidEstudioMercadoDetalle)
                .IgnoreNullValues(true);
        }
    }
}
