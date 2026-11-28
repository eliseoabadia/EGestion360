namespace EG.Business.Interfaces.Operations;
public interface IMarcaService

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse request);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse request);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
