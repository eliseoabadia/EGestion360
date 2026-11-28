using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.PresupuestoComprometido;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Domain.Interfaces;
namespace EG.Application.Services.PresupuestoComprometido;
public class AutorizacionSuficienciaAppService(global::EG.Business.Services.PresupuestoComprometido.AutorizacionSuficienciaOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class AutorizacionSuficienciaDetalleAppService(global::EG.Business.Services.PresupuestoComprometido.AutorizacionSuficienciaDetalleOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaDetalleResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaDetalleResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaDetalleResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaDetalleResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaDetalleResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaDetalleResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.PresupuestoComprometido.AutorizacionSuficienciaDetalleResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
