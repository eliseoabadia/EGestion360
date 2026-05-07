using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class TipoBienMappingProfile : Profile
    {
        public TipoBienMappingProfile()
        {
            CreateMap<TipoBien, TipoBienDto>().ReverseMap();
            CreateMap<TipoBien, TipoBienResponse>()
                .ForMember(dest => dest.TipoBienDescripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.GrupoBienDescripcion, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.Descripcion : null))
                .ForMember(dest => dest.GrupoBienClave, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.Clave : null))
                .ForMember(dest => dest.ClaveAn, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.ClaveAn : null))
                .ForMember(dest => dest.CabmAct, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.CabmAct : null))
                .ForMember(dest => dest.ClaveCucop, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.ClaveCucop : null))
                .ForMember(dest => dest.GrupoBienMedida, opt => opt.MapFrom(src => src.FkidGrupoBienAlmaNavigation != null ? src.FkidGrupoBienAlmaNavigation.Medida : null))
                .ForMember(dest => dest.FamiliaDescripcion, opt => opt.Ignore())
                .ForMember(dest => dest.FamiliaClave, opt => opt.Ignore())
                .ForMember(dest => dest.Nivel, opt => opt.MapFrom(src => src.FkidNivelAlmaNavigation != null ? src.FkidNivelAlmaNavigation.Nivel1 : (int?)null))
                .ForMember(dest => dest.NivelDescripcion, opt => opt.MapFrom(src => src.FkidNivelAlmaNavigation != null ? src.FkidNivelAlmaNavigation.Descripcion : null))
                .ForMember(dest => dest.PartidaClave, opt => opt.Ignore())
                .ForMember(dest => dest.PartidaDescripcion, opt => opt.MapFrom(src => src.FkidPartidaContaNavigation != null ? src.FkidPartidaContaNavigation.Descripcion : null))
                .ForMember(dest => dest.CtaCoi, opt => opt.MapFrom(src => src.FkidCuentaContableContaNavigation != null ? src.FkidCuentaContableContaNavigation.CtaCoi : null))
                .ForMember(dest => dest.CuentaDescripcion, opt => opt.MapFrom(src => src.FkidCuentaContableContaNavigation != null ? src.FkidCuentaContableContaNavigation.Descripcion : null))
                .ForMember(dest => dest.TipoCuenta, opt => opt.MapFrom(src => src.FkidCuentaContableContaNavigation != null ? src.FkidCuentaContableContaNavigation.TipoCuenta : null))
                .ForMember(dest => dest.UnidadMedida, opt => opt.MapFrom(src => src.FkidUnidadesAlmaNavigation != null ? src.FkidUnidadesAlmaNavigation.Descripcion : null))
                .ForMember(dest => dest.UnidadEquivalenteMedida, opt => opt.MapFrom(src => src.FkidUnidadesEquivalenteNavigation != null ? src.FkidUnidadesEquivalenteNavigation.Descripcion : null));
            CreateMap<VwTipoBien, TipoBienDto>()
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.TipoBienDescripcion))
                .ForMember(dest => dest.PkidTipoBien, opt => opt.Ignore());
            CreateMap<VwTipoBien, TipoBienResponse>();
            CreateMap<TipoBienResponse, TipoBienDto>()
                .ForMember(dest => dest.PkidTipoBien, opt => opt.Ignore())
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.TipoBienDescripcion))
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
