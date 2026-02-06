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

            CreateMap<Departamento, DepartamentoDto>().ReverseMap();
            CreateMap<Departamento, DepartamentoResponse>().ReverseMap();
            CreateMap<Empresa, EmpresaDto>().ReverseMap();
            CreateMap<Empresa, EmpresaResponse>().ReverseMap();


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