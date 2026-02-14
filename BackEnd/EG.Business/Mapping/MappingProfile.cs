using AutoMapper;


namespace EG.Business.Mapping
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            //RegisterMappingsByConvention();
            RegisterManualMappings();
        }

        private void RegisterManualMappings()
        {

            // ============ PERFILES EXTERNOS ============

            //this.AddProfile<EmpresaMappingProfile>();
            //this.AddProfile<DepartamentoMappingProfile>();
            //this.AddProfile<GeneralMappingProfile>();



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