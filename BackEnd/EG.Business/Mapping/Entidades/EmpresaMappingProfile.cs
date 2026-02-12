using AutoMapper;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;

namespace EG.Business.Mappings
{
    public class EmpresaMappingProfile : Profile
    {
        public EmpresaMappingProfile()
        {
            // ============ ENTITY -> RESPONSE con Estado ============
            CreateMap<Empresa, EmpresaResponse>()
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.EmpresaNombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.EmpresaActivo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.PkidEstado, opt => opt.MapFrom(src =>
                    src.EmpresaEstados.FirstOrDefault(ee => ee.Activo).FkidEstadoSisNavigation))
                .ForMember(dest => dest.EstadoNombre, opt => opt.MapFrom(src =>
                    src.EmpresaEstados.FirstOrDefault(ee => ee.Activo).FkidEstadoSisNavigation.Nombre));

            // ============ DTO -> ENTITY ============
            CreateMap<EmpresaDto, Empresa>()
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.Departamentos, opt => opt.Ignore())
                .ForMember(dest => dest.EmpresaEstados, opt => opt.Ignore())
                .ForMember(dest => dest.Sucursals, opt => opt.Ignore())
                .ForMember(dest => dest.Usuarios, opt => opt.Ignore());

            // ============ RESPONSE -> DTO ============
            CreateMap<EmpresaResponse, EmpresaDto>()
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.EmpresaNombre))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.EmpresaActivo));

            // ============ VISTA -> DTO ============
            CreateMap<VwEstadoEmpresa, EmpresaDto>()
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.EmpresaNombre))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.EmpresaActivo));

            // ============ VISTA -> RESPONSE ============
            CreateMap<VwEstadoEmpresa, EmpresaResponse>()
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.EmpresaNombre, opt => opt.MapFrom(src => src.EmpresaNombre))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.EmpresaActivo, opt => opt.MapFrom(src => src.EmpresaActivo))
                .ForMember(dest => dest.PkidEstado, opt => opt.MapFrom(src => src.PkidEstado))
                .ForMember(dest => dest.EstadoNombre, opt => opt.MapFrom(src => src.EstadoNombre));

            // ============ RESPONSE -> DTO (para actualizaciones) ============
            CreateMap<EmpresaResponse, EmpresaDto>()
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.EmpresaNombre))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.EmpresaActivo));
        }
    }
}