using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class DepartamentoMappingProfile : Profile
    {
        public DepartamentoMappingProfile()
        {
            CreateMap<Departamento, DepartamentoDto>()
                .ForMember(dest => dest.PkidDepartamento, opt => opt.MapFrom(src => src.PkidDepartamento))
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.FkidEmpresaSis))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.FkidSucursalSis))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.NivelJerarquico, opt => opt.MapFrom(src => src.NivelJerarquico))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion));

            CreateMap<DepartamentoDto, Departamento>()
                .ForMember(dest => dest.FkidEmpresaSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.FkidSucursalSisNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacionNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacionNavigation, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioDepartamentos, opt => opt.Ignore());

            CreateMap<Departamento, DepartamentoResponse>()
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.FkidEmpresaSis))
                .ForMember(dest => dest.EmpresaNombre, opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Nombre : string.Empty))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Rfc : string.Empty))
                .ForMember(dest => dest.DepartamentoNombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.DepartamentoActivo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.EmpresaActivo, opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Activo : false))
                .ForMember(dest => dest.UsuarioCreacionNombre, opt => opt.MapFrom(src => src.UsuarioCreacionNavigation != null 
                    ? $"{src.UsuarioCreacionNavigation.Nombre} {src.UsuarioCreacionNavigation.ApellidoPaterno}" 
                    : string.Empty));

            CreateMap<VwEmpresaDepartamanto, DepartamentoResponse>();

            CreateMap<DepartamentoResponse, DepartamentoDto>()
                .ForMember(dest => dest.PkidDepartamento, opt => opt.MapFrom(src => src.PkidDepartamento))
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.Ignore())
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.DepartamentoNombre))
                .ForMember(dest => dest.Descripcion, opt => opt.MapFrom(src => src.Descripcion))
                .ForMember(dest => dest.NivelJerarquico, opt => opt.MapFrom(src => src.NivelJerarquico))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.DepartamentoActivo))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore());
        }
    }
}
