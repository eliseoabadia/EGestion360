using System.Reflection;
using Mapster;
using EG.Business.Services;
using EG.Common.GenericModel;

namespace EG.Application.Services.Adquisicion
{
    public abstract class AdquisicionCrudAppService<TEntity, TView, TDto, TResponse>
        where TEntity : class
        where TView : class
        where TDto : class
        where TResponse : class
    {
        protected readonly GenericService<TEntity, TDto, TResponse> _service;
        protected readonly GenericService<TView, TDto, TResponse> _serviceView;
        private readonly string _idPropertyName;
        private readonly string _entityName;
        private readonly Action<TDto, int> _setId;

        protected AdquisicionCrudAppService(
            GenericService<TEntity, TDto, TResponse> service,
            GenericService<TView, TDto, TResponse> serviceView,
            string idPropertyName,
            string entityName,
            Action<TDto, int> setId)
        {
            _service = service;
            _serviceView = serviceView;
            _idPropertyName = idPropertyName;
            _entityName = entityName;
            _setId = setId;
        }

        public virtual async Task<PagedResult<TResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            var items = result.ToList();

            return new PagedResult<TResponse>
            {
                Success = true,
                Message = $"{_entityName} obtenidos correctamente",
                Code = "SUCCESS",
                Items = items,
                TotalCount = items.Count
            };
        }

        public virtual async Task<PagedResult<TResponse>> GetByIdAsync(int id)
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: _idPropertyName);

            if (result == null)
            {
                return NotFound(id);
            }

            return new PagedResult<TResponse>
            {
                Success = true,
                Message = $"{_entityName} encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<TResponse> { result },
                TotalCount = 1
            };
        }

        public virtual async Task<PagedResult<TResponse>> CreateAsync(TResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<TDto>();
                SetProperty(dto, "UsuarioCreacion", usuarioActual);
                SetProperty(dto, "FechaCreacion", DateTime.Now);
                SetProperty(dto, "Activo", true);

                await _service.AddAsync(dto);

                return new PagedResult<TResponse>
                {
                    Success = true,
                    Message = $"{_entityName} creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TResponse>
                {
                    Success = false,
                    Message = $"Error al crear {_entityName}: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public virtual async Task<PagedResult<TResponse>> UpdateAsync(int id, TResponse response, int usuarioActual)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id, idPropertyName: _idPropertyName);
                if (existing == null)
                {
                    return NotFound(id);
                }

                var dto = response.Adapt<TDto>();
                _setId(dto, id);
                CopyProperty(existing, dto, "UsuarioCreacion");
                CopyProperty(existing, dto, "FechaCreacion");
                SetProperty(dto, "UsuarioModificacion", usuarioActual);
                SetProperty(dto, "FechaModificacion", DateTime.Now);

                await _service.UpdateAsync(id, dto);

                return new PagedResult<TResponse>
                {
                    Success = true,
                    Message = $"{_entityName} actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return NotFound(id);
            }
            catch (Exception ex)
            {
                return new PagedResult<TResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar {_entityName}: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public virtual async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                await _service.DeleteAsync(id);

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = $"{_entityName} eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"{_entityName} con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar {_entityName}: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public virtual async Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _serviceView.GetAllPaginadoAsync(request);

            return new PagedResult<TResponse>
            {
                Success = result.Success,
                Message = result.Success ? $"{_entityName} obtenidos correctamente" : $"Error al obtener {_entityName}",
                Code = result.Success ? "SUCCESS" : "ERROR",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        private PagedResult<TResponse> NotFound(int id)
        {
            return new PagedResult<TResponse>
            {
                Success = false,
                Message = $"{_entityName} con ID {id} no encontrado",
                Code = "NOT_FOUND",
                TotalCount = 0
            };
        }

        private static void CopyProperty(object source, object target, string propertyName)
        {
            var sourceProperty = source.GetType().GetProperty(propertyName, BindingFlags.Instance | BindingFlags.Public);
            if (sourceProperty == null)
            {
                return;
            }

            SetProperty(target, propertyName, sourceProperty.GetValue(source));
        }

        private static void SetProperty(object target, string propertyName, object? value)
        {
            var property = target.GetType().GetProperty(propertyName, BindingFlags.Instance | BindingFlags.Public);
            if (property == null || !property.CanWrite)
            {
                return;
            }

            if (value == null)
            {
                property.SetValue(target, null);
                return;
            }

            var targetType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
            var convertedValue = targetType.IsInstanceOfType(value)
                ? value
                : Convert.ChangeType(value, targetType);

            property.SetValue(target, convertedValue);
        }
    }
}
