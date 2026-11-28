using System.Text.Json;
using EG.Application.Interfaces.Nomina;
using EG.Business.Services;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using Mapster;
namespace EG.Application.Services.Nomina;
public abstract class NominaRhDetailAppService<TView, TDto, TResponse>(global::EG.Business.Services.Nomina.NominaRhDetailOperationsService<TView,TDto,TResponse> service) : global::EG.Application.Interfaces.Nomina.INominaRhDetailAppService<TDto,TResponse>
where TView : class
where TDto : NominaRhDetailDtoBase
where TResponse : NominaRhDetailResponseBase
{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetAllAsync(global::System.Int32? empresaId) => service.GetAllAsync(empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetByIdAsync(global::System.Int32 id, global::System.Int32? empresaId) => service.GetByIdAsync(id, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request, global::System.Int32? empresaId) => service.GetAllPaginadoAsync(request, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> CreateAsync(TDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.CreateAsync(dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> UpdateAsync(global::System.Int32 id, TDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.UpdateAsync(id, dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.DeleteAsync(id, usuarioActual, empresaId);
}
public sealed class NominaRhExpedienteAppService(global::EG.Business.Services.Nomina.NominaRhExpedienteOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaRhDetailAppService<global::EG.Domain.DTOs.Requests.Nomina.NominaRhExpedienteDto,global::EG.Domain.DTOs.Responses.Nomina.NominaRhExpedienteResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhExpedienteResponse>> GetAllAsync(global::System.Int32? empresaId) => service.GetAllAsync(empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhExpedienteResponse>> GetByIdAsync(global::System.Int32 id, global::System.Int32? empresaId) => service.GetByIdAsync(id, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhExpedienteResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request, global::System.Int32? empresaId) => service.GetAllPaginadoAsync(request, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhExpedienteResponse>> CreateAsync(global::EG.Domain.DTOs.Requests.Nomina.NominaRhExpedienteDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.CreateAsync(dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhExpedienteResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Nomina.NominaRhExpedienteDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.UpdateAsync(id, dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.DeleteAsync(id, usuarioActual, empresaId);
}
public sealed class NominaRhContratoAppService(global::EG.Business.Services.Nomina.NominaRhContratoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaRhDetailAppService<global::EG.Domain.DTOs.Requests.Nomina.NominaRhContratoDto,global::EG.Domain.DTOs.Responses.Nomina.NominaRhContratoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhContratoResponse>> GetAllAsync(global::System.Int32? empresaId) => service.GetAllAsync(empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhContratoResponse>> GetByIdAsync(global::System.Int32 id, global::System.Int32? empresaId) => service.GetByIdAsync(id, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhContratoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request, global::System.Int32? empresaId) => service.GetAllPaginadoAsync(request, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhContratoResponse>> CreateAsync(global::EG.Domain.DTOs.Requests.Nomina.NominaRhContratoDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.CreateAsync(dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhContratoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Nomina.NominaRhContratoDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.UpdateAsync(id, dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.DeleteAsync(id, usuarioActual, empresaId);
}
public sealed class NominaRhDependienteAppService(global::EG.Business.Services.Nomina.NominaRhDependienteOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaRhDetailAppService<global::EG.Domain.DTOs.Requests.Nomina.NominaRhDependienteDto,global::EG.Domain.DTOs.Responses.Nomina.NominaRhDependienteResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhDependienteResponse>> GetAllAsync(global::System.Int32? empresaId) => service.GetAllAsync(empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhDependienteResponse>> GetByIdAsync(global::System.Int32 id, global::System.Int32? empresaId) => service.GetByIdAsync(id, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhDependienteResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request, global::System.Int32? empresaId) => service.GetAllPaginadoAsync(request, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhDependienteResponse>> CreateAsync(global::EG.Domain.DTOs.Requests.Nomina.NominaRhDependienteDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.CreateAsync(dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhDependienteResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Nomina.NominaRhDependienteDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.UpdateAsync(id, dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.DeleteAsync(id, usuarioActual, empresaId);
}
public sealed class NominaRhIncidenciaAppService(global::EG.Business.Services.Nomina.NominaRhIncidenciaOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaRhDetailAppService<global::EG.Domain.DTOs.Requests.Nomina.NominaRhIncidenciaDto,global::EG.Domain.DTOs.Responses.Nomina.NominaRhIncidenciaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhIncidenciaResponse>> GetAllAsync(global::System.Int32? empresaId) => service.GetAllAsync(empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhIncidenciaResponse>> GetByIdAsync(global::System.Int32 id, global::System.Int32? empresaId) => service.GetByIdAsync(id, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhIncidenciaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request, global::System.Int32? empresaId) => service.GetAllPaginadoAsync(request, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhIncidenciaResponse>> CreateAsync(global::EG.Domain.DTOs.Requests.Nomina.NominaRhIncidenciaDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.CreateAsync(dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhIncidenciaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Nomina.NominaRhIncidenciaDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.UpdateAsync(id, dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.DeleteAsync(id, usuarioActual, empresaId);
}
public sealed class NominaRhPensionAppService(global::EG.Business.Services.Nomina.NominaRhPensionOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaRhDetailAppService<global::EG.Domain.DTOs.Requests.Nomina.NominaRhPensionDto,global::EG.Domain.DTOs.Responses.Nomina.NominaRhPensionResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhPensionResponse>> GetAllAsync(global::System.Int32? empresaId) => service.GetAllAsync(empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhPensionResponse>> GetByIdAsync(global::System.Int32 id, global::System.Int32? empresaId) => service.GetByIdAsync(id, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhPensionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request, global::System.Int32? empresaId) => service.GetAllPaginadoAsync(request, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhPensionResponse>> CreateAsync(global::EG.Domain.DTOs.Requests.Nomina.NominaRhPensionDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.CreateAsync(dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhPensionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Nomina.NominaRhPensionDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.UpdateAsync(id, dto, usuarioActual, empresaId);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual, global::System.Int32? empresaId) => service.DeleteAsync(id, usuarioActual, empresaId);
}
public sealed class NominaRhLookupAppService(global::EG.Business.Services.Nomina.NominaRhLookupOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaRhLookupAppService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhLookupResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request, global::System.Int32? empresaId) => service.GetAllPaginadoAsync(request, empresaId);
}
