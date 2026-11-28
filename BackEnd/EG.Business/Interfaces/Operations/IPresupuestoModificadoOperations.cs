namespace EG.Business.Interfaces.Operations;
public interface IPresupuestoModificadoOperations

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> EnviarSolicitudAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> AutorizarAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> RechazarAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> CancelarSolicitudAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
