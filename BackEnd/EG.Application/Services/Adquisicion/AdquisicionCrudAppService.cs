using System.Reflection;
using EG.Application.Interfaces.Adquisicion;
using Mapster;
using EG.Business.Services;
using EG.Common;
using EG.Common.Enums;
using EG.Common.Exceptions;
using EG.Common.GenericModel;

namespace EG.Application.Services.Adquisicion
{
    public abstract class AdquisicionCrudAppService<TEntity, TView, TDto, TResponse>
        : IAdquisicionCrudAppService<TResponse>
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
        private readonly Logger.Log4NetLogger _logger;

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
            _logger = new Logger.Log4NetLogger(GetType());
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
            catch (UserVisibleException ex)
            {
                LogUserVisibleMessage("crear", ex);
                return Failure<TResponse>(ex.UserMessage, ex.Code);
            }
            catch (Exception ex)
            {
                LogException("crear", ex);
                return Failure<TResponse>(UserFacingMessages.OperationFailed($"crear {_entityName}"), "ERROR");
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
            catch (UserVisibleException ex)
            {
                LogUserVisibleMessage("actualizar", ex);
                return Failure<TResponse>(ex.UserMessage, ex.Code);
            }
            catch (Exception ex)
            {
                LogException("actualizar", ex);
                return Failure<TResponse>(UserFacingMessages.OperationFailed($"actualizar {_entityName}"), "ERROR");
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
            catch (UserVisibleException ex)
            {
                LogUserVisibleMessage("eliminar", ex);
                return Failure<bool>(ex.UserMessage, ex.Code);
            }
            catch (Exception ex)
            {
                LogException("eliminar", ex);
                return Failure<bool>(UserFacingMessages.OperationFailed($"eliminar {_entityName}"), "ERROR");
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

        protected PagedResult<TResult> Failure<TResult>(string message, string code = "ERROR") => new()
        {
            Success = false,
            Message = message,
            Code = code,
            TotalCount = 0
        };

        protected void LogException(string operation, Exception ex)
        {
            _logger.LogMessage(
                LogLevelGRP.Error,
                $"Error al {operation} {_entityName}: {ex}",
                (byte)SystemLogTypes.Error,
                _entityName,
                string.Empty,
                string.Empty);
        }

        protected void LogUserVisibleMessage(string operation, UserVisibleException ex)
        {
            _logger.LogMessage(
                LogLevelGRP.Warn,
                $"Mensaje controlado al {operation} {_entityName}: {ex.UserMessage}",
                (byte)SystemLogTypes.Warning,
                _entityName,
                string.Empty,
                string.Empty);
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
