using System.Reflection;
using EG.Application.Interfaces.Nomina;
using EG.Business.Services;
using EG.Common;
using EG.Common.Enums;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using Mapster;

namespace EG.Application.Services.Nomina
{
    public abstract class NominaCrudAppService<TEntity, TDto, TResponse> : INominaCrudAppService<TResponse>
        where TEntity : class
        where TDto : class
        where TResponse : class
    {
        private readonly GenericService<TEntity, TDto, TResponse> _service;
        private readonly string _idPropertyName;
        private readonly string _entityName;
        private readonly Action<TDto, int> _setId;
        private readonly Logger.Log4NetLogger _logger;

        protected NominaCrudAppService(
            GenericService<TEntity, TDto, TResponse> service,
            string idPropertyName,
            string entityName,
            Action<TDto, int> setId)
        {
            _service = service;
            _idPropertyName = idPropertyName;
            _entityName = entityName;
            _setId = setId;
            _logger = new Logger.Log4NetLogger(GetType());
        }

        public virtual async Task<PagedResult<TResponse>> GetAllAsync()
        {
            try
            {
                var items = (await _service.GetAllAsync()).ToList();
                return new PagedResult<TResponse>
                {
                    Success = true,
                    Message = $"{_entityName} obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = items.Count
                };
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return Failure<TResponse>(UserFacingMessages.OperationFailed($"obtener {_entityName}"));
            }
        }

        public virtual async Task<PagedResult<TResponse>> GetByIdAsync(int id)
        {
            try
            {
                var result = await _service.GetByIdAsync(id, idPropertyName: _idPropertyName);
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
            catch (Exception ex)
            {
                LogException("obtener por id", ex);
                return Failure<TResponse>(UserFacingMessages.OperationFailed($"obtener {_entityName}"));
            }
        }

        public virtual async Task<PagedResult<TResponse>> CreateAsync(TResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<TDto>();
                SetProperty(dto, "Activo", true);
                SetProperty(dto, "UsuarioCreacion", usuarioActual);
                SetProperty(dto, "FechaCreacion", DateTime.Now);
                SetProperty(dto, "UsuarioModificacion", null);
                SetProperty(dto, "FechaModificacion", null);

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
                return Failure<TResponse>(UserFacingMessages.OperationFailed($"crear {_entityName}"));
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
                return Failure<TResponse>(UserFacingMessages.OperationFailed($"actualizar {_entityName}"));
            }
        }

        public virtual async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id, idPropertyName: _idPropertyName);
                if (existing == null)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"{_entityName} con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };
                }

                var dto = existing.Adapt<TDto>();
                _setId(dto, id);
                CopyProperty(existing, dto, "UsuarioCreacion");
                CopyProperty(existing, dto, "FechaCreacion");
                SetProperty(dto, "Activo", false);
                SetProperty(dto, "UsuarioModificacion", usuarioActual);
                SetProperty(dto, "FechaModificacion", DateTime.Now);

                await _service.UpdateAsync(id, dto);

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
                return Failure<bool>(UserFacingMessages.OperationFailed($"eliminar {_entityName}"));
            }
        }

        public virtual async Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(request);
                if (!result.Success)
                {
                    LogMessage(LogLevelGRP.Warn, $"No fue posible obtener {_entityName}: {result.Message}", SystemLogTypes.Warning);
                    result.Message = UserFacingMessages.OperationFailed($"obtener {_entityName}");
                    result.Code = "ERROR";
                }
                else
                {
                    result.Message = $"{_entityName} obtenidos correctamente";
                    result.Code = "SUCCESS";
                }

                return result;
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return Failure<TResponse>(UserFacingMessages.OperationFailed($"obtener {_entityName}"));
            }
        }

        private PagedResult<TResponse> NotFound(int id) => new()
        {
            Success = false,
            Message = $"{_entityName} con ID {id} no encontrado",
            Code = "NOT_FOUND",
            TotalCount = 0
        };

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
            LogMessage(LogLevelGRP.Warn, $"Mensaje controlado al {operation} {_entityName}: {ex.UserMessage}", SystemLogTypes.Warning);
        }

        protected void LogMessage(LogLevelGRP level, string message, SystemLogTypes type)
        {
            _logger.LogMessage(
                level,
                message,
                (byte)type,
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