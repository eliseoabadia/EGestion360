namespace EG.Business.Interfaces.Operations;
public interface IEstadoContratoOperations

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> AutorizarAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> LiberarRemanenteAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
