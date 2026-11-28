namespace EG.Business.Interfaces.Operations;
public interface IRegistroCompromisoOperations

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> AutorizarAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
