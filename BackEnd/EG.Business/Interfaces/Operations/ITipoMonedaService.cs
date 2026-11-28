namespace EG.Business.Interfaces.Operations;
public interface ITipoMonedaService

{
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Tesoreria.TipoMonedaResponse?> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Tesoreria.TipoMonedaResponse> CreateAsync(global::EG.Domain.DTOs.Requests.Tesoreria.TipoMonedaDto dto, global::System.Int32 usuarioId);
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Tesoreria.TipoMonedaResponse?> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Tesoreria.TipoMonedaDto dto, global::System.Int32 usuarioId);
    global::System.Threading.Tasks.Task DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoMonedaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
