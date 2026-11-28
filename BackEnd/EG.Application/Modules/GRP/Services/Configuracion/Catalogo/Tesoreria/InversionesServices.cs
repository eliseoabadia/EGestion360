using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using Mapster;
using System.Text.Json;
namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria;
public class BancoInversionService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.BancoInversionServiceOperations service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Tesoreria.BancoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.BancoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.BancoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.BancoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Tesoreria.BancoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.BancoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Tesoreria.BancoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.BancoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class CuentaBancariaInversionService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.CuentaBancariaInversionServiceOperations service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Tesoreria.CuentaBancariaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.CuentaBancariaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.CuentaBancariaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.CuentaBancariaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.CuentaBancariaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Tesoreria.CuentaBancariaResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.CuentaBancariaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Tesoreria.CuentaBancariaResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
}
public class IntermediarioFinancieroInversionService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.IntermediarioFinancieroInversionServiceOperations service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Tesoreria.IntermediarioFinancieroResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.IntermediarioFinancieroResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.IntermediarioFinancieroResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.IntermediarioFinancieroResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Tesoreria.IntermediarioFinancieroResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.IntermediarioFinancieroResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Tesoreria.IntermediarioFinancieroResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.IntermediarioFinancieroResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class InstrumentoInversionService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.InstrumentoInversionServiceOperations service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Tesoreria.InstrumentoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InstrumentoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InstrumentoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InstrumentoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Tesoreria.InstrumentoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InstrumentoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Tesoreria.InstrumentoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InstrumentoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class InversionAppService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.InversionOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Tesoreria.InversionResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InversionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Tesoreria.InversionResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InversionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Tesoreria.InversionResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InversionResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InversionResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InversionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class InteresAppService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.InteresOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Tesoreria.InteresResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InteresResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InteresResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InteresResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Tesoreria.InteresResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InteresResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Tesoreria.InteresResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.InteresResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class RetiroAppService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.RetiroOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Tesoreria.RetiroResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.RetiroResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.RetiroResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.RetiroResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.RetiroResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Tesoreria.RetiroResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.RetiroResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Tesoreria.RetiroResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
}
public class TipoPlazoInversionService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.TipoPlazoInversionServiceOperations service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Tesoreria.TipoPlazoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoPlazoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoPlazoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoPlazoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Tesoreria.TipoPlazoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoPlazoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Tesoreria.TipoPlazoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoPlazoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class TipoRetiroInversionService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.TipoRetiroInversionServiceOperations service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Tesoreria.TipoRetiroResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoRetiroResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoRetiroResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoRetiroResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Tesoreria.TipoRetiroResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoRetiroResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Tesoreria.TipoRetiroResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoRetiroResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
