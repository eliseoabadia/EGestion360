using Mapster;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class MatrizConversionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
config.NewConfig<MatrizConversion, MatrizConversionDto>().TwoWays();
config.NewConfig<MatrizConversion, MatrizConversionResponse>()
    .Map(dest => dest.ProgramaClave, src => src.FkidProgramaPresNavigation.Clave)
    .Map(dest => dest.PartidaDescripcion, src => src.FkidPartidaSisNavigation.Descripcion)
    .Map(dest => dest.CuentaAprobadoNombre, src => src.FkidCuentaContableAprobadoNavigation.Cuenta + " - " + src.FkidCuentaContableAprobadoNavigation.Descripcion)
    .Map(dest => dest.CuentaPorEjercerNombre, src => src.FkidCuentaContablePorEjercerNavigation.Cuenta + " - " + src.FkidCuentaContablePorEjercerNavigation.Descripcion)
    .Map(dest => dest.CuentaModificadoNombre, src => src.FkidCuentaContableModificadoNavigation.Cuenta + " - " + src.FkidCuentaContableModificadoNavigation.Descripcion)
    .Map(dest => dest.CuentaComprometidoNombre, src => src.FkidCuentaContableComprometidoNavigation.Cuenta + " - " + src.FkidCuentaContableComprometidoNavigation.Descripcion)
    .Map(dest => dest.CuentaDevengadoNombre, src => src.FkidCuentaContableDevengadoNavigation.Cuenta + " - " + src.FkidCuentaContableDevengadoNavigation.Descripcion)
    .Map(dest => dest.CuentaEjercidoNombre, src => src.FkidCuentaContableEjercidoNavigation.Cuenta + " - " + src.FkidCuentaContableEjercidoNavigation.Descripcion)
    .Map(dest => dest.CuentaPagadoNombre, src => src.FkidCuentaContablePagadoNavigation.Cuenta + " - " + src.FkidCuentaContablePagadoNavigation.Descripcion)
    .Map(dest => dest.CuentaGastoNombre, src => src.FkidCuentaContableGastoNavigation.Cuenta + " - " + src.FkidCuentaContableGastoNavigation.Descripcion);
config.NewConfig<MatrizConversionResponse, MatrizConversionDto>()
    .Ignore(dest => dest.PkidMatrizConversion)
    .IgnoreNullValues(true);
        }
    }
}
