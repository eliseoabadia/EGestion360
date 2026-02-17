using AutoMapper;
using EG.Application.CommonModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.Interfaces;
using System.Linq.Expressions;
using System.Reflection;

namespace EG.Business.Services
{
    public class GenericService<TEntity, TDto, TResponse>(
        IRepository<TEntity> repository,
        IMapper mapper)
        where TEntity : class
        where TDto : class
        where TResponse : class
    {
        protected readonly IRepository<TEntity> _repository = repository;
        protected readonly IMapper _mapper = mapper;

        // Propiedades para configurar includes dinámicos
        protected List<Expression<Func<TEntity, object>>> _includes = new();
        protected Dictionary<string, List<string>> _relationFilters = new();

        // ============ NUEVO: DICCIONARIOS PARA VALIDACIONES ============
        protected Dictionary<string, Func<TDto, Task<bool>>> _validationRules = new();
        protected Dictionary<string, Func<TDto, int?, Task<bool>>> _validationRulesWithId = new();

        // ============ NUEVO: MÉTODOS DE VALIDACIÓN ============

        // Método para agregar regla de validación (para Add)
        public virtual GenericService<TEntity, TDto, TResponse> AddValidationRule(
            string ruleName,
            Func<TDto, Task<bool>> rule)
        {
            _validationRules[ruleName] = rule;
            return this;
        }

        // Método para agregar regla de validación con ID (para Update)
        public virtual GenericService<TEntity, TDto, TResponse> AddValidationRuleWithId(
            string ruleName,
            Func<TDto, int?, Task<bool>> rule)
        {
            _validationRulesWithId[ruleName] = rule;
            return this;
        }

        // Validación para agregar
        public virtual async Task<bool> CanAddAsync(TDto dto)
        {
            foreach (var rule in _validationRules.Values)
            {
                if (!await rule(dto))
                    return false;
            }
            return true;
        }

        // Validación para actualizar
        public virtual async Task<bool> CanUpdateAsync(int id, TDto dto)
        {
            foreach (var rule in _validationRulesWithId.Values)
            {
                if (!await rule(dto, id))
                    return false;
            }
            return true;
        }

        // Método para agregar includes dinámicamente
        public virtual GenericService<TEntity, TDto, TResponse> AddInclude(Expression<Func<TEntity, object>> includeExpression)
        {
            _includes.Add(includeExpression);
            return this;
        }

        // Método para agregar filtros en relaciones
        public virtual GenericService<TEntity, TDto, TResponse> AddRelationFilter(string relationProperty, List<string> searchProperties)
        {
            _relationFilters[relationProperty] = searchProperties;
            return this;
        }

        // Limpiar configuración
        public virtual void ClearConfiguration()
        {
            _includes.Clear();
            _relationFilters.Clear();
            _validationRules.Clear();
            _validationRulesWithId.Clear();
        }

        // Obtener query con includes configurados
        public virtual IQueryable<TEntity> GetQueryWithIncludes(Expression<Func<TEntity, bool>>? whereCondition = null)
        {
            if (whereCondition == null)
                whereCondition = x => true;

            return _includes.Any()
                ? _repository.QueryWithIncludes(whereCondition, _includes.ToArray())
                : _repository.QueryWithIncludes(whereCondition);
        }

        public virtual async Task<IEnumerable<TResponse>> GetAllAsync()
        {
            var query = GetQueryWithIncludes();
            var entities = await Task.Run(() => query.ToList());
            return _mapper.Map<IEnumerable<TResponse>>(entities);
        }

        public virtual async Task<TResponse?> GetByIdAsync(int id)
        {
            var query = GetQueryWithIncludes();

            // Obtener la propiedad ID de forma estática para la expresión
            var idProperty = typeof(TEntity).GetProperties()
                .FirstOrDefault(p => p.Name.Contains("Id", StringComparison.OrdinalIgnoreCase) &&
                                    (p.PropertyType == typeof(int) || p.PropertyType == typeof(int?)));

            if (idProperty == null)
                return null;

            // Construir la expresión lambda de forma estática
            var parameter = Expression.Parameter(typeof(TEntity), "e");
            var propertyAccess = Expression.Property(parameter, idProperty);
            var constant = Expression.Constant(id);

            Expression equality;
            if (idProperty.PropertyType == typeof(int?))
            {
                var convertedConstant = Expression.Convert(constant, typeof(int?));
                equality = Expression.Equal(propertyAccess, convertedConstant);
            }
            else
            {
                equality = Expression.Equal(propertyAccess, constant);
            }

            var lambda = Expression.Lambda<Func<TEntity, bool>>(equality, parameter);

            // Usar ToList() primero (menos eficiente pero funciona sin EF Core)
            var entities = await Task.Run(() => query.ToList());
            var entity = entities.FirstOrDefault(lambda.Compile());

            return entity != null ? _mapper.Map<TResponse>(entity) : null;
        }

        // Versión con parámetros personalizados - CORREGIDA
        public virtual async Task<TResponse?> GetByIdAsync(int id,
            Func<IQueryable<TEntity>, IQueryable<TEntity>>? customQuery = null,
            string idPropertyName = null)
        {
            var query = customQuery != null ? customQuery(GetQueryWithIncludes()) : GetQueryWithIncludes();

            PropertyInfo keyProperty;

            if (!string.IsNullOrEmpty(idPropertyName))
            {
                keyProperty = typeof(TEntity).GetProperty(idPropertyName);
                if (keyProperty == null)
                    return null;
            }
            else
            {
                keyProperty = typeof(TEntity).GetProperties()
                    .FirstOrDefault(p => p.Name.EndsWith("Id") ||
                                       p.Name.Equals("Id") ||
                                       p.Name.Equals($"{typeof(TEntity).Name}Id"));

                if (keyProperty == null)
                    return null;
            }

            var parameter = Expression.Parameter(typeof(TEntity), "e");
            var propertyAccess = Expression.Property(parameter, keyProperty);
            var constant = Expression.Constant(id);

            // Manejar propiedades nullable vs no nullable
            Expression equality;
            if (keyProperty.PropertyType == typeof(int?))
            {
                var convertedConstant = Expression.Convert(constant, typeof(int?));
                equality = Expression.Equal(propertyAccess, convertedConstant);
            }
            else
            {
                equality = Expression.Equal(propertyAccess, constant);
            }

            var lambda = Expression.Lambda<Func<TEntity, bool>>(equality, parameter);

            // CORRECCIÓN: Usar Task.Run con ToList() en lugar de FirstOrDefaultAsync
            var entities = await Task.Run(() => query.ToList());
            var entity = entities.FirstOrDefault(lambda.Compile());

            return entity != null ? _mapper.Map<TResponse>(entity) : null;
        }

        private int GetIdValue(TEntity entity)
        {
            var idProperty = typeof(TEntity).GetProperties()
                .FirstOrDefault(p => p.Name.Contains("Id", StringComparison.OrdinalIgnoreCase) &&
                                    (p.PropertyType == typeof(int) || p.PropertyType == typeof(int?)));

            if (idProperty != null)
            {
                return (int)idProperty.GetValue(entity);
            }

            var intProperty = typeof(TEntity).GetProperties()
                .FirstOrDefault(p => p.PropertyType == typeof(int) || p.PropertyType == typeof(int?));

            return intProperty != null ? (int)intProperty.GetValue(entity) : 0;
        }

        public virtual async Task AddAsync(TDto dto)
        {
            var entity = _mapper.Map<TEntity>(dto);
            await _repository.AddAsync(entity);

            // Mapear el ID de vuelta al DTO si es necesario
            var idProperty = typeof(TDto).GetProperty("PkidDepartamento") ??
                            typeof(TDto).GetProperty("Id") ??
                            typeof(TDto).GetProperties().FirstOrDefault(p => p.Name.Contains("Id"));

            if (idProperty != null)
            {
                var entityId = GetIdValue(entity);
                idProperty.SetValue(dto, entityId);
            }
        }

        public virtual async Task UpdateAsync(int id, TDto dto)
        {
            var existing = await _repository.GetByIdAsync(id);
            if (existing == null)
                throw new KeyNotFoundException($"Entidad con ID {id} no encontrada.");

            _mapper.Map(dto, existing);
            await _repository.UpdateAsync(existing);
        }

        public virtual async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"Entidad con ID {id} no encontrada.");

            await _repository.DeleteAsync(id);
        }

        public virtual async Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest _params)
        {
            try
            {
                var query = GetQueryWithIncludes();

                if (!string.IsNullOrWhiteSpace(_params.Filtro))
                {
                    query = ApplyFilterWithRelations(query, _params.Filtro);
                }

                query = ApplyOrdering(query, _params.SortLabel, _params.SortDirection);

                var totalCount = await Task.Run(() => query.Count());
                if (_params.Page < 1)
                    _params.Page = 1;

                var pagedQuery = query
                    .Skip((_params.Page - 1) * _params.PageSize)
                    .Take(_params.PageSize);

                var entities = await Task.Run(() => pagedQuery.ToList());
                var mapped = _mapper.Map<IList<TResponse>>(entities);

                return new PagedResult<TResponse>
                {
                    Items = mapped,
                    TotalCount = totalCount
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
            }
            return new PagedResult<TResponse>
            {
                Items = null,
                TotalCount = 0
            };
        }

        public virtual async Task<PagedResult<TResponse>> GetAllPaginadoAsync(
            PagedRequest _params,
            Expression<Func<TEntity, bool>> whereCondition)
        {
            var query = GetQueryWithIncludes(whereCondition);

            if (!string.IsNullOrWhiteSpace(_params.Filtro))
            {
                query = ApplyFilterWithRelations(query, _params.Filtro);
            }

            query = ApplyOrdering(query, _params.SortLabel, _params.SortDirection);

            var totalCount = await Task.Run(() => query.Count());
            if (_params.Page < 1)
                _params.Page = 1;

            var pagedQuery = query
                .Skip((_params.Page - 1) * _params.PageSize)
                .Take(_params.PageSize);

            var entities = await Task.Run(() => pagedQuery.ToList());
            var mapped = _mapper.Map<IList<TResponse>>(entities);

            return new PagedResult<TResponse>
            {
                Items = mapped,
                TotalCount = totalCount
            };
        }

        protected virtual IQueryable<TEntity> ApplyFilterWithRelations(IQueryable<TEntity> query, string filtro)
        {
            if (string.IsNullOrWhiteSpace(filtro))
                return query;

            var filtroLower = filtro.ToLower();
            var parameter = Expression.Parameter(typeof(TEntity), "x");
            Expression? finalExpression = null;

            var stringProperties = typeof(TEntity).GetProperties()
                .Where(p => p.PropertyType == typeof(string))
                .ToList();

            foreach (var prop in stringProperties)
            {
                var property = Expression.Property(parameter, prop);
                var constant = Expression.Constant(filtro);
                var containsMethod = typeof(string).GetMethod("Contains", new[] { typeof(string) });

                if (containsMethod != null)
                {
                    var containsExpression = Expression.Call(property, containsMethod, constant);
                    finalExpression = finalExpression == null
                        ? containsExpression
                        : Expression.OrElse(finalExpression, containsExpression);
                }
            }

            foreach (var relation in _relationFilters)
            {
                var relationProperty = typeof(TEntity).GetProperty(relation.Key);
                if (relationProperty != null)
                {
                    var relationAccess = Expression.Property(parameter, relationProperty);

                    foreach (var propName in relation.Value)
                    {
                        var relationProp = relationProperty.PropertyType.GetProperty(propName);
                        if (relationProp != null && relationProp.PropertyType == typeof(string))
                        {
                            var nestedProperty = Expression.Property(relationAccess, relationProp);
                            var constant = Expression.Constant(filtro);
                            var containsMethod = typeof(string).GetMethod("Contains", new[] { typeof(string) });

                            if (containsMethod != null)
                            {
                                var containsExpression = Expression.Call(nestedProperty, containsMethod, constant);
                                var notNullCheck = Expression.NotEqual(relationAccess, Expression.Constant(null));
                                var safeContains = Expression.AndAlso(notNullCheck, containsExpression);

                                finalExpression = finalExpression == null
                                    ? safeContains
                                    : Expression.OrElse(finalExpression, safeContains);
                            }
                        }
                    }
                }
            }

            if (finalExpression != null)
            {
                var lambda = Expression.Lambda<Func<TEntity, bool>>(finalExpression, parameter);
                return query.Where(lambda);
            }

            return query;
        }

        protected virtual IQueryable<TEntity> ApplyOrdering(IQueryable<TEntity> query, string sortLabel, string sortDirection)
        {
            if (string.IsNullOrWhiteSpace(sortLabel))
                return query;

            var propertyInfo = typeof(TEntity).GetProperty(sortLabel,
                System.Reflection.BindingFlags.IgnoreCase |
                System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.Instance);

            if (propertyInfo == null)
            {
                foreach (var relation in _relationFilters)
                {
                    var relationProperty = typeof(TEntity).GetProperty(relation.Key);
                    if (relationProperty != null && relation.Value.Contains(sortLabel))
                    {
                        return ApplyRelationOrdering(query, relation.Key, sortLabel, sortDirection);
                    }
                }
                return query;
            }

            var parameter = Expression.Parameter(typeof(TEntity), "x");
            var property = Expression.Property(parameter, propertyInfo);
            var lambda = Expression.Lambda(property, parameter);

            string methodName = sortDirection?.ToLower() == "desc" || sortDirection?.Contains("Descending") == true
                ? "OrderByDescending"
                : "OrderBy";

            var methodCallExpression = Expression.Call(
                typeof(Queryable),
                methodName,
                new Type[] { typeof(TEntity), propertyInfo.PropertyType },
                query.Expression,
                Expression.Quote(lambda));

            return query.Provider.CreateQuery<TEntity>(methodCallExpression);
        }

        protected virtual IQueryable<TEntity> ApplyRelationOrdering(IQueryable<TEntity> query, string relationName, string propertyName, string sortDirection)
        {
            try
            {
                var parameter = Expression.Parameter(typeof(TEntity), "x");
                var relationProperty = Expression.Property(parameter, relationName);
                var nestedProperty = Expression.Property(relationProperty, propertyName);
                var lambda = Expression.Lambda(nestedProperty, parameter);

                string methodName = sortDirection?.ToLower() == "desc" || sortDirection?.Contains("Descending") == true
                    ? "OrderByDescending"
                    : "OrderBy";

                var methodCallExpression = Expression.Call(
                    typeof(Queryable),
                    methodName,
                    new Type[] { typeof(TEntity), nestedProperty.Type },
                    query.Expression,
                    Expression.Quote(lambda));

                return query.Provider.CreateQuery<TEntity>(methodCallExpression);
            }
            catch
            {
                return query;
            }
        }
    }

    public class GenericService<TEntity, TDto>(
        IRepository<TEntity> repository,
        IMapper mapper) : GenericService<TEntity, TDto, TDto>(repository, mapper)
        where TEntity : class
        where TDto : class
    {
    }
}