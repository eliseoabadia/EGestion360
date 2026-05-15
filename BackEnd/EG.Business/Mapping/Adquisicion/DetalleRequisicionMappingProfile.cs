using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class DetalleRequisicionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<DetalleRequisicion, DetalleRequisicionResponse>();
            config.NewConfig<VwDetalleRequisicion, DetalleRequisicionResponse>();
            config.NewConfig<DetalleRequisicionResponse, DetalleRequisicionDto>().IgnoreNullValues(true);

            config.NewConfig<DetalleRequisicionDto, DetalleRequisicion>()
                .Ignore(dest => dest.PkidDetalleRequisicion);
        }
    }
}
