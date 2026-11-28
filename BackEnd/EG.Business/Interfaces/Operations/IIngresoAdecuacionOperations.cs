namespace EG.Business.Interfaces.Operations;
public interface IIngresoAdecuacionOperations

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> EnviarSolicitudAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> AutorizarAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> RechazarAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
