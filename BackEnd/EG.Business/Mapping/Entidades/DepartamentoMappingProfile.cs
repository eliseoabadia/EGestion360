using AutoMapper;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;

namespace EG.Business.Mappings
{
    public class DepartamentoMappingProfile : Profile
    {
        public DepartamentoMappingProfile()
        {
            // ============ DEPARTAMENTO ============

            // Entidad <-> DTO básico
            CreateMap<Departamento, DepartamentoDto>()
                .ReverseMap()
                .ForMember(dest => dest.PkidDepartamento,
                    opt => opt.MapFrom(src => src.PkidDepartamento ?? 0));

            // Vista -> Response
            CreateMap<VwEmpresaDepartamanto, DepartamentoResponse>();

            // Vista -> Entity
            CreateMap<VwEmpresaDepartamanto, Departamento>();

            // Vista -> DTO
            CreateMap<VwEmpresaDepartamanto, DepartamentoDto>()
                .ForMember(dest => dest.PkidDepartamento, opt => opt.MapFrom(src => src.PkidDepartamento))
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.DepartamentoNombre))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.DepartamentoActivo));

            // Entidad + Empresa -> Response
            CreateMap<Departamento, DepartamentoResponse>()
                .ForMember(dest => dest.PkidEmpresa,
                    opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation.PkidEmpresa))
                .ForMember(dest => dest.EmpresaNombre,
                    opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation.Nombre))
                .ForMember(dest => dest.Rfc,
                    opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation.Rfc))
                .ForMember(dest => dest.PkidDepartamento,
                    opt => opt.MapFrom(src => src.PkidDepartamento))
                .ForMember(dest => dest.DepartamentoNombre,
                    opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.DepartamentoActivo,
                    opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.EmpresaActivo,
                    opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation.Activo));

            //--
            // Mapeo de Entidad a DTO básico
            //CreateMap<Departamento, DepartamentoDto>()
            //    .ReverseMap()
            //    .ForMember(dest => dest.PkidDepartamento,
            //        opt => opt.MapFrom(src => src.PkidDepartamento ?? 0));

            //// Mapeo de la vista a Response
            //CreateMap<VwEmpresaDepartamanto, DepartamentoResponse>();
            //// Mapeo de la vista a Response
            //CreateMap<VwEmpresaDepartamanto, Departamento>();

            //CreateMap<VwEmpresaDepartamanto, DepartamentoDto>()
            //    .ForMember(dest => dest.PkidDepartamento, opt => opt.MapFrom(src => src.PkidDepartamento))
            //    .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.PkidEmpresa))
            //    .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.DepartamentoNombre))
            //    .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.DepartamentoActivo));

            //// Mapeo de Entidad + Empresa a Response
            //CreateMap<Departamento, DepartamentoResponse>()
            //    .ForMember(dest => dest.PkidEmpresa,
            //        opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation.PkidEmpresa))
            //    .ForMember(dest => dest.EmpresaNombre,
            //        opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation.Nombre))
            //    .ForMember(dest => dest.Rfc,
            //        opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation.Rfc))
            //    .ForMember(dest => dest.PkidDepartamento,
            //        opt => opt.MapFrom(src => src.PkidDepartamento))
            //    .ForMember(dest => dest.DepartamentoNombre,
            //        opt => opt.MapFrom(src => src.Nombre))
            //    .ForMember(dest => dest.DepartamentoActivo,
            //        opt => opt.MapFrom(src => src.Activo))
            //    .ForMember(dest => dest.EmpresaActivo,
            //        opt => opt.MapFrom(src => src.FkidEmpresaSisNavigation.Activo));
        }
    }
}