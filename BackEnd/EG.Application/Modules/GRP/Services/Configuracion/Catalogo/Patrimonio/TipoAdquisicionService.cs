using Mapster;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio;
public class TipoAdquisicionService(global::EG.Business.Services.Configuracion.Catalogo.Patrimonio.TipoAdquisicionServiceOperations service) : global::EG.Application.Interfaces.Patrimonio.ITipoAdquisicionService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse request) => service.CreateAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse request) => service.UpdateAsync(id, request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.TipoAdquisicionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
