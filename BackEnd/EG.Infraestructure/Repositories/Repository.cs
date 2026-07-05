using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Metadata;
using System.Linq.Expressions;
using System.Reflection;

namespace EG.Infrastructure
{
    public class Repository<T> : IRepository<T> where T : class
    {
        private readonly EGestionContext _context;
        private readonly DbSet<T> _dbSet;

        public Repository(EGestionContext context)
        {
            _context = context;
            _dbSet = _context.Set<T>();
        }

        public async Task AddAsync(T entity)
        {
            await _dbSet.AddAsync(entity);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            await SoftDeleteAsync(id);
        }

        public async Task SoftDeleteAsync(int id, string? activePropertyName = "Activo")
        {
            var entity = await GetByIdAsync(id);
            if (entity == null)
            {
                throw new KeyNotFoundException($"Entidad {typeof(T).Name} con ID {id} no encontrada.");
            }

            var prop = typeof(T).GetProperty(activePropertyName ?? "Activo", BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
            if (prop == null || !IsBooleanProperty(prop.PropertyType))
            {
                throw new InvalidOperationException($"La entidad {typeof(T).Name} no soporta baja logica porque no tiene la propiedad {activePropertyName ?? "Activo"}.");
            }

            if (IsInactive(entity, prop))
            {
                throw new InvalidOperationException($"La entidad {typeof(T).Name} con ID {id} ya se encuentra inactiva.");
            }

            await EnsureNoActiveDependentsAsync(id);

            prop.SetValue(entity, false);
            var entry = _context.Entry(entity);
            MarkOnlyActivePropertyModified(entry);
            await SaveChangesOrThrowAsync(
                $"No fue posible dar de baja {typeof(T).Name} con ID {id} porque la base de datos no confirmo el cambio.");
            await EnsureEntityIsInactiveAsync(id, activePropertyName ?? "Activo");
        }

        public async Task<bool> HasActiveChildrenAsync<TChild>(string childForeignKeyProperty, int parentId, string? childActiveProperty = "Activo") where TChild : class
        {
            var childSet = _context.Set<TChild>();
            var prop = typeof(TChild).GetProperty(childActiveProperty ?? "Activo", BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);

            IQueryable<TChild> query = childSet;

            if (prop != null && prop.PropertyType == typeof(bool))
            {
                var param = Expression.Parameter(typeof(TChild), "e");
                var propAccess = Expression.Property(param, prop);
                var condition = Expression.Equal(propAccess, Expression.Constant(true, typeof(bool)));
                var lambda = Expression.Lambda<Func<TChild, bool>>(condition, param);
                query = query.Where(lambda);
            }

            var fkProp = typeof(TChild).GetProperty(childForeignKeyProperty, BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
            if (fkProp == null) return false;

            var param2 = Expression.Parameter(typeof(TChild), "e");
            var fkAccess = Expression.Property(param2, fkProp);
            var fkCondition = Expression.Equal(fkAccess, Expression.Constant(parentId, fkProp.PropertyType));
            var fkLambda = Expression.Lambda<Func<TChild, bool>>(fkCondition, param2);
            query = query.Where(fkLambda);

            return await query.AnyAsync();
        }

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            var query = _dbSet.AsQueryable();
            var activoProperty = typeof(T).GetProperty("Activo", BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
            if (activoProperty != null && activoProperty.PropertyType == typeof(bool))
            {
                var param = Expression.Parameter(typeof(T), "e");
                var propAccess = Expression.Property(param, activoProperty);
                var condition = Expression.Equal(propAccess, Expression.Constant(true, typeof(bool)));
                var lambda = Expression.Lambda<Func<T, bool>>(condition, param);
                query = query.Where(lambda);
            }
            return await query.AsNoTracking().ToListAsync();
        }

        public async Task<T> GetByIdAsync(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            return entity;
        }

        public async Task<T> GetByIdAsync(short id)
        {
            var entity = await _dbSet.FindAsync(id);
            return entity;
        }


        public async Task UpdateAsync(T entity)
        {
            var entry = _context.Entry(entity);
            if (entry.State == EntityState.Detached)
            {
                _dbSet.Attach(entity);
                entry.State = EntityState.Modified;
            }

            if (TryGetInactiveEntityId(entity, out var id))
            {
                await EnsureNoActiveDependentsAsync(id);
                MarkOnlyActivePropertyModified(entry);
                await SaveChangesOrThrowAsync(
                    $"No fue posible dar de baja {typeof(T).Name} con ID {id} porque la base de datos no confirmo el cambio.");
                await EnsureEntityIsInactiveAsync(id, "Activo");
                return;
            }

            await _context.SaveChangesAsync();
        }

        public async Task<IEnumerable<T>> GetAllWithIncludesAsync(Expression<Func<T, bool>> filter, params Expression<Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet;

            if (filter != null)
            {
                query = query.Where(filter);
            }

            foreach (var include in includes)
            {
                query = query.Include(include);
            }

            return await query.AsNoTracking().ToListAsync();
        }

        public async Task<IEnumerable<T>> GetAllWithIncludes2Async( Expression<Func<T, bool>> filter,  params Expression<Func<T, object>>[] includes)
        {
            try
            {
                IQueryable<T> query = _dbSet.AsQueryable();

                foreach (var include in includes)
                {
                    query = query.Include(include);
                }

                if (filter != null)
                {
                    query = query.Where(filter);
                }

                return await query.AsNoTracking().ToListAsync();
            }
            catch
            {
                throw;
            }
        }

        public IQueryable<T> QueryWithIncludes(Expression<Func<T, bool>> filter, params Expression<Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet.AsQueryable();

            foreach (var include in includes)
            {
                query = query.Include(include);
            }

            if (filter != null)
            {
                query = query.Where(filter);
            }

            return query.AsNoTracking();
        }

        private static bool IsBooleanProperty(Type propertyType)
        {
            var targetType = Nullable.GetUnderlyingType(propertyType) ?? propertyType;
            return targetType == typeof(bool);
        }

        private static bool IsInactive(T entity, PropertyInfo activeProperty)
        {
            var value = activeProperty.GetValue(entity);
            return value is bool active && !active;
        }

        private static void MarkOnlyActivePropertyModified(EntityEntry entry)
        {
            foreach (var property in entry.Properties)
            {
                property.IsModified = false;
            }

            var activeProperty = entry.Properties.FirstOrDefault(property =>
                string.Equals(property.Metadata.Name, "Activo", StringComparison.OrdinalIgnoreCase));

            if (activeProperty != null)
            {
                activeProperty.IsModified = true;
            }
        }

        private async Task SaveChangesOrThrowAsync(string message)
        {
            var affectedRows = await _context.SaveChangesAsync();
            if (affectedRows <= 0)
            {
                throw new InvalidOperationException(message);
            }
        }

        private async Task EnsureEntityIsInactiveAsync(int id, string activePropertyName)
        {
            var entityType = _context.Model.FindEntityType(typeof(T));
            var primaryKeyProperty = entityType?.FindPrimaryKey()?.Properties.SingleOrDefault();
            var activeProperty = entityType?.FindProperty(activePropertyName);
            if (primaryKeyProperty == null || activeProperty == null || !IsBooleanProperty(activeProperty.ClrType))
            {
                return;
            }

            var parameter = Expression.Parameter(typeof(T), "entity");
            var keyAccess = CreatePropertyAccess(parameter, primaryKeyProperty);
            var keyConstant = Expression.Constant(ConvertToPropertyType(id, primaryKeyProperty.ClrType), Nullable.GetUnderlyingType(primaryKeyProperty.ClrType) ?? primaryKeyProperty.ClrType);
            Expression comparableKeyValue = keyConstant;
            if (keyAccess.Type != keyConstant.Type)
            {
                comparableKeyValue = Expression.Convert(keyConstant, keyAccess.Type);
            }

            var activeAccess = CreatePropertyAccess(parameter, activeProperty);
            var activeConstant = Expression.Constant(true, typeof(bool));
            Expression comparableActiveValue = activeAccess.Type == typeof(bool)
                ? activeConstant
                : Expression.Convert(activeConstant, activeAccess.Type);

            var predicate = Expression.AndAlso(
                Expression.Equal(keyAccess, comparableKeyValue),
                Expression.Equal(activeAccess, comparableActiveValue));

            var lambda = Expression.Lambda<Func<T, bool>>(predicate, parameter);
            var stillActive = await _dbSet.AsNoTracking().AnyAsync(lambda);
            if (stillActive)
            {
                throw new InvalidOperationException(
                    $"No fue posible dar de baja {typeof(T).Name} con ID {id}; el registro sigue activo en la base de datos.");
            }
        }

        private bool TryGetInactiveEntityId(T entity, out int id)
        {
            id = 0;
            var activeProperty = typeof(T).GetProperty("Activo", BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
            if (activeProperty == null || !IsBooleanProperty(activeProperty.PropertyType) || !IsInactive(entity, activeProperty))
            {
                return false;
            }

            var entityType = _context.Model.FindEntityType(typeof(T));
            var primaryKeyProperty = entityType?.FindPrimaryKey()?.Properties.SingleOrDefault();
            var keyValue = primaryKeyProperty?.PropertyInfo?.GetValue(entity);
            if (keyValue == null)
            {
                return false;
            }

            id = Convert.ToInt32(keyValue);
            return id > 0;
        }

        private async Task EnsureNoActiveDependentsAsync(int id)
        {
            var entityType = _context.Model.FindEntityType(typeof(T));
            var primaryKey = entityType?.FindPrimaryKey();
            if (entityType == null || primaryKey?.Properties.Count != 1)
            {
                return;
            }

            var principalKey = primaryKey.Properties[0];
            var incomingForeignKeys = _context.Model
                .GetEntityTypes()
                .SelectMany(type => type.GetForeignKeys())
                .Where(foreignKey =>
                    foreignKey.PrincipalEntityType == entityType &&
                    foreignKey.PrincipalKey.Properties.Count == 1 &&
                    foreignKey.PrincipalKey.Properties[0] == principalKey &&
                    foreignKey.Properties.Count == 1 &&
                    !foreignKey.DeclaringEntityType.IsOwned());

            foreach (var foreignKey in incomingForeignKeys)
            {
                var dependentType = foreignKey.DeclaringEntityType.ClrType;
                var hasActiveDependent = await HasActiveDependentAsync(dependentType, foreignKey, id);
                if (hasActiveDependent)
                {
                    throw new InvalidOperationException(
                        $"No se puede dar de baja {entityType.ClrType.Name} porque existen registros activos en {dependentType.Name} que lo referencian.");
                }
            }
        }

        private async Task<bool> HasActiveDependentAsync(Type dependentType, IForeignKey foreignKey, int principalId)
        {
            var method = typeof(Repository<T>)
                .GetMethod(nameof(HasActiveDependentGenericAsync), BindingFlags.Instance | BindingFlags.NonPublic)!
                .MakeGenericMethod(dependentType);

            var result = method.Invoke(this, [foreignKey, principalId]);
            return result is Task<bool> task && await task;
        }

        private async Task<bool> HasActiveDependentGenericAsync<TDependent>(IForeignKey foreignKey, int principalId)
            where TDependent : class
        {
            var parameter = Expression.Parameter(typeof(TDependent), "entity");
            var foreignKeyProperty = foreignKey.Properties[0];
            var foreignKeyAccess = CreatePropertyAccess(parameter, foreignKeyProperty);
            var foreignKeyValue = ConvertToPropertyType(principalId, foreignKeyProperty.ClrType);
            var foreignKeyConstant = Expression.Constant(foreignKeyValue, Nullable.GetUnderlyingType(foreignKeyProperty.ClrType) ?? foreignKeyProperty.ClrType);
            Expression comparableForeignKeyValue = foreignKeyConstant;

            if (foreignKeyAccess.Type != foreignKeyConstant.Type)
            {
                comparableForeignKeyValue = Expression.Convert(foreignKeyConstant, foreignKeyAccess.Type);
            }

            Expression predicate = Expression.Equal(foreignKeyAccess, comparableForeignKeyValue);

            var activeProperty = foreignKey.DeclaringEntityType.FindProperty("Activo");
            if (activeProperty != null && IsBooleanProperty(activeProperty.ClrType))
            {
                var activeAccess = CreatePropertyAccess(parameter, activeProperty);
                var activeConstant = Expression.Constant(true, typeof(bool));
                Expression comparableActiveValue = activeAccess.Type == typeof(bool)
                    ? activeConstant
                    : Expression.Convert(activeConstant, activeAccess.Type);

                predicate = Expression.AndAlso(predicate, Expression.Equal(activeAccess, comparableActiveValue));
            }

            var lambda = Expression.Lambda<Func<TDependent, bool>>(predicate, parameter);
            return await _context.Set<TDependent>().AnyAsync(lambda);
        }

        private static Expression CreatePropertyAccess(ParameterExpression parameter, IProperty property)
        {
            if (property.PropertyInfo != null)
            {
                return Expression.Property(parameter, property.PropertyInfo);
            }

            return Expression.Call(
                typeof(EF),
                nameof(EF.Property),
                [property.ClrType],
                parameter,
                Expression.Constant(property.Name));
        }

        private static object ConvertToPropertyType(int value, Type propertyType)
        {
            var targetType = Nullable.GetUnderlyingType(propertyType) ?? propertyType;
            return Convert.ChangeType(value, targetType);
        }


    }
}
