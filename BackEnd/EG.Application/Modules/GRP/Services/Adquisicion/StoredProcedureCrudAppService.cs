using EG.Business.Services;
using EG.Common;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;

namespace EG.Application.Services.Adquisicion
{
    public abstract class StoredProcedureCrudAppService<TEntity, TView, TDto, TResponse>
        : AdquisicionCrudAppService<TEntity, TView, TDto, TResponse>
        where TEntity : class
        where TView : class
        where TDto : class
        where TResponse : class
    {
        private readonly EGestionContext _context;
        private readonly string _storedProcedure;
        private readonly string _entityName;
        private readonly Func<TResponse, int> _getResponseId;
        private readonly Func<int, int?, TResponse?, int?, SqlParameter[]> _buildParameters;

        protected StoredProcedureCrudAppService(
            GenericService<TEntity, TDto, TResponse> service,
            GenericService<TView, TDto, TResponse> serviceView,
            EGestionContext context,
            string idPropertyName,
            string entityName,
            Action<TDto, int> setId,
            string storedProcedure,
            Func<TResponse, int> getResponseId,
            Func<int, int?, TResponse?, int?, SqlParameter[]> buildParameters)
            : base(service, serviceView, idPropertyName, entityName, setId)
        {
            _context = context;
            _storedProcedure = storedProcedure;
            _entityName = entityName;
            _getResponseId = getResponseId;
            _buildParameters = buildParameters;
        }

        protected virtual int CreateAction => 1;
        protected virtual int UpdateAction => 2;
        protected virtual int DeleteAction => 3;

        public override async Task<PagedResult<TResponse>> CreateAsync(TResponse response, int usuarioActual)
        {
            SetPendingAuthorizationOnCreate(response);
            return await ExecuteMutationAsync(CreateAction, null, response, usuarioActual, "creado", "crear");
        }

        public override async Task<PagedResult<TResponse>> UpdateAsync(int id, TResponse response, int usuarioActual)
        {
            return await ExecuteMutationAsync(UpdateAction, id, response, usuarioActual, "actualizado", "actualizar");
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var existing = await GetByIdAsync(id);
                if (!existing.Success)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"{_entityName} con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };
                }

                await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    _storedProcedure,
                    _buildParameters(DeleteAction, id, null, null));

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
            catch (Exception ex)
            {
                if (ex is UserVisibleException userVisibleException)
                {
                    LogUserVisibleMessage("eliminar", userVisibleException);
                    return Failure<bool>(userVisibleException.UserMessage, userVisibleException.Code);
                }

                LogException("eliminar", ex);
                return Failure<bool>(UserFacingMessages.OperationFailed($"eliminar {_entityName}"), "ERROR");
            }
        }

        private async Task<PagedResult<TResponse>> ExecuteMutationAsync(
            int action,
            int? id,
            TResponse response,
            int usuarioActual,
            string operationPast,
            string operationInfinitive)
        {
            try
            {
                _service.ApplyCurrentEmpresaIfPresent(response);

                var result = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    _storedProcedure,
                    _buildParameters(action, id, response, usuarioActual));

                var resolvedId = result.GetId();
                if (!resolvedId.HasValue)
                {
                    var responseId = _getResponseId(response);
                    if (responseId > 0)
                    {
                        resolvedId = responseId;
                    }
                }

                if (resolvedId.HasValue)
                {
                    var refreshed = await GetByIdAsync(resolvedId.Value);
                    if (refreshed.Success)
                    {
                        refreshed.Message = result.Mensaje;
                        return refreshed;
                    }
                }

                return new PagedResult<TResponse>
                {
                    Success = true,
                    Message = string.IsNullOrWhiteSpace(result.Mensaje)
                        ? $"{_entityName} {operationPast} correctamente"
                        : result.Mensaje,
                    Code = "SUCCESS",
                    TotalCount = resolvedId.HasValue ? 1 : 0
                };
            }
            catch (Exception ex)
            {
                if (ex is UserVisibleException userVisibleException)
                {
                    LogUserVisibleMessage(operationInfinitive, userVisibleException);
                    return Failure<TResponse>(userVisibleException.UserMessage, userVisibleException.Code);
                }

                LogException(operationInfinitive, ex);
                return Failure<TResponse>(
                    UserFacingMessages.OperationFailed($"{operationInfinitive} {_entityName}"),
                    "ERROR");
            }
        }
    }
}
