using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class ProveedorMappingProfile : Profile
    {
        public ProveedorMappingProfile()
        {
            CreateMap<Proveedor, ProveedorDto>()
                .ForMember(dest => dest.FkIdTipoProveedorSis, opt => opt.MapFrom(src => src.FkIdTipoProveedorSis))
                .ReverseMap();
            CreateMap<Proveedor, ProveedorResponse>()
                .ForMember(dest => dest.TipoProveedorNombre, opt => opt.MapFrom(src => src.FkIdTipoProveedorSisNavigation != null ? src.FkIdTipoProveedorSisNavigation.Descripcion : string.Empty))
                .ForMember(dest => dest.EstatusProveedorNombre, opt => opt.MapFrom(src => src.FkidEstatusProveedorSisNavigation != null ? src.FkidEstatusProveedorSisNavigation.Descripcion : string.Empty))
                .ForMember(dest => dest.CuentaContableNombre, opt => opt.MapFrom(src => src.FkidCuentaContableSisNavigation != null ? src.FkidCuentaContableSisNavigation.Descripcion : string.Empty))
                .ForMember(dest => dest.MunicipioNombre, opt => opt.MapFrom(src => src.FkidMunicipioSisNavigation != null ? src.FkidMunicipioSisNavigation.Nombre : string.Empty))
                .ForMember(dest => dest.EstadoNombre, opt => opt.MapFrom(src => src.FkidEstadoSisNavigation != null ? src.FkidEstadoSisNavigation.Nombre : string.Empty))
                .ForMember(dest => dest.PaisNombre, opt => opt.MapFrom(src => src.FkidPaisSisNavigation != null ? src.FkidPaisSisNavigation.Nombre : string.Empty));
            CreateMap<VwProveedor, ProveedorResponse>()
                .ForMember(dest => dest.TipoProveedorNombre, opt => opt.MapFrom(src => src.TipoProveedorDesc))
                .ForMember(dest => dest.EstatusProveedorNombre, opt => opt.MapFrom(src => src.EstatusProveedorDesc))
                .ForMember(dest => dest.CuentaContableNombre, opt => opt.MapFrom(src => src.CuentaContableClave))
                .ForMember(dest => dest.ResponsableNombre, opt => opt.Ignore());
            CreateMap<ProveedorResponse, ProveedorDto>()
                .ForMember(dest => dest.PkidProveedor, opt => opt.Ignore())
                .ForMember(dest => dest.FkIdTipoProveedorSis, opt => opt.Ignore())
                .ForMember(dest => dest.FkidEstatusProveedorSis, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}