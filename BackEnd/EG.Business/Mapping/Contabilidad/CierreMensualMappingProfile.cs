using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.Contabilidad
{
    public class CierreMensualMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<SaldoMensual, CierreMensualResponse>()
                .Map(dest => dest.PkidSaldoMensual, src => src.PkidSaldoMensual)
                .Map(dest => dest.FkidAnioSis, src => src.FkidAnioSis)
                .Map(dest => dest.Anio, src => src.FkidAnioSisNavigation != null ? src.FkidAnioSisNavigation.Clave : src.FkidAnioSis)
                .Map(dest => dest.FkidMesSis, src => src.FkidMesSis)
                .Map(dest => dest.FkidCuentaContable, src => src.FkidCuentaContable)
                .Map(dest => dest.FkidEmpresaSis, src => src.FkidCuentaContableNavigation != null ? src.FkidCuentaContableNavigation.FkidEmpresaSis : 0)
                .Map(dest => dest.CuentaClave, src => src.FkidCuentaContableNavigation != null ? src.FkidCuentaContableNavigation.ClaveOrd : string.Empty)
                .Map(dest => dest.CuentaDescripcion, src => src.FkidCuentaContableNavigation != null ? src.FkidCuentaContableNavigation.Descripcion : string.Empty)
                .Map(dest => dest.CuentaClaveNombre, src => src.FkidCuentaContableNavigation != null ? src.FkidCuentaContableNavigation.ClaveOrd + " " + src.FkidCuentaContableNavigation.Descripcion : string.Empty)
                .Map(dest => dest.SaldoInicial, src => src.SaldoInicial ?? 0m)
                .Map(dest => dest.Cargos, src => src.Cargos ?? 0m)
                .Map(dest => dest.Abonos, src => src.Abonos ?? 0m)
                .Map(dest => dest.SaldoFinal, src => src.SaldoFinal ?? 0m);
        }
    }
}
