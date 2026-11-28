namespace EG.Business.Interfaces.Operations;
public interface ITipoPolizaService

{
    global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Contabilidad.TipoPolizaResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Contabilidad.TipoPolizaResponse?> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Contabilidad.TipoPolizaResponse> AddAsync(global::EG.Domain.DTOs.Requests.Contabilidad.TipoPolizaDto dto, global::System.Int32 usuarioId);
    global::System.Threading.Tasks.Task UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Contabilidad.TipoPolizaDto dto, global::System.Int32 usuarioId);
    global::System.Threading.Tasks.Task DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contabilidad.TipoPolizaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
    global::System.Threading.Tasks.Task<global::System.Boolean> CanAddAsync(global::EG.Domain.DTOs.Requests.Contabilidad.TipoPolizaDto dto);
    global::System.Threading.Tasks.Task<global::System.Boolean> CanUpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Contabilidad.TipoPolizaDto dto);
}
