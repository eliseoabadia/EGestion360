using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class ProcedimientoContratacionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<ProcedimientoContratacion, ProcedimientoContratacionDto>().TwoWays();
            config.NewConfig<ProcedimientoContratacion, ProcedimientoContratacionResponse>();
            config.NewConfig<ProcedimientoContratacionResponse, ProcedimientoContratacionDto>()
                .Ignore(dest => dest.PkidProcedimientoContratacion)
                .IgnoreNullValues(true);
        }
    }
}