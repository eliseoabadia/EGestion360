using Mapster;
using System.Reflection;

namespace EG.Business.Services
{
    public static class EntityUpdateMapper
    {
        private static readonly string[] DefaultPreservedProperties =
        [
            "UsuarioCreacion",
            "FechaCreacion",
            "RowVersion"
        ];

        public static void Apply<TDto, TEntity>(
            TDto sourceDto,
            TEntity targetEntity,
            params string[] additionalPreservedPropertyNames)
            where TDto : class
            where TEntity : class
        {
            ArgumentNullException.ThrowIfNull(sourceDto);
            ArgumentNullException.ThrowIfNull(targetEntity);

            var mappedEntity = sourceDto.Adapt<TEntity>();
            var preservedNames = DefaultPreservedProperties
                .Concat(additionalPreservedPropertyNames ?? [])
                .ToHashSet(StringComparer.OrdinalIgnoreCase);

            CopyUpdatablePropertyValues(mappedEntity, targetEntity, preservedNames);
        }

        private static void CopyUpdatablePropertyValues<TEntity>(
            TEntity source,
            TEntity target,
            HashSet<string> preservedNames)
            where TEntity : class
        {
            var primaryKeyProperty = FindPrimaryKeyProperty<TEntity>();
            var sourceProperties = typeof(TEntity)
                .GetProperties(BindingFlags.Instance | BindingFlags.Public)
                .Where(property => property.CanRead)
                .ToDictionary(property => property.Name, StringComparer.OrdinalIgnoreCase);

            foreach (var targetProperty in typeof(TEntity).GetProperties(BindingFlags.Instance | BindingFlags.Public))
            {
                if (!targetProperty.CanWrite ||
                    !IsScalarMappableProperty(targetProperty.PropertyType) ||
                    preservedNames.Contains(targetProperty.Name) ||
                    IsSameProperty(targetProperty, primaryKeyProperty))
                {
                    continue;
                }

                if (!sourceProperties.TryGetValue(targetProperty.Name, out var sourceProperty) ||
                    !IsScalarMappableProperty(sourceProperty.PropertyType))
                {
                    continue;
                }

                targetProperty.SetValue(target, sourceProperty.GetValue(source));
            }
        }

        private static PropertyInfo? FindPrimaryKeyProperty<TEntity>()
        {
            var properties = typeof(TEntity).GetProperties(BindingFlags.Instance | BindingFlags.Public);
            return properties.FirstOrDefault(property =>
                property.Name.StartsWith("Pkid", StringComparison.OrdinalIgnoreCase) ||
                property.Name.Equals("Id", StringComparison.OrdinalIgnoreCase) ||
                property.Name.Equals($"{typeof(TEntity).Name}Id", StringComparison.OrdinalIgnoreCase));
        }

        private static bool IsSameProperty(PropertyInfo property, PropertyInfo? otherProperty)
        {
            return otherProperty != null &&
                string.Equals(property.Name, otherProperty.Name, StringComparison.OrdinalIgnoreCase);
        }

        private static bool IsScalarMappableProperty(Type propertyType)
        {
            var targetType = Nullable.GetUnderlyingType(propertyType) ?? propertyType;
            return targetType.IsEnum ||
                targetType.IsPrimitive ||
                targetType == typeof(string) ||
                targetType == typeof(decimal) ||
                targetType == typeof(DateTime) ||
                targetType == typeof(DateOnly) ||
                targetType == typeof(TimeOnly) ||
                targetType == typeof(Guid) ||
                targetType == typeof(byte[]);
        }
    }
}
