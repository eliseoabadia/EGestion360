namespace EG.Business.Interfaces.Operations;
public interface INivelService

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.NivelResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.NivelResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.NivelResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Patrimonio.NivelResponse request);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.NivelResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Patrimonio.NivelResponse request);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.NivelResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
    global::System.Threading.Tasks.Task<global::System.Collections.Generic.List<global::EG.Common.GenericModel.LookupItem>> GetLookupAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetLookupPaginadoAsync(global::System.Int32 page = 1, global::System.Int32 pageSize = 25, global::System.String? filter = default);
}
