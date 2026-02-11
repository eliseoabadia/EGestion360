using AutoMapper;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;
using System.Reflection;

namespace EG.Business.Mapping
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            RegisterMappingsByConvention();
            RegisterManualMappings();
        }

        private void RegisterMappingsByConvention()
        {
            var entityTypes = GetTypesFromNamespace("EG.Domain.Entities");
            var dtoTypes = GetTypesFromNamespace("EG.Dommain.DTOs.Responses");

            foreach (var entity in entityTypes)
            {
                var dtoType = dtoTypes.FirstOrDefault(d => 
                    d.Name == $"{entity.Name}Dto" || 
                    d.Name == $"{entity.Name}Response");

                if (dtoType != null)
                {
                    try
                    {
                        CreateMap(entity, dtoType).ReverseMap();
                    }
                    catch (Exception ex)
                    {
                        System.Diagnostics.Debug.WriteLine($"Error mapeando {entity.Name}: {ex.Message}");
                    }
                }
            }
        }

        private void RegisterManualMappings()
        {

            // Mapeo de Entidad a DTO básico
            CreateMap<Empresa, EmpresaDto>()
                .ReverseMap()
                .ForMember(dest => dest.PkidEmpresa,
                    opt => opt.MapFrom(src => src.PkidEmpresa));

            // Mapeo de la vista a Response (si tienes una vista VwEmpresa)
            CreateMap<VwEstadoEmpresa, EmpresaResponse>()
                .ForMember(dest => dest.PkidEmpresa,
                    opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.EmpresaNombre,
                    opt => opt.MapFrom(src => src.EmpresaNombre))
                .ForMember(dest => dest.Rfc,
                    opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.EmpresaActivo,
                    opt => opt.MapFrom(src => src.EmpresaActivo));

            // Mapeo de Entidad a Response (para cuando necesitas relaciones)
            CreateMap<Empresa, EmpresaResponse>()
                .ForMember(dest => dest.PkidEmpresa,
                    opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.EmpresaNombre,
                    opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.Rfc,
                    opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.EmpresaActivo,
                    opt => opt.MapFrom(src => src.Activo))
                // Si necesitas mapear información de estados
                .ForMember(dest => dest.PkidEstado,
                    opt => opt.MapFrom(src => src.EmpresaEstados.FirstOrDefault().FkidEstadoSis))
                .ForMember(dest => dest.EstadoNombre,
                    opt => opt.MapFrom(src => src.EmpresaEstados.FirstOrDefault().FkidEstadoSisNavigation.Nombre));

            // Mapeo de Entidad a DTO básico
            CreateMap<Departamento, DepartamentoDto>()
                .ReverseMap()
                .ForMember(dest => dest.PkidDepartamento,
                    opt => opt.MapFrom(src => src.PkidDepartamento ?? 0));

            // Mapeo de la vista a Response
            CreateMap<VwEmpresaDepartamanto, DepartamentoResponse>();
            // Mapeo de la vista a Response
            CreateMap<VwEmpresaDepartamanto, Departamento>();

            CreateMap<VwEmpresaDepartamanto, DepartamentoDto>()
                .ForMember(dest => dest.PkidDepartamento, opt => opt.MapFrom(src => src.PkidDepartamento))
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.DepartamentoNombre))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.DepartamentoActivo));

            // Mapeo de Entidad + Empresa a Response
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

            CreateMap<Empresa, EmpresaResponse>().ReverseMap();
            CreateMap<Usuario, UsuarioResponse>().ReverseMap();


            CreateMap<LoginInformationEmployeeResult, UserResponse>().ReverseMap();
            CreateMap<spNodeMenuResponse, spNodeMenuResult>().ReverseMap();
            //CreateMap<DepartamentoResponse, DepartamentoDto>().ReverseMap();
            CreateMap<PerfilUsuarioResponse, PerfilUsuario>()
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.FkidUsuarioSisNavigation, opt => opt.Ignore())
                .ReverseMap();
        }

        private Type[] GetTypesFromNamespace(string namespaceName)
        {
            var excludeAssemblies = new[] { "System", "Microsoft" };

            return AppDomain.CurrentDomain.GetAssemblies()
                .Where(a => !excludeAssemblies.Any(e => a.GetName().Name?.StartsWith(e) ?? false))
                .SelectMany(s => 
                {
                    try
                    {
                        return s.GetTypes();
                    }
                    catch
                    {
                        return [];
                    }
                })
                .Where(p => p?.Namespace == namespaceName && !p.IsInterface && !p.IsAbstract)
                .ToArray();
        }
    }
}