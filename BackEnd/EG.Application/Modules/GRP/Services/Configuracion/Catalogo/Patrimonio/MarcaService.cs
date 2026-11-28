using Mapster;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio;
public class MarcaService(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.MarcaServiceOperations service) : global::EG.Application.Interfaces.Patrimonio.IMarcaService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse request) => service.CreateAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse request) => service.UpdateAsync(id, request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.MarcaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
