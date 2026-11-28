namespace EG.Business.Interfaces.Operations;
public interface IFnService

{
    global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Presupuestales.FnResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.FnResponse?> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.FnResponse> AddAsync(global::EG.Domain.DTOs.Requests.Presupuestales.FnDto dto, global::System.Int32 usuarioId);
    global::System.Threading.Tasks.Task UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Presupuestales.FnDto dto, global::System.Int32 usuarioId);
    global::System.Threading.Tasks.Task DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::System.String?> GetDeleteBlockReasonAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Presupuestales.FnResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
    global::System.Threading.Tasks.Task<global::System.Boolean> CanAddAsync(global::EG.Domain.DTOs.Requests.Presupuestales.FnDto dto);
    global::System.Threading.Tasks.Task<global::System.Boolean> CanUpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Presupuestales.FnDto dto);
}
