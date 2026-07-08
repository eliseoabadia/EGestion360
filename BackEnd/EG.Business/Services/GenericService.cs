using Mapster;
using EG.Common;
using EG.Common.GenericModel;
using EG.Domain.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System.Globalization;
using System.Linq;
using System.Linq.Expressions;
using System.Reflection;
using System.Text.Json;

namespace EG.Business.Services
{
    public class GenericService<TEntity, TDto, TResponse>(
        IRepository<TEntity> repository,
        IUserContextService? userContext = null,
        ILogger<GenericService<TEntity, TDto, TResponse>>? logger = null)
        where TEntity : class
        where TDto : class
        where TResponse : class
    {
        protected readonly IRepository<TEntity> _repository = repository;
        protected readonly IUserContextService? _userContext = userContext;
        protected readonly ILogger<GenericService<TEntity, TDto, TResponse>>? _logger = logger;
        private const int DefaultPageSize = 10;
        private const int MaxPageSize = 250;

        private static readonly string[] EmpresaPropertyCandidates =
        [
            "FkidEmpresaSis",
            "FKIdEmpresaSIS",
            "FKIdEmpresa_SIS",
            "IdEmpresa",
            "EmpresaId",
            "PkidEmpresa",
            "PKIdEmpresa",
            "PkIdEmpresa"
        ];

        // Propiedad para habilitar/deshabilitar filtro de Activo
        protected bool FilterByActivo { get; set; } = true;

        // Propiedad para habilitar/deshabilitar filtro de empresa del usuario autenticado
        protected bool FilterByEmpresa { get; set; } = true;

        // Propiedades para configurar includes din�micos
        protected List<Expression<Func<TEntity, object>>> _includes = new();
        protected Dictionary<string, List<string>> _relationFilters = new();
        protected List<string> _searchFilterProperties = new();

        // ============ NUEVO: DICCIONARIOS PARA VALIDACIONES ============
        protected Dictionary<string, Func<TDto, Task<bool>>> _validationRules = new();
        protected Dictionary<string, Func<TDto, int?, Task<bool>>> _validationRulesWithId = new();

        // ============ NUEVO: M�TODOS DE VALIDACI�N ============

        // M�todo para agregar regla de validaci�n (para Add)
        public virtual GenericService<TEntity, TDto, TResponse> AddValidationRule(
            string ruleName,
            Func<TDto, Task<bool>> rule)
        {
            _validationRules[ruleName] = rule;
            return this;
        }

        // M�todo para agregar regla de validaci�n con ID (para Update)
        public virtual GenericService<TEntity, TDto, TResponse> AddValidationRuleWithId(
            string ruleName,
            Func<TDto, int?, Task<bool>> rule)
        {
            _validationRulesWithId[ruleName] = rule;
            return this;
        }

        // Validaci�n para agregar
        public virtual async Task<bool> CanAddAsync(TDto dto)
        {
            foreach (var rule in _validationRules.Values)
            {
                if (!await rule(dto))
                    return false;
            }
            return true;
        }

        // Validaci�n para actualizar
        public virtual async Task<bool> CanUpdateAsync(int id, TDto dto)
        {
            foreach (var rule in _validationRulesWithId.Values)
            {
                if (!await rule(dto, id))
                    return false;
            }
            return true;
        }

        // M�todo para agregar includes din�micamente
        public virtual GenericService<TEntity, TDto, TResponse> AddInclude(Expression<Func<TEntity, object>> includeExpression)
        {
            _includes.Add(includeExpression);
            return this;
        }

        // M�todo para agregar filtros en relaciones
        public virtual GenericService<TEntity, TDto, TResponse> AddRelationFilter(string relationProperty, List<string> searchProperties)
        {
            _relationFilters[relationProperty] = searchProperties;
            return this;
        }

        // Limpiar configuraci�n
        public virtual GenericService<TEntity, TDto, TResponse> AddSearchFilter(params string[] propertyNames)
        {
            foreach (var propertyName in propertyNames)
            {
                if (string.IsNullOrWhiteSpace(propertyName))
                {
                    continue;
                }

                var cleanPropertyName = propertyName.Trim();
                if (!_searchFilterProperties.Contains(cleanPropertyName, StringComparer.OrdinalIgnoreCase))
                {
                    _searchFilterProperties.Add(cleanPropertyName);
                }
            }

            return this;
        }

        public virtual void ClearConfiguration()
        {
            _includes.Clear();
            _relationFilters.Clear();
            _searchFilterProperties.Clear();
            _validationRules.Clear();
            _validationRulesWithId.Clear();
        }

        public virtual GenericService<TEntity, TDto, TResponse> DisableEmpresaFilter()
        {
            FilterByEmpresa = false;
            return this;
        }

        public virtual GenericService<TEntity, TDto, TResponse> DisableActivoFilter()
        {
            FilterByActivo = false;
            return this;
        }

        // Obtener query con includes configurados
        public virtual IQueryable<TEntity> GetQueryWithIncludes(Expression<Func<TEntity, bool>>? whereCondition = null)
        {
            IQueryable<TEntity> query = _includes.Any()
                ? _repository.QueryWithIncludes(x => true, _includes.ToArray())
                : _repository.QueryWithIncludes(x => true);

            if (FilterByActivo)
            {
                query = ApplyActivoFilter(query);
            }

            if (FilterByEmpresa)
            {
                query = ApplyEmpresaFilter(query);
            }

            if (whereCondition != null)
            {
                query = query.Where(whereCondition);
            }

            return query;
        }

        private IQueryable<TEntity> ApplyEmpresaFilter(IQueryable<TEntity> query)
        {
            var empresaId = _userContext?.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
            {
                return query;
            }

            var empresaProperty = GetEmpresaProperty(typeof(TEntity));
            if (empresaProperty == null || !IsSupportedEmpresaProperty(empresaProperty.PropertyType))
            {
                return query;
            }

            var parameter = Expression.Parameter(typeof(TEntity), "e");
            var propertyAccess = Expression.Property(parameter, empresaProperty);
            var targetType = Nullable.GetUnderlyingType(empresaProperty.PropertyType) ?? empresaProperty.PropertyType;
            var convertedEmpresaId = Convert.ChangeType(empresaId.Value, targetType, CultureInfo.InvariantCulture);
            var constant = Expression.Constant(convertedEmpresaId, targetType);
            Expression comparisonValue = empresaProperty.PropertyType == targetType
                ? constant
                : Expression.Convert(constant, empresaProperty.PropertyType);
            var condition = Expression.Equal(propertyAccess, comparisonValue);
            var lambda = Expression.Lambda<Func<TEntity, bool>>(condition, parameter);

            return query.Where(lambda);
        }

        private static PropertyInfo? GetEmpresaProperty(Type type)
        {
            foreach (var candidate in EmpresaPropertyCandidates)
            {
                var property = type.GetProperty(
                    candidate,
                    BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);

                if (property != null)
                {
                    return property;
                }
            }

            return null;
        }

        private static bool IsSupportedEmpresaProperty(Type propertyType)
        {
            var targetType = Nullable.GetUnderlyingType(propertyType) ?? propertyType;
            return targetType == typeof(int) || targetType == typeof(long) || targetType == typeof(short);
        }

        public virtual void ApplyCurrentEmpresaIfPresent(object? target)
        {
            if (!FilterByEmpresa)
            {
                return;
            }

            if (target == null)
            {
                return;
            }

            var empresaId = _userContext?.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
            {
                return;
            }

            var empresaProperty = GetEmpresaProperty(target.GetType());
            if (empresaProperty == null || !empresaProperty.CanWrite || !IsSupportedEmpresaProperty(empresaProperty.PropertyType))
            {
                return;
            }

            var targetType = Nullable.GetUnderlyingType(empresaProperty.PropertyType) ?? empresaProperty.PropertyType;
            var convertedEmpresaId = Convert.ChangeType(empresaId.Value, targetType, CultureInfo.InvariantCulture);
            empresaProperty.SetValue(target, convertedEmpresaId);
        }

        private bool BelongsToCurrentEmpresa(object? entity)
        {
            if (!FilterByEmpresa)
            {
                return true;
            }

            if (entity == null)
            {
                return false;
            }

            var empresaId = _userContext?.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
            {
                return true;
            }

            var empresaProperty = GetEmpresaProperty(entity.GetType());
            if (empresaProperty == null || !IsSupportedEmpresaProperty(empresaProperty.PropertyType))
            {
                return true;
            }

            var value = empresaProperty.GetValue(entity);
            if (value == null)
            {
                return false;
            }

            var entityEmpresaId = Convert.ToInt64(value, CultureInfo.InvariantCulture);
            return entityEmpresaId == empresaId.Value;
        }

        private IQueryable<TEntity> ApplyActivoFilter(IQueryable<TEntity> query)
        {
            var activoProperty = typeof(TEntity).GetProperty("Activo");
            if (activoProperty != null && activoProperty.PropertyType == typeof(bool))
            {
                var parametro = Expression.Parameter(typeof(TEntity), "e");
                var propertyAccess = Expression.Property(parametro, activoProperty);
                var condition = Expression.Equal(propertyAccess, Expression.Constant(true, typeof(bool)));
                var lambda = Expression.Lambda<Func<TEntity, bool>>(condition, parametro);
                query = query.Where(lambda);
            }
            return query;
        }

        public virtual async Task<IEnumerable<TResponse>> GetAllAsync()
        {
            var query = GetQueryWithIncludes();
            var entities = await query.ToListAsync();
            return entities.Adapt<IEnumerable<TResponse>>();
        }

        public virtual async Task<TResponse?> GetByIdAsync(int id)
        {
            var query = GetQueryWithIncludes();

            // Obtener la propiedad ID de forma est�tica para la expresi�n
            var idProperty = typeof(TEntity).GetProperties()
                .FirstOrDefault(p => p.Name.Contains("Id", StringComparison.OrdinalIgnoreCase) &&
                                    (p.PropertyType == typeof(int) || p.PropertyType == typeof(int?)));

            if (idProperty == null)
                return null;

            // Construir la expresi�n lambda de forma est�tica
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

            var entity = await query.FirstOrDefaultAsync(lambda);

            return entity != null ? entity.Adapt<TResponse>() : null;
        }

        // Versi�n con par�metros personalizados - CORREGIDA
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

            var entity = await query.FirstOrDefaultAsync(lambda);

            return entity != null ? entity.Adapt<TResponse>() : null;
        }

        private int GetIdValue(TEntity entity)
        {
            // First try to find Pkid* properties (primary keys)
            var pkidProperty = typeof(TEntity).GetProperties()
                .FirstOrDefault(p => p.Name.StartsWith("Pkid") && 
                                    (p.PropertyType == typeof(int) || p.PropertyType == typeof(int?)));

            if (pkidProperty != null)
            {
                return pkidProperty.GetValue(entity) as int? ?? 0;
            }

            // Fallback to properties ending with "Id"
            var idProperty = typeof(TEntity).GetProperties()
                .FirstOrDefault(p => p.Name.EndsWith("Id", StringComparison.OrdinalIgnoreCase) &&
                                    !p.Name.StartsWith("Fk") &&
                                    (p.PropertyType == typeof(int) || p.PropertyType == typeof(int?)));

            if (idProperty != null)
            {
                return idProperty.GetValue(entity) as int? ?? 0;
            }

            var intProperty = typeof(TEntity).GetProperties()
                .FirstOrDefault(p => p.PropertyType == typeof(int) || p.PropertyType == typeof(int?));

            var value = intProperty?.GetValue(entity) as int?;
            return value ?? 0;
        }

        public virtual async Task AddAsync(TDto dto)
        {
            ApplyCreationAuditIfPresent(dto);
            ApplyCurrentEmpresaIfPresent(dto);
            var entity = dto.Adapt<TEntity>();
            ApplyCreationAuditIfPresent(entity);
            ApplyCurrentEmpresaIfPresent(entity);
            await _repository.AddAsync(entity);

            // Mapear el ID de vuelta al DTO si es necesario
            var idProperty = typeof(TDto).GetProperty("PkidDepartamento") ??
                            typeof(TDto).GetProperty("PkidPeriodoConteo") ??
                            typeof(TDto).GetProperty("PkidBien") ??
                            typeof(TDto).GetProperty("Id") ??
                            typeof(TDto).GetProperties().FirstOrDefault(p => p.Name.StartsWith("Pkid"));

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
            if (!BelongsToCurrentEmpresa(existing))
                throw new KeyNotFoundException($"Entidad con ID {id} no encontrada.");

            ApplyCurrentEmpresaIfPresent(dto);
            EntityUpdateMapper.Apply(dto, existing);
            ApplyModificationAuditIfPresent(existing);
            ApplyCurrentEmpresaIfPresent(existing);
            await _repository.UpdateAsync(existing);
        }

        public virtual async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"Entidad con ID {id} no encontrada.");
            if (!BelongsToCurrentEmpresa(entity))
                throw new KeyNotFoundException($"Entidad con ID {id} no encontrada.");

            await _repository.SoftDeleteAsync(id);
        }

        private void ApplyCreationAuditIfPresent(object target)
        {
            SetPropertyIfPresent(target, "Activo", true, onlyWhenDefault: true);
            SetPropertyIfPresent(target, "UsuarioCreacion", _userContext?.TryGetCurrentUserId(), onlyWhenDefault: true);
            SetPropertyIfPresent(target, "FechaCreacion", DateTime.Now, onlyWhenDefault: true);
        }

        private void ApplyModificationAuditIfPresent(object target)
        {
            SetPropertyIfPresent(target, "UsuarioModificacion", _userContext?.TryGetCurrentUserId(), onlyWhenDefault: false);
            SetPropertyIfPresent(target, "FechaModificacion", DateTime.Now, onlyWhenDefault: false);
        }

        private static void SetPropertyIfPresent(object target, string propertyName, object? value, bool onlyWhenDefault)
        {
            if (value == null)
            {
                return;
            }

            var property = target.GetType().GetProperty(
                propertyName,
                BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
            if (property == null || !property.CanWrite)
            {
                return;
            }

            if (onlyWhenDefault && !IsDefaultValue(property.GetValue(target), property.PropertyType))
            {
                return;
            }

            var targetType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
            var convertedValue = targetType.IsInstanceOfType(value)
                ? value
                : Convert.ChangeType(value, targetType, CultureInfo.InvariantCulture);
            property.SetValue(target, convertedValue);
        }

        private static bool IsDefaultValue(object? value, Type propertyType)
        {
            if (value == null)
            {
                return true;
            }

            var targetType = Nullable.GetUnderlyingType(propertyType) ?? propertyType;
            if (targetType == typeof(string))
            {
                return string.IsNullOrWhiteSpace(value as string);
            }

            return value.Equals(Activator.CreateInstance(targetType));
        }

        public virtual async Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest _params)
        {
            try
            {
                NormalizePaging(_params);
                var query = GetQueryWithIncludes();
                var searchTerm = ResolveSearchTerm(_params);

                if (!string.IsNullOrWhiteSpace(searchTerm))
                {
                    query = ApplyFilterWithRelations(query, searchTerm);
                }

                // 2. Aplicar filtros adicionales del diccionario
                if (_params.AdditionalFilters != null && _params.AdditionalFilters.Any())
                {
                    foreach (var filter in _params.AdditionalFilters)
                    {
                        string propertyName = filter.Key;
                        object? value = filter.Value;

                        if (value == null) continue;

                        query = ApplyAdditionalFilter(query, propertyName, value);
                    }
                }

                query = ApplyOrdering(query, _params.SortLabel, _params.SortDirection);

                var totalCount = await query.CountAsync();

                var pagedQuery = query
                    .Skip((_params.Page - 1) * _params.PageSize)
                    .Take(_params.PageSize);

                var entities = await pagedQuery.ToListAsync();
                var mapped = entities.Adapt<IList<TResponse>>();

                return new PagedResult<TResponse>
                {
                    Items = mapped,
                    TotalCount = totalCount,
                    Success = true
                };
            }
            catch (Exception ex)
            {
                _logger?.LogError(ex, "Error en GetAllPaginado para {Entity}", typeof(TEntity).Name);
            }
            return new PagedResult<TResponse>
            {
                TotalCount = 0,
                Success = false,
                Message = UserFacingMessages.UnexpectedError
            };
        }

        private IQueryable<TEntity> ApplyAdditionalFilter(IQueryable<TEntity> query, string propertyName, object value)
        {
            const string notEqualSuffix = "__ne";
            var useNotEqual = propertyName.EndsWith(notEqualSuffix, StringComparison.OrdinalIgnoreCase);
            if (useNotEqual)
            {
                propertyName = propertyName[..^notEqualSuffix.Length];
            }

            var parameter = Expression.Parameter(typeof(TEntity), "x");
            var property = Expression.Property(parameter, propertyName);
            var propertyType = property.Type;
            var targetType = Nullable.GetUnderlyingType(propertyType) ?? propertyType;

            object convertedValue;
            if (value is JsonElement jsonElement)
            {
                // Convert JsonElement to the target property type
                convertedValue = ConvertJsonElement(jsonElement, targetType);
            }
            else
            {
                // Try direct conversion
                convertedValue = Convert.ChangeType(value, targetType, CultureInfo.InvariantCulture);
            }

            Expression left = useNotEqual && propertyType == typeof(string)
                ? Expression.Call(property, typeof(string).GetMethod(nameof(string.Trim), Type.EmptyTypes)!)
                : property;
            Expression constant = Expression.Constant(convertedValue, targetType);
            if (left.Type != targetType)
            {
                constant = Expression.Convert(constant, left.Type);
            }

            var comparison = useNotEqual
                ? Expression.NotEqual(left, constant)
                : Expression.Equal(left, constant);
            var lambda = Expression.Lambda<Func<TEntity, bool>>(comparison, parameter);
            return query.Where(lambda);
        }

        private object ConvertJsonElement(JsonElement jsonElement, Type targetType)
        {
            // Handle nullable types
            var underlyingType = Nullable.GetUnderlyingType(targetType) ?? targetType;

            if (underlyingType == typeof(int))
                return jsonElement.GetInt32();
            if (underlyingType == typeof(long))
                return jsonElement.GetInt64();
            if (underlyingType == typeof(decimal))
                return jsonElement.GetDecimal();
            if (underlyingType == typeof(double))
                return jsonElement.GetDouble();
            if (underlyingType == typeof(float))
                return jsonElement.GetSingle();
            if (underlyingType == typeof(string))
                return jsonElement.GetString();
            if (underlyingType == typeof(bool))
                return jsonElement.GetBoolean();
            if (underlyingType == typeof(DateTime))
                return jsonElement.GetDateTime();
            if (underlyingType == typeof(Guid))
                return jsonElement.GetGuid();
            // For other types, try to get the raw text and parse or convert
            // Alternatively, use JsonSerializer.Deserialize
            return JsonSerializer.Deserialize(jsonElement.GetRawText(), underlyingType);
        }

        public virtual async Task<PagedResult<TResponse>> GetAllPaginadoAsync(
            PagedRequest _params,
            Expression<Func<TEntity, bool>> whereCondition)
        {
            NormalizePaging(_params);
            var query = GetQueryWithIncludes(whereCondition);
            var searchTerm = ResolveSearchTerm(_params);

            if (!string.IsNullOrWhiteSpace(searchTerm))
            {
                query = ApplyFilterWithRelations(query, searchTerm);
            }

            query = ApplyOrdering(query, _params.SortLabel, _params.SortDirection);

            var totalCount = await query.CountAsync();

            var pagedQuery = query
                .Skip((_params.Page - 1) * _params.PageSize)
                .Take(_params.PageSize);

            var entities = await pagedQuery.ToListAsync();
            var mapped = entities.Adapt<IList<TResponse>>();

            return new PagedResult<TResponse>
            {
                Items = mapped,
                TotalCount = totalCount,
                Success = true
            };
        }

        private static void NormalizePaging(PagedRequest request)
        {
            if (request.Page < 1)
            {
                request.Page = 1;
            }

            var requestedPageSize = request.PageSize <= 0 ? DefaultPageSize : request.PageSize;
            request.PageSize = Math.Clamp(requestedPageSize, 1, MaxPageSize);
        }

        private static string ResolveSearchTerm(PagedRequest request)
        {
            var searchTerm = string.IsNullOrWhiteSpace(request.Filtro)
                ? request.SearchString
                : request.Filtro;

            return searchTerm?.Trim() ?? string.Empty;
        }

        protected virtual IQueryable<TEntity> ApplyFilterWithRelations(IQueryable<TEntity> query, string filtro)
        {
            if (string.IsNullOrWhiteSpace(filtro))
                return query;

            var cleanFilter = filtro.Trim();
            var parameter = Expression.Parameter(typeof(TEntity), "x");
            Expression? finalExpression = null;

            var properties = _searchFilterProperties.Count > 0
                ? _searchFilterProperties
                    .Select(GetSearchProperty)
                    .Where(p => p != null)
                    .Cast<PropertyInfo>()
                    .ToList()
                : typeof(TEntity).GetProperties()
                    .Where(IsDefaultSearchProperty)
                    .ToList();

            foreach (var prop in properties)
            {
                var searchExpression = BuildSearchExpression(parameter, prop, cleanFilter);
                if (searchExpression == null)
                {
                    continue;
                }

                finalExpression = finalExpression == null
                    ? searchExpression
                    : Expression.OrElse(finalExpression, searchExpression);
            }

            foreach (var relation in _relationFilters)
            {
                var relationProperty = typeof(TEntity).GetProperty(relation.Key);
                if (relationProperty == null)
                {
                    continue;
                }

                var relationAccess = Expression.Property(parameter, relationProperty);
                var relationNotNull = Expression.NotEqual(relationAccess, Expression.Constant(null, relationProperty.PropertyType));

                foreach (var propName in relation.Value)
                {
                    var relationProp = relationProperty.PropertyType.GetProperty(propName);
                    if (relationProp == null)
                    {
                        continue;
                    }

                    var searchExpression = BuildSearchExpression(relationAccess, relationProp, cleanFilter);
                    if (searchExpression == null)
                    {
                        continue;
                    }

                    var safeSearchExpression = Expression.AndAlso(relationNotNull, searchExpression);
                    finalExpression = finalExpression == null
                        ? safeSearchExpression
                        : Expression.OrElse(finalExpression, safeSearchExpression);
                }
            }

            if (finalExpression != null)
            {
                var lambda = Expression.Lambda<Func<TEntity, bool>>(finalExpression, parameter);
                return query.Where(lambda);
            }

            return query;
        }

        private static bool IsDefaultSearchProperty(PropertyInfo property)
        {
            var normalizedName = property.Name.ToLowerInvariant();
            if (normalizedName.Contains("empresa", StringComparison.Ordinal)
                || normalizedName.Contains("anio", StringComparison.Ordinal)
                || normalizedName.Contains("año", StringComparison.Ordinal)
                || normalizedName.Contains("sucursal", StringComparison.Ordinal)
                || normalizedName.Contains("moneda", StringComparison.Ordinal)
                || normalizedName.Contains("activo", StringComparison.Ordinal)
                || normalizedName.Contains("estatusregistro", StringComparison.Ordinal)
                || normalizedName.Contains("fechacreacion", StringComparison.Ordinal)
                || normalizedName.Contains("fechamodificacion", StringComparison.Ordinal)
                || normalizedName.Contains("usuariocreacion", StringComparison.Ordinal)
                || normalizedName.Contains("usuariomodificacion", StringComparison.Ordinal)
                || normalizedName.EndsWith("format", StringComparison.Ordinal)
                || normalizedName.Contains("json", StringComparison.Ordinal))
            {
                return false;
            }

            if (normalizedName.StartsWith("fk", StringComparison.Ordinal)
                || normalizedName.StartsWith("idempresa", StringComparison.Ordinal)
                || normalizedName.StartsWith("idsucursal", StringComparison.Ordinal)
                || normalizedName.StartsWith("idanio", StringComparison.Ordinal)
                || normalizedName.StartsWith("idmoneda", StringComparison.Ordinal))
            {
                return false;
            }

            var targetType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
            if (targetType == typeof(string))
            {
                return true;
            }

            if (targetType == typeof(int)
                || targetType == typeof(long)
                || targetType == typeof(short)
                || targetType == typeof(decimal)
                || targetType == typeof(double)
                || targetType == typeof(float)
                || targetType == typeof(Guid))
            {
                return normalizedName.StartsWith("pk", StringComparison.Ordinal)
                    || normalizedName.EndsWith("id", StringComparison.Ordinal)
                    || normalizedName.Contains("clave", StringComparison.Ordinal)
                    || normalizedName.Contains("codigo", StringComparison.Ordinal)
                    || normalizedName.Contains("numero", StringComparison.Ordinal)
                    || normalizedName.Contains("folio", StringComparison.Ordinal);
            }

            return false;
        }

        private static Expression? BuildSearchExpression(Expression instance, PropertyInfo property, string filter)
        {
            var propertyType = property.PropertyType;
            var targetType = Nullable.GetUnderlyingType(propertyType) ?? propertyType;
            var propertyAccess = Expression.Property(instance, property);

            if (targetType == typeof(string))
            {
                var notNullCheck = Expression.NotEqual(propertyAccess, Expression.Constant(null, propertyType));
                var containsMethod = typeof(string).GetMethod(nameof(string.Contains), new[] { typeof(string) });
                if (containsMethod == null)
                {
                    return null;
                }

                var containsExpression = Expression.Call(propertyAccess, containsMethod, Expression.Constant(filter));
                return Expression.AndAlso(notNullCheck, containsExpression);
            }

            if (!TryConvertSearchValue(filter, targetType, out var convertedValue))
            {
                return null;
            }

            var constant = Expression.Constant(convertedValue, targetType);
            if (Nullable.GetUnderlyingType(propertyType) != null)
            {
                var hasValue = Expression.Property(propertyAccess, nameof(Nullable<int>.HasValue));
                var value = Expression.Property(propertyAccess, nameof(Nullable<int>.Value));
                return Expression.AndAlso(hasValue, Expression.Equal(value, constant));
            }

            return Expression.Equal(propertyAccess, constant);
        }

        private static bool TryConvertSearchValue(string filter, Type targetType, out object? value)
        {
            value = null;
            if (targetType == typeof(int) && int.TryParse(filter, NumberStyles.Integer, CultureInfo.InvariantCulture, out var intValue))
            {
                value = intValue;
                return true;
            }

            if (targetType == typeof(long) && long.TryParse(filter, NumberStyles.Integer, CultureInfo.InvariantCulture, out var longValue))
            {
                value = longValue;
                return true;
            }

            if (targetType == typeof(short) && short.TryParse(filter, NumberStyles.Integer, CultureInfo.InvariantCulture, out var shortValue))
            {
                value = shortValue;
                return true;
            }

            if (targetType == typeof(decimal) && decimal.TryParse(filter, NumberStyles.Number, CultureInfo.InvariantCulture, out var decimalValue))
            {
                value = decimalValue;
                return true;
            }

            if (targetType == typeof(double) && double.TryParse(filter, NumberStyles.Number, CultureInfo.InvariantCulture, out var doubleValue))
            {
                value = doubleValue;
                return true;
            }

            if (targetType == typeof(float) && float.TryParse(filter, NumberStyles.Number, CultureInfo.InvariantCulture, out var floatValue))
            {
                value = floatValue;
                return true;
            }

            if (targetType == typeof(Guid) && Guid.TryParse(filter, out var guidValue))
            {
                value = guidValue;
                return true;
            }

            return false;
        }

        private static PropertyInfo? GetSearchProperty(string propertyName)
        {
            return typeof(TEntity).GetProperty(
                propertyName,
                BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
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
        IUserContextService? userContext = null,
        ILogger<GenericService<TEntity, TDto, TDto>>? logger = null)
        : GenericService<TEntity, TDto, TDto>(repository, userContext, logger)
        where TEntity : class
        where TDto : class
    {
    }
}
