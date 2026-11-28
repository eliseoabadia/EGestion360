using Mapster;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio;
public class GrupoBienService(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.GrupoBienServiceOperations service) : global::EG.Application.Interfaces.Patrimonio.IGrupoBienService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.GrupoBienResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.GrupoBienResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.GrupoBienResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Patrimonio.GrupoBienResponse request) => service.CreateAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.GrupoBienResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Patrimonio.GrupoBienResponse request) => service.UpdateAsync(id, request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.GrupoBienResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.GrupoBienResponse>> GetGrupoBienAsync() => service.GetGrupoBienAsync();
    public global::System.Threading.Tasks.Task<global::System.Collections.Generic.List<global::EG.Common.GenericModel.LookupItem>> GetLookupAsync() => service.GetLookupAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetLookupPaginadoAsync(global::System.Int32 page = 1, global::System.Int32 pageSize = 25, global::System.String? filter = default) => service.GetLookupPaginadoAsync(page, pageSize, filter);
}
