using AutoMapper;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Almacen;

public class AlmacenMappingProfile : Profile
{
    public AlmacenMappingProfile()
    {
        // Familia mappings (Familium)
        CreateMap<Familium, FamiliaResponse>()
            .ForMember(dest => dest.PkidFamilia, opt => opt.MapFrom(src => src.PkidFamilia)).ReverseMap();

        CreateMap<FamiliaDto, FamiliaResponse>()
            .ForMember(dest => dest.PkidFamilia, opt => opt.MapFrom(src => src.PkidFamilia)).ReverseMap();

        // TipoBien Entity <-> Dto
        CreateMap<TipoBien, TipoBienDto>()
            .ForMember(dest => dest.PkidTipoBien, opt => opt.MapFrom(src => src.PkidTipoBien))
            .ForMember(dest => dest.FkidGrupoBienAlma, opt => opt.MapFrom(src => src.FkidGrupoBienAlma))
            .ForMember(dest => dest.FkidNivelAlma, opt => opt.MapFrom(src => src.FkidNivelAlma))
            .ForMember(dest => dest.FkidPartidaConta, opt => opt.MapFrom(src => src.FkidPartidaConta))
            .ForMember(dest => dest.FkidCuentaContableConta, opt => opt.MapFrom(src => src.FkidCuentaContableConta))
            .ForMember(dest => dest.FkidUnidadesAlma, opt => opt.MapFrom(src => src.FkidUnidadesAlma))
            .ForMember(dest => dest.FkidLocalizacionAlma, opt => opt.MapFrom(src => src.FkidLocalizacionAlma))
            .ForMember(dest => dest.CodigoClave, opt => opt.MapFrom(src => src.CodigoClave))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
            .ForMember(dest => dest.DepreciacionAnual, opt => opt.MapFrom(src => src.DepreciacionAnual))
            .ForMember(dest => dest.Consecutivo, opt => opt.MapFrom(src => src.Consecutivo))
            .ForMember(dest => dest.Cabms, opt => opt.MapFrom(src => src.Cabms))
            .ForMember(dest => dest.Identificador, opt => opt.MapFrom(src => src.Identificador))
            .ForMember(dest => dest.ExistenciaMinima, opt => opt.MapFrom(src => src.ExistenciaMinima))
            .ForMember(dest => dest.ExistenciaMaxima, opt => opt.MapFrom(src => src.ExistenciaMaxima))
            .ForMember(dest => dest.TiempoVida, opt => opt.MapFrom(src => src.TiempoVida))
            .ForMember(dest => dest.PkIdTratadoInt, opt => opt.MapFrom(src => src.PkIdTratadoInt))
            .ForMember(dest => dest.Cuota, opt => opt.MapFrom(src => src.Cuota))
            .ForMember(dest => dest.ProveeduriaNac, opt => opt.MapFrom(src => src.ProveeduriaNac))
            .ForMember(dest => dest.CatalogoBasico, opt => opt.MapFrom(src => src.CatalogoBasico))
            .ForMember(dest => dest.CucopPlus, opt => opt.MapFrom(src => src.CucopPlus))
            .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
            .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
            .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
            .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
            .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
            .ForMember(dest => dest.FkidUnidadesEquivalente, opt => opt.MapFrom(src => src.FkidUnidadesEquivalente))
            .ForMember(dest => dest.CantidadEquivalente, opt => opt.MapFrom(src => src.CantidadEquivalente));

        CreateMap<TipoBienDto, TipoBien>()
            .ForMember(dest => dest.FkidGrupoBienAlmaNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidNivelAlmaNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidPartidaContaNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidCuentaContableContaNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidUnidadesAlmaNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidUnidadesEquivalenteNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.Biens, opt => opt.Ignore())
            .ForMember(dest => dest.ConteoDetalleEscaneos, opt => opt.Ignore())
            .ForMember(dest => dest.Conteos, opt => opt.Ignore());

        // VwTipoBienConteo -> TipoBienResponse (vista para lectura)
        CreateMap<VwTipoBienConteo, TipoBienResponse>();

        // TipoBienResponse -> TipoBienDto (para actualizaciones desde frontend)
        CreateMap<TipoBienResponse, TipoBienDto>()
            .ForMember(dest => dest.PkidTipoBien, opt => opt.MapFrom(src => src.PkidTipoBien))
            .ForMember(dest => dest.CodigoClave, opt => opt.MapFrom(src => src.CodigoArticulo))
            .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.DescripcionArticulo))
            .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
            .ForMember(dest => dest.ExistenciaMinima, opt => opt.MapFrom(src => src.ExistenciaMinima))
            .ForMember(dest => dest.ExistenciaMaxima, opt => opt.MapFrom(src => src.ExistenciaMaxima))
            .ForMember(dest => dest.CucopPlus, opt => opt.MapFrom(src => src.CucopPlus))
            .ForMember(dest => dest.Cabms, opt => opt.MapFrom(src => src.Cabms))
            .ForMember(dest => dest.DepreciacionAnual, opt => opt.MapFrom(src => src.DepreciacionAnual))
            .ForMember(dest => dest.TiempoVida, opt => opt.MapFrom(src => src.TiempoVida))
            .ForMember(dest => dest.ProveeduriaNac, opt => opt.MapFrom(src => src.ProveeduriaNac))
            .ForMember(dest => dest.CatalogoBasico, opt => opt.MapFrom(src => src.CatalogoBasico))
            .ForMember(dest => dest.CantidadEquivalente, opt => opt.MapFrom(src => src.CantidadEquivalente))
            .ForMember(dest => dest.Identificador, opt => opt.MapFrom(src => src.Identificador))
            .ForMember(dest => dest.Consecutivo, opt => opt.MapFrom(src => src.Consecutivo))
            .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
            .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
            .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
            .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
            .ForMember(dest => dest.FkidGrupoBienAlma, opt => opt.MapFrom(src => src.FkIdGrupoBienSicop))
            .ForMember(dest => dest.FkidNivelAlma, opt => opt.MapFrom(src => src.FkIdNivel))
            .ForMember(dest => dest.FkidPartidaConta, opt => opt.MapFrom(src => src.FkIdPartidaSis))
            .ForMember(dest => dest.FkidCuentaContableConta, opt => opt.MapFrom(src => src.FkIdCuentaContable))
            .ForMember(dest => dest.FkidUnidadesAlma, opt => opt.MapFrom(src => src.FkIdUnidadesAlma))
            .ForMember(dest => dest.FkidLocalizacionAlma, opt => opt.Ignore())
            .ForMember(dest => dest.PkIdTratadoInt, opt => opt.Ignore())
            .ForMember(dest => dest.Cuota, opt => opt.Ignore())
            .ForMember(dest => dest.FkidUnidadesEquivalente, opt => opt.MapFrom(src => src.FkIdUnidadesEquivalente));

        // Bien mappings
        CreateMap<Bien, BienDto>().ReverseMap();
        CreateMap<VwBien, BienResponse>();
    }
}
