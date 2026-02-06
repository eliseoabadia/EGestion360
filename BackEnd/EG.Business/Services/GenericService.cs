using AutoMapper;
using EG.Application.CommonModel;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;
using System.Linq.Expressions;

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

        public virtual async Task<IEnumerable<TResponse>> GetAllAsync()
        {
            var entities = await _repository.GetAllAsync();
            return _mapper.Map<IEnumerable<TResponse>>(entities);
        }

        public virtual async Task<TResponse?> GetByIdAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            return entity != null ? _mapper.Map<TResponse>(entity) : null;
        }

        public virtual async Task AddAsync(TDto dto)
        {
            var entity = _mapper.Map<TEntity>(dto);
            await _repository.AddAsync(entity);
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
            // Obtener IQueryable - todos los registros
            var query = _repository.QueryWithIncludes(x => true);

            // Aplicar filtro si existe (método genérico que puede ser sobrescrito)
            if (!string.IsNullOrWhiteSpace(_params.Filtro))
            {
                query = ApplyFilter(query, _params.Filtro);
            }

            // Aplicar ordenamiento (método genérico que puede ser sobrescrito)
            query = ApplyOrdering(query, _params.SortLabel, _params.SortDirection);

            // Obtener total antes de paginar
            var totalCount = query.Count();
            if (_params.Page < 1)
                _params.Page = 1;

            // Aplicar paginación
            var pagedQuery = query
                .Skip((_params.Page - 1) * _params.PageSize)
                .Take(_params.PageSize);

            // Ejecutar la consulta y mapear
            var entities = pagedQuery.ToList();
            var mapped = _mapper.Map<IList<TResponse>>(entities);

            // Retornar resultado paginado
            return new PagedResult<TResponse>
            {
                Items = mapped,
                TotalCount = totalCount
            };
        }

        // Versión con filtro opcional
        public virtual async Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest _params, Expression<Func<TEntity, bool>> whereCondition)
        {
            // Obtener IQueryable con filtro
            var query = _repository.QueryWithIncludes(whereCondition);

            // Resto del código igual...
            if (!string.IsNullOrWhiteSpace(_params.Filtro))
            {
                query = ApplyFilter(query, _params.Filtro);
            }

            query = ApplyOrdering(query, _params.SortLabel, _params.SortDirection);

            var totalCount = query.Count();
            if (_params.Page < 1)
                _params.Page = 1;

            var pagedQuery = query
                .Skip((_params.Page - 1) * _params.PageSize)
                .Take(_params.PageSize);

            var entities = pagedQuery.ToList();
            var mapped = _mapper.Map<IList<TResponse>>(entities);

            return new PagedResult<TResponse>
            {
                Items = mapped,
                TotalCount = totalCount
            };
        }

        // Métodos virtuales para que las clases hijas puedan personalizar el comportamiento
        protected virtual IQueryable<TEntity> ApplyFilter(IQueryable<TEntity> query, string filtro)
        {
            if (string.IsNullOrWhiteSpace(filtro))
                return query;

            var stringProperties = typeof(TEntity).GetProperties()
                .Where(p => p.PropertyType == typeof(string))
                .ToList();

            if (!stringProperties.Any())
                return query;

            // Crear expresión dinámica para filtrado
            var parameter = Expression.Parameter(typeof(TEntity), "x");
            Expression? finalExpression = null;

            foreach (var prop in stringProperties)
            {
                var property = Expression.Property(parameter, prop);
                var constant = Expression.Constant(filtro);
                var containsMethod = typeof(string).GetMethod("Contains", new[] { typeof(string) });

                if (containsMethod != null)
                {
                    var containsExpression = Expression.Call(property, containsMethod, constant);

                    if (finalExpression == null)
                        finalExpression = containsExpression;
                    else
                        finalExpression = Expression.OrElse(finalExpression, containsExpression);
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

            // Verificar si la propiedad existe
            var propertyInfo = typeof(TEntity).GetProperty(sortLabel,
                System.Reflection.BindingFlags.IgnoreCase |
                System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.Instance);

            if (propertyInfo == null)
                return query;

            var parameter = Expression.Parameter(typeof(TEntity), "x");
            var property = Expression.Property(parameter, propertyInfo);
            var lambda = Expression.Lambda(property, parameter);

            string methodName = sortDirection.Contains("Descending") ? "OrderByDescending" : "OrderBy";

            var methodCallExpression = Expression.Call(
                typeof(Queryable),
                methodName,
                new Type[] { typeof(TEntity), propertyInfo.PropertyType },
                query.Expression,
                Expression.Quote(lambda));

            return query.Provider.CreateQuery<TEntity>(methodCallExpression);
        }
    }

    // Versión simplificada para casos comunes (TDto y TResponse son el mismo tipo)
    public class GenericService<TEntity, TDto>(
        IRepository<TEntity> repository,
        IMapper mapper) : GenericService<TEntity, TDto, TDto>(repository, mapper)
        where TEntity : class
        where TDto : class
    {
    }
}