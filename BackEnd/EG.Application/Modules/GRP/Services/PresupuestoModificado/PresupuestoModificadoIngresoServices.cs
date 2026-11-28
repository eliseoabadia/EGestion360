using EG.Application.Interfaces.PresupuestoModificado;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.PresupuestoModificado;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Domain.Interfaces;
namespace EG.Application.Services.PresupuestoModificado;
public class IngreAdecuacionAppService(global::EG.Business.Services.PresupuestoModificado.IngreAdecuacionOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>, global::EG.Application.Interfaces.PresupuestoModificado.IIngresoAdecuacionAppService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> EnviarSolicitudAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.EnviarSolicitudAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> AutorizarAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.AutorizarAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionResponse>> RechazarAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.RechazarAsync(id, usuarioActual);
}
public class IngreAdecuacionDetalleAppService(global::EG.Business.Services.PresupuestoModificado.IngreAdecuacionDetalleOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionDetalleResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionDetalleResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionDetalleResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionDetalleResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionDetalleResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionDetalleResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.PresupuestoModificado.IngreAdecuacionDetalleResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
}
