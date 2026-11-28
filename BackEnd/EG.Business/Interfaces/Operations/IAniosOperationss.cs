namespace EG.Business.Interfaces.Operations;
public interface IAniosOperationss

{
    global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Presupuestales.AniosResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.AniosResponse> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Presupuestales.AniosResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest pageRequest, global::System.Func<global::EG.Domain.DTOs.Responses.Presupuestales.AniosResponse,global::System.Boolean>? predicate = default);
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.AniosResponse> CreateAsync(global::EG.Domain.DTOs.Responses.Presupuestales.AniosResponse response, global::System.Int32 usuarioCreacion);
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.AniosResponse> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Presupuestales.AniosResponse response, global::System.Int32 usuarioModificacion);
    global::System.Threading.Tasks.Task<global::System.Boolean> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::System.Boolean> ExistsAsync(global::System.Int32 id);
}
