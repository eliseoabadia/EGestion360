using Mapster;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
namespace EG.Application.Services.General;
public class UsuarioAppService(global::EG.Business.Services.General.UsuarioOperationsService service) : global::EG.Application.Interfaces.General.IUsuarioAppService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Dommain.DTOs.Responses.UsuarioResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Dommain.DTOs.Responses.UsuarioResponse> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Dommain.DTOs.Responses.UsuarioResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest pageRequest, global::System.Func<global::EG.Dommain.DTOs.Responses.UsuarioResponse,global::System.Boolean> predicate = default) => service.GetAllPaginadoAsync(pageRequest, predicate);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Dommain.DTOs.Responses.UsuarioResponse>> GetByEmpresaIdAsync(global::System.Int32 empresaId) => service.GetByEmpresaIdAsync(empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Dommain.DTOs.Responses.UsuarioResponse> CreateAsync(global::EG.Domain.DTOs.Requests.General.UsuarioDto dto, global::System.Int32 usuarioActual) => service.CreateAsync(dto, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Dommain.DTOs.Responses.UsuarioResponse> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.General.UsuarioDto dto, global::System.Int32 usuarioActual) => service.UpdateAsync(id, dto, usuarioActual);
    public global::System.Threading.Tasks.Task<global::System.Boolean> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
