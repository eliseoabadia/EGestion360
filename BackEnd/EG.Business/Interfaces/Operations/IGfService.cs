namespace EG.Business.Interfaces.Operations;
public interface IGfService

{
    global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Presupuestales.GfResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.GfResponse> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.GfResponse> AddAsync(global::EG.Domain.DTOs.Requests.Presupuestales.GfDto dto, global::System.Int32 usuarioCreacion);
    global::System.Threading.Tasks.Task UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Presupuestales.GfDto dto, global::System.Int32 usuarioModificacion);
    global::System.Threading.Tasks.Task DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Presupuestales.GfResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
    global::System.Threading.Tasks.Task<global::System.Boolean> CanAddAsync(global::EG.Domain.DTOs.Requests.Presupuestales.GfDto dto);
    global::System.Threading.Tasks.Task<global::System.Boolean> CanUpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Presupuestales.GfDto dto);
}
