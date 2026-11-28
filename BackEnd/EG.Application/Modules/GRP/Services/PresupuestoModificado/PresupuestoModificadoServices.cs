using EG.Application.Interfaces.PresupuestoModificado;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.PresupuestoModificado;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.Domain.Interfaces;
namespace EG.Application.Services.PresupuestoModificado;
public class EgreAdecuacionAppService(global::EG.Business.Services.PresupuestoModificado.EgreAdecuacionOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>, global::EG.Application.Interfaces.PresupuestoModificado.IPresupuestoModificadoAppService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> EnviarSolicitudAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.EnviarSolicitudAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> AutorizarAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.AutorizarAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> RechazarAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.RechazarAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionResponse>> CancelarSolicitudAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.CancelarSolicitudAsync(id, usuarioActual);
}
public class EgreAdecuacionDetalleAppService(global::EG.Business.Services.PresupuestoModificado.EgreAdecuacionDetalleOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionDetalleResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionDetalleResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionDetalleResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionDetalleResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionDetalleResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionDetalleResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgreAdecuacionDetalleResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
}
public class EgresoDisponibleAppService(global::EG.Business.Services.PresupuestoModificado.EgresoDisponibleOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgresoDisponibleResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgresoDisponibleResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgresoDisponibleResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgresoDisponibleResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgresoDisponibleResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgresoDisponibleResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgresoDisponibleResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.PresupuestoModificado.EgresoDisponibleResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
}
