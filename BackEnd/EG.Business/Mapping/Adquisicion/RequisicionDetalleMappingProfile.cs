using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class RequisicionDetalleMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<RequisicionDetalle, RequisicionDetalleResponse>();
            config.NewConfig<VwRequisicionDetalle, RequisicionDetalleResponse>();
            config.NewConfig<RequisicionDetalleResponse, RequisicionDetalleDto>().IgnoreNullValues(true);

            config.NewConfig<RequisicionDetalleDto, RequisicionDetalle>()
                .Ignore(dest => dest.PkidRequisicionDetalle);
        }
    }
}
