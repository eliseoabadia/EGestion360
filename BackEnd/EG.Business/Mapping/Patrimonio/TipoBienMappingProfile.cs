using Mapster;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class TipoBienMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoBien, TipoBienDto>().TwoWays();
            config.NewConfig<TipoBien, TipoBienResponse>()
                .Map(dest => dest.TipoBienDescripcion, src => src.Descripcion)
                .Map(dest => dest.GrupoBienDescripcion, src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.Descripcion : null)
                .Map(dest => dest.GrupoBienClave, src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.Clave : null)
                .Map(dest => dest.ClaveAn, src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.ClaveAn : null)
                .Map(dest => dest.CabmAct, src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.CabmAct : null)
                .Map(dest => dest.ClaveCucop, src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.ClaveCucop : null)
                .Map(dest => dest.GrupoBienMedida, src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.Medida : null)
                .Ignore(dest => dest.FamiliaDescripcion)
                .Ignore(dest => dest.FamiliaClave)
                .Map(dest => dest.Nivel, src => src.FkidNivelAlmaNavigation != null ? src.FkidNivelAlmaNavigation.Nivel1 : (int?)null)
                .Map(dest => dest.NivelDescripcion, src => src.FkidNivelAlmaNavigation != null ? src.FkidNivelAlmaNavigation.Descripcion : null)
                .Ignore(dest => dest.PartidaClave)
                .Map(dest => dest.PartidaDescripcion, src => src.FkidPartidaContaNavigation != null ? src.FkidPartidaContaNavigation.Descripcion : null)
                .Map(dest => dest.CtaCoi, src => src.FkidCuentaContableContaNavigation != null ? src.FkidCuentaContableContaNavigation.CtaCoi : null)
                .Map(dest => dest.CuentaDescripcion, src => src.FkidCuentaContableContaNavigation != null ? src.FkidCuentaContableContaNavigation.Descripcion : null)
                .Map(dest => dest.TipoCuenta, src => src.FkidCuentaContableContaNavigation != null ? src.FkidCuentaContableContaNavigation.TipoCuenta : null)
                .Map(dest => dest.UnidadMedida, src => src.FkidUnidadesAlmaNavigation != null ? src.FkidUnidadesAlmaNavigation.Descripcion : null)
                .Map(dest => dest.UnidadEquivalenteMedida, src => src.FkidUnidadesEquivalenteNavigation != null ? src.FkidUnidadesEquivalenteNavigation.Descripcion : null);
            config.NewConfig<VwTipoBien, TipoBienDto>()
                .Map(dest => dest.Descripcion, src => src.TipoBienDescripcion)
                .Ignore(dest => dest.PkidTipoBien);
            config.NewConfig<VwTipoBien, TipoBienResponse>();
            config.NewConfig<TipoBienResponse, TipoBienDto>()
                .Ignore(dest => dest.PkidTipoBien)
                .Map(dest => dest.Descripcion, src => src.TipoBienDescripcion)
                .IgnoreNullValues(true);
        }
    }
}
