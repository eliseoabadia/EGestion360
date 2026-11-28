using EG.Application.Services.Adquisicion;
using EG.Application.Interfaces.CuentasXPagar;
using EG.Business.Services;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.CuentasXPagar;
using EG.Domain.DTOs.Responses.CuentasXPagar;
using EG.Domain.Interfaces;
namespace EG.Application.Services.CuentasXPagar;
public class ContratoAppService(global::EG.Business.Services.CuentasXPagar.ContratoOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class ContratoDetalleAppService(global::EG.Business.Services.CuentasXPagar.ContratoDetalleOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoDetalleResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoDetalleResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoDetalleResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoDetalleResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoDetalleResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoDetalleResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ContratoDetalleResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class FacturaAppService(global::EG.Business.Services.CuentasXPagar.FacturaOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
}
public class FacturaDetalleAppService(global::EG.Business.Services.CuentasXPagar.FacturaDetalleOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaDetalleResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaDetalleResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaDetalleResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaDetalleResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaDetalleResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaDetalleResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.FacturaDetalleResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class CLCAppService(global::EG.Business.Services.CuentasXPagar.CLCOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
}
public class CLCDetalleAppService(global::EG.Business.Services.CuentasXPagar.CLCDetalleOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCDetalleResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCDetalleResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCDetalleResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCDetalleResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCDetalleResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCDetalleResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCDetalleResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCDetalleResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class CLCFacturaAppService(global::EG.Business.Services.CuentasXPagar.CLCFacturaOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCFacturaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCFacturaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCFacturaResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCFacturaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCFacturaResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCFacturaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCFacturaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.CLCFacturaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class ChequeAppService(global::EG.Business.Services.CuentasXPagar.ChequeOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>, global::EG.Application.Interfaces.CuentasXPagar.IChequeAppService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> RegresarASolicitudSuficienciaAsync(global::System.Int32 id, global::System.String motivo) => service.RegresarASolicitudSuficienciaAsync(id, motivo);
}
public class ChequePartidaAppService(global::EG.Business.Services.CuentasXPagar.ChequePartidaOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequePartidaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequePartidaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequePartidaResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequePartidaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequePartidaResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequePartidaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequePartidaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequePartidaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class DepositoAppService(global::EG.Business.Services.CuentasXPagar.DepositoOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>, global::EG.Application.Interfaces.CuentasXPagar.IDepositoAppService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> AutorizarAsync(global::System.Int32 id) => service.AutorizarAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoPolizaResponse>> GetPolizaAsync(global::System.Int32 id) => service.GetPolizaAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetIngresoAutorizadoLookupPaginadoAsync(global::System.Int32 page, global::System.Int32 pageSize, global::System.String? filter, global::System.Int32? idAnio) => service.GetIngresoAutorizadoLookupPaginadoAsync(page, pageSize, filter, idAnio);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetCLCFacturaLookupPaginadoAsync(global::System.Int32 page, global::System.Int32 pageSize, global::System.String? filter) => service.GetCLCFacturaLookupPaginadoAsync(page, pageSize, filter);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetTipoDoctoPagoLookupPaginadoAsync(global::System.Int32 page, global::System.Int32 pageSize, global::System.String? filter) => service.GetTipoDoctoPagoLookupPaginadoAsync(page, pageSize, filter);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetCuentaContableLookupPaginadoAsync(global::System.Int32 page, global::System.Int32 pageSize, global::System.String? filter) => service.GetCuentaContableLookupPaginadoAsync(page, pageSize, filter);
}
