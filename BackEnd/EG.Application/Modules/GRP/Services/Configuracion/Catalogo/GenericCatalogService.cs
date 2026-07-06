using Mapster;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;

namespace EG.Application.Modules.GRP.Services.Configuracion.Catalogo
{
    public abstract class GenericCatalogService<TEntity, TDto, TResponse>
        where TEntity : class
        where TDto : class
        where TResponse : class
    {
        protected readonly GenericService<TEntity, TDto, TResponse> Service;

        protected GenericCatalogService(GenericService<TEntity, TDto, TResponse> service)
        {
            Service = service;
        }

        public virtual async Task<TResponse?> GetByIdAsync(int id)
        {
            return await Service.GetByIdAsync(id);
        }

        public virtual async Task<TResponse> CreateAsync(TDto dto, int usuarioId)
        {
            SetProperty(dto, "UsuarioCreacion", usuarioId);
            SetProperty(dto, "FechaCreacion", DateTime.Now);
            SetProperty(dto, "Activo", true, onlyWhenDefault: true);

            await Service.AddAsync(dto);
            var id = GetIdValue(dto);
            var created = id > 0 ? await Service.GetByIdAsync(id) : null;
            return created ?? dto.Adapt<TResponse>();
        }

        public virtual async Task<TResponse?> UpdateAsync(int id, TDto dto, int usuarioId)
        {
            var existing = await Service.GetByIdAsync(id);
            if (existing == null)
            {
                return null;
            }

            SetIdValue(dto, id);
            SetProperty(dto, "UsuarioModificacion", usuarioId);
            SetProperty(dto, "FechaModificacion", DateTime.Now);

            await Service.UpdateAsync(id, dto);
            return await Service.GetByIdAsync(id);
        }

        public virtual async Task DeleteAsync(int id)
        {
            var existing = await Service.GetByIdAsync(id);
            if (existing == null)
            {
                throw new KeyNotFoundException($"Registro con ID {id} no encontrado");
            }

            await Service.DeleteAsync(id);
        }

        public virtual async Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await Service.GetAllPaginadoAsync(request);
            result.Code = result.Success ? "SUCCESS" : result.Code;
            result.Message = result.Success ? "OK" : result.Message;
            return result;
        }

        public virtual async Task<object> GetAllPaginadoAsync(
            int page,
            int pageSize,
            string? sortBy,
            string? sortDirection,
            string? filter)
        {
            var result = await GetAllPaginadoAsync(new PagedRequest
            {
                Page = page,
                PageSize = pageSize,
                SortLabel = sortBy,
                SortDirection = sortDirection,
                Filtro = filter
            });

            return new
            {
                Items = result.Items,
                result.TotalCount,
                Page = page,
                PageSize = pageSize
            };
        }

        protected virtual async Task<List<LookupItem>> GetLookupAsync(
            Func<TResponse, int> idSelector,
            Func<TResponse, string?> textSelector)
        {
            var items = await Service.GetAllAsync();
            return items
                .OrderBy(item => textSelector(item))
                .Select(item => new LookupItem
                {
                    Id = idSelector(item),
                    Text = textSelector(item) ?? string.Empty
                })
                .ToList();
        }

        protected virtual async Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(
            int page,
            int pageSize,
            string? filter,
            Func<TResponse, int> idSelector,
            Func<TResponse, string?> textSelector)
        {
            var result = await Service.GetAllPaginadoAsync(new PagedRequest
            {
                Page = page,
                PageSize = pageSize,
                Filtro = filter,
                SortLabel = "Descripcion",
                SortDirection = "asc"
            });

            return new PagedResult<LookupItem>
            {
                Success = result.Success,
                Message = result.Success ? "OK" : result.Message,
                Code = result.Success ? "SUCCESS" : result.Code,
                Items = result.Items
                    .Select(item => new LookupItem
                    {
                        Id = idSelector(item),
                        Text = textSelector(item) ?? string.Empty
                    })
                    .ToList(),
                TotalCount = result.TotalCount
            };
        }

        private static int GetIdValue(object source)
        {
            var property = FindIdProperty(source.GetType());
            var value = property?.GetValue(source);
            return value == null ? 0 : Convert.ToInt32(value);
        }

        private static void SetIdValue(object target, int id)
        {
            var property = FindIdProperty(target.GetType());
            if (property != null && property.CanWrite)
            {
                property.SetValue(target, Convert.ChangeType(id, Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType));
            }
        }

        private static System.Reflection.PropertyInfo? FindIdProperty(Type type)
        {
            return type.GetProperties()
                .FirstOrDefault(property =>
                    property.Name.StartsWith("Pkid", StringComparison.OrdinalIgnoreCase) ||
                    property.Name.Equals("Id", StringComparison.OrdinalIgnoreCase) ||
                    property.Name.Equals($"{type.Name}Id", StringComparison.OrdinalIgnoreCase));
        }

        private static void SetProperty(object target, string propertyName, object? value, bool onlyWhenDefault = false)
        {
            if (value == null)
            {
                return;
            }

            var property = target.GetType().GetProperty(
                propertyName,
                System.Reflection.BindingFlags.Instance |
                System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.IgnoreCase);
            if (property == null || !property.CanWrite)
            {
                return;
            }

            if (onlyWhenDefault)
            {
                var currentValue = property.GetValue(target);
                var targetType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
                if (currentValue != null && !currentValue.Equals(Activator.CreateInstance(targetType)))
                {
                    return;
                }
            }

            var propertyType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
            property.SetValue(target, Convert.ChangeType(value, propertyType));
        }
    }
}
