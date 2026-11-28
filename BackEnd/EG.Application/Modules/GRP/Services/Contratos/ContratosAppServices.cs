using EG.Application.Interfaces.Contratos;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contratos;
using EG.Domain.DTOs.Responses.Contratos;
using EG.Domain.Interfaces;
using System.Text.Json;
namespace EG.Application.Services.Contratos;
public class RegistroCompromisoAppService(global::EG.Business.Services.Contratos.RegistroCompromisoOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>, global::EG.Application.Interfaces.Contratos.IRegistroCompromisoAppService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> AutorizarAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.AutorizarAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.OrcoContratoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class SaldosContratoAppService(global::EG.Business.Services.Contratos.SaldosContratoOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Contratos.SaldosContratoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.SaldosContratoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.SaldosContratoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.SaldosContratoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Contratos.SaldosContratoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.SaldosContratoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Contratos.SaldosContratoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.SaldosContratoResponse>> GetAllAsync() => service.GetAllAsync();
}
public class EstadoContratoAppService(global::EG.Business.Services.Contratos.EstadoContratoOperationsService service) : global::EG.Application.Interfaces.Adquisicion.IAdquisicionCrudAppService<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>, global::EG.Application.Interfaces.Contratos.IEstadoContratoAppService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> AutorizarAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.AutorizarAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> LiberarRemanenteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.LiberarRemanenteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contratos.EstadoContratoResponse>> GetAllAsync() => service.GetAllAsync();
}
