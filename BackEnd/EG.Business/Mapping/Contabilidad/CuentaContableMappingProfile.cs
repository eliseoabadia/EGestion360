using Mapster;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class CuentaContableMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<CuentaContable, CuentaContableDto>().TwoWays();
            config.NewConfig<CuentaContable, CuentaContableResponse>();
            config.NewConfig<CuentaContableResponse, CuentaContableDto>()
                .Ignore(dest => dest.PkidCuentaContable)
                .IgnoreNullValues(true);
        }
    }
}
