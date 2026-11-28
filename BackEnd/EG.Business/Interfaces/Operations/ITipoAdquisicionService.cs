namespace EG.Business.Interfaces.Operations;
public interface ITipoAdquisicionService

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse request);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse request);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
