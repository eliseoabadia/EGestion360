using AutoMapper;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class TipoBienMappingProfile : Profile
    {
        public TipoBienMappingProfile()
        {
            // Mapeo de entidad a DTO de respuesta
            CreateMap<TipoBien, TipoBienResponse>()
                .ForMember(dest => dest.CodigoArticulo, opt => opt.MapFrom(src => src.CodigoClave))
                .ForMember(dest => dest.DescripcionArticulo, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.UnidadMedida, opt => opt.MapFrom(src => src.FkidUnidadesAlmaNavigation.Descripcion))
                .ForMember(dest => dest.UnidadEquivalente, opt => opt.MapFrom(src => src.FkidUnidadesEquivalenteNavigation.Descripcion))
                .ForMember(dest => dest.CantidadEquivalente, opt => opt.MapFrom(src => src.CantidadEquivalente))
                .ForMember(dest => dest.Familia, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation.FkidFamiliaAlmaNavigation.Descripcion))
                .ForMember(dest => dest.GrupoBien, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation.Descripcion))
                .ForMember(dest => dest.Nivel, opt => opt.MapFrom(src => src.FkidNivelAlmaNavigation.Descripcion)) // Nota: typo en campo Descripcion de Nivel
                .ForMember(dest => dest.PartidaClave, opt => opt.MapFrom(src => src.FkidPartidaContaNavigation.Clave))
                .ForMember(dest => dest.PartidaDescripcion, opt => opt.MapFrom(src => src.FkidPartidaContaNavigation.Descripcion))
                .ForMember(dest => dest.CuentaCompleta, opt => opt.MapFrom(src =>
                    src.FkidCuentaContableContaNavigation.Cuenta + "." +
                    src.FkidCuentaContableContaNavigation.SubCuenta + "." +
                    src.FkidCuentaContableContaNavigation.SubSubCuenta + "." +
                    src.FkidCuentaContableContaNavigation.SubSubSubCuenta + "." +
                    src.FkidCuentaContableContaNavigation.SubSubSubSubCuenta))
                .ForMember(dest => dest.CuentaDescripcion, opt => opt.MapFrom(src => src.FkidCuentaContableContaNavigation.Descripcion))
                .ForMember(dest => dest.TipoCuenta, opt => opt.MapFrom(src => src.FkidCuentaContableContaNavigation.FkidTipoCuentaContaNavigation.Descripcion))
                .ForMember(dest => dest.ExistenciaMinima, opt => opt.MapFrom(src => src.ExistenciaMinima))
                .ForMember(dest => dest.ExistenciaMaxima, opt => opt.MapFrom(src => src.ExistenciaMaxima))
                .ForMember(dest => dest.Cabms, opt => opt.MapFrom(src => src.Cabms))
                .ForMember(dest => dest.CucopPlus, opt => opt.MapFrom(src => src.CucopPlus))
                .ForMember(dest => dest.DepreciacionAnual, opt => opt.MapFrom(src => src.DepreciacionAnual))
                .ForMember(dest => dest.TiempoVida, opt => opt.MapFrom(src => src.TiempoVida))
                .ForMember(dest => dest.ProveeduriaNac, opt => opt.MapFrom(src => src.ProveeduriaNac))
                .ForMember(dest => dest.CatalogoBasico, opt => opt.MapFrom(src => src.CatalogoBasico))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ReverseMap(); // Si se necesita mapeo inverso para creación/actualización

            // Mapeo de DTO de request a entidad (para creación/actualización)
            CreateMap<TipoBienDto, TipoBien>()
                .ForMember(dest => dest.CodigoClave, opt => opt.MapFrom(src => src.CodigoClave))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.ArticuloConteos, opt => opt.Ignore())
                .ForMember(dest => dest.FkidCuentaContableContaNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidGrupoBienAlmaNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidNivelAlmaNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidPartidaContaNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidUnidadesAlmaNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidUnidadesEquivalenteNavigation, opt => opt.Ignore());

            // Mapeo de vista a DTO de respuesta
            CreateMap<VwTipoBienConteo, TipoBienResponse>()
                .ForMember(dest => dest.PkidTipoBien, opt => opt.MapFrom(src => src.PkidTipoBien))
                .ForMember(dest => dest.CodigoArticulo, opt => opt.MapFrom(src => src.CodigoArticulo))
                .ForMember(dest => dest.DescripcionArticulo, opt => opt.MapFrom(src => src.DescripcionArticulo))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.UnidadMedida, opt => opt.MapFrom(src => src.UnidadMedida))
                .ForMember(dest => dest.UnidadEquivalente, opt => opt.MapFrom(src => src.UnidadEquivalente))
                .ForMember(dest => dest.CantidadEquivalente, opt => opt.MapFrom(src => src.CantidadEquivalente))
                .ForMember(dest => dest.Familia, opt => opt.MapFrom(src => src.Familia))
                .ForMember(dest => dest.GrupoBien, opt => opt.MapFrom(src => src.GrupoBien))
                .ForMember(dest => dest.Nivel, opt => opt.MapFrom(src => src.Nivel))
                .ForMember(dest => dest.PartidaClave, opt => opt.MapFrom(src => src.PartidaClave))
                .ForMember(dest => dest.PartidaDescripcion, opt => opt.MapFrom(src => src.PartidaDescripcion))
                .ForMember(dest => dest.CuentaCompleta, opt => opt.MapFrom(src => src.CuentaCompleta))
                .ForMember(dest => dest.CuentaDescripcion, opt => opt.MapFrom(src => src.CuentaDescripcion))
                .ForMember(dest => dest.TipoCuenta, opt => opt.MapFrom(src => src.TipoCuenta))
                .ForMember(dest => dest.ExistenciaMinima, opt => opt.MapFrom(src => src.ExistenciaMinima))
                .ForMember(dest => dest.ExistenciaMaxima, opt => opt.MapFrom(src => src.ExistenciaMaxima))
                .ForMember(dest => dest.Cabms, opt => opt.MapFrom(src => src.Cabms))
                .ForMember(dest => dest.CucopPlus, opt => opt.MapFrom(src => src.CucopPlus))
                .ForMember(dest => dest.DepreciacionAnual, opt => opt.MapFrom(src => src.DepreciacionAnual))
                .ForMember(dest => dest.TiempoVida, opt => opt.MapFrom(src => src.TiempoVida))
                .ForMember(dest => dest.ProveeduriaNac, opt => opt.MapFrom(src => src.ProveeduriaNac))
                .ForMember(dest => dest.CatalogoBasico, opt => opt.MapFrom(src => src.CatalogoBasico))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion));
        }
    }
}