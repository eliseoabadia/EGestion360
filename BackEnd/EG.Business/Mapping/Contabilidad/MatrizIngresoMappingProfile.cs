using Mapster;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class MatrizIngresoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<MatrizIngreso, MatrizIngresoDto>().TwoWays();
            config.NewConfig<MatrizIngreso, MatrizIngresoResponse>()
                .Map(dest => dest.ProgramaClave, src => src.FkIdProgramaNavigation.Clave)
                .Map(dest => dest.ProgramaDescripcion, src => src.FkIdProgramaNavigation.Descripcion)
                .Map(dest => dest.OrigenDescripcion, src => src.FkIdOrigenNavigation.Descripcion)
                .Map(dest => dest.CuentaAutorizadoNombre, src => src.FkIdCuentaContableAutorizadoNavigation != null ? src.FkIdCuentaContableAutorizadoNavigation.Cuenta + " - " + src.FkIdCuentaContableAutorizadoNavigation.Descripcion : null)
                .Map(dest => dest.CuentaPorEjecutarNombre, src => src.FkIdCuentaContablePorEjercerNavigation != null ? src.FkIdCuentaContablePorEjercerNavigation.Cuenta + " - " + src.FkIdCuentaContablePorEjercerNavigation.Descripcion : null)
                .Map(dest => dest.CuentaModificadoNombre, src => src.FkIdCuentaContableModificadoNavigation != null ? src.FkIdCuentaContableModificadoNavigation.Cuenta + " - " + src.FkIdCuentaContableModificadoNavigation.Descripcion : null)
                .Map(dest => dest.CuentaDevengadoNombre, src => src.FkIdCuentaContableDevengadoNavigation != null ? src.FkIdCuentaContableDevengadoNavigation.Cuenta + " - " + src.FkIdCuentaContableDevengadoNavigation.Descripcion : null)
                .Map(dest => dest.CuentaRecaudadoNombre, src => src.FkIdCuentaContableRecaudadoNavigation != null ? src.FkIdCuentaContableRecaudadoNavigation.Cuenta + " - " + src.FkIdCuentaContableRecaudadoNavigation.Descripcion : null)
                .Map(dest => dest.CuentaDepositoNombre, src => src.FkIdCuentaContableDepositoNavigation != null ? src.FkIdCuentaContableDepositoNavigation.Cuenta + " - " + src.FkIdCuentaContableDepositoNavigation.Descripcion : null);
            config.NewConfig<MatrizIngresoResponse, MatrizIngresoDto>()
                .Ignore(dest => dest.PkidMatrizIngreso)
                .IgnoreNullValues(true);
        }
    }
}
