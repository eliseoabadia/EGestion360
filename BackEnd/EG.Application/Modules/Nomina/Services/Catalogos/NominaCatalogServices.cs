using EG.Business.Services;
using EG.Common;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using Mapster;
namespace EG.Application.Services.Nomina;
public class NomEmpresaNominaAppService(global::EG.Business.Services.Nomina.NomEmpresaNominaOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomEmpresaNominaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEmpresaNominaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEmpresaNominaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEmpresaNominaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomEmpresaNominaResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEmpresaNominaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomEmpresaNominaResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEmpresaNominaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomUniversoAppService(global::EG.Business.Services.Nomina.NomUniversoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomUniversoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomUniversoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomUniversoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomUniversoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomUniversoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomUniversoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomUniversoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomUniversoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomNivelAppService(global::EG.Business.Services.Nomina.NomNivelOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomNivelResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNivelResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNivelResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNivelResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomNivelResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNivelResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomNivelResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNivelResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomClasePuestoAppService(global::EG.Business.Services.Nomina.NomClasePuestoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomClasePuestoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomClasePuestoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomClasePuestoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomClasePuestoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomClasePuestoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomClasePuestoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomClasePuestoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomClasePuestoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomPuestoAppService(global::EG.Business.Services.Nomina.NomPuestoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomPuestoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPuestoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPuestoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPuestoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomPuestoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPuestoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomPuestoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPuestoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomPlazaAutorizadaAppService(global::EG.Business.Services.Nomina.NomPlazaAutorizadaOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomPlazaAutorizadaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPlazaAutorizadaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPlazaAutorizadaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPlazaAutorizadaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPlazaAutorizadaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomPlazaAutorizadaResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPlazaAutorizadaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomPlazaAutorizadaResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
public class NomNombramientoAppService(global::EG.Business.Services.Nomina.NomNombramientoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomNombramientoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNombramientoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNombramientoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNombramientoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomNombramientoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNombramientoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomNombramientoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomNombramientoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomImporteNivelAppService(global::EG.Business.Services.Nomina.NomImporteNivelOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomImporteNivelResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomImporteNivelResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomImporteNivelResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomImporteNivelResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomImporteNivelResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomImporteNivelResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomImporteNivelResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomImporteNivelResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomContratoLaboralAppService(global::EG.Business.Services.Nomina.NomContratoLaboralOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomContratoLaboralResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoLaboralResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoLaboralResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoLaboralResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomContratoLaboralResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoLaboralResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomContratoLaboralResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoLaboralResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomConceptoAppService(global::EG.Business.Services.Nomina.NomConceptoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomConceptoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomConceptoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
public class NomConceptoFactorAppService(global::EG.Business.Services.Nomina.NomConceptoFactorOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFactorResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFactorResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFactorResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFactorResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFactorResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFactorResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFactorResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFactorResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
public class NomConceptoFijoAppService(global::EG.Business.Services.Nomina.NomConceptoFijoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFijoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFijoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFijoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFijoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFijoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFijoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFijoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomConceptoFijoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
public class NomConceptoPorcentajeAppService(global::EG.Business.Services.Nomina.NomConceptoPorcentajeOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoPorcentajeResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoPorcentajeResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoPorcentajeResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoPorcentajeResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoPorcentajeResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomConceptoPorcentajeResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoPorcentajeResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomConceptoPorcentajeResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
public class NomConceptoProporcionalAppService(global::EG.Business.Services.Nomina.NomConceptoProporcionalOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoProporcionalResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoProporcionalResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoProporcionalResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoProporcionalResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoProporcionalResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomConceptoProporcionalResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoProporcionalResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomConceptoProporcionalResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
public class NomConceptoTabularAppService(global::EG.Business.Services.Nomina.NomConceptoTabularOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoTabularResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoTabularResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoTabularResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoTabularResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoTabularResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomConceptoTabularResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoTabularResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomConceptoTabularResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
public class NomConceptoVariableAppService(global::EG.Business.Services.Nomina.NomConceptoVariableOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoVariableResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoVariableResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoVariableResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoVariableResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoVariableResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomConceptoVariableResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomConceptoVariableResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomConceptoVariableResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
public class NomContratoTercerosAppService(global::EG.Business.Services.Nomina.NomContratoTercerosOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomContratoTercerosResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoTercerosResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoTercerosResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoTercerosResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomContratoTercerosResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoTercerosResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomContratoTercerosResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomContratoTercerosResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomCreditoAppService(global::EG.Business.Services.Nomina.NomCreditoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomCreditoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCreditoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCreditoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCreditoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomCreditoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCreditoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomCreditoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCreditoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomDescuentoCreditoAppService(global::EG.Business.Services.Nomina.NomDescuentoCreditoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoCreditoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoCreditoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoCreditoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoCreditoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoCreditoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoCreditoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoCreditoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoCreditoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomDescuentoInfonavitAppService(global::EG.Business.Services.Nomina.NomDescuentoInfonavitOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoInfonavitResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoInfonavitResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoInfonavitResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoInfonavitResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoInfonavitResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoInfonavitResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoInfonavitResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDescuentoInfonavitResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomEstatusPagoAppService(global::EG.Business.Services.Nomina.NomEstatusPagoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomEstatusPagoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstatusPagoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstatusPagoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstatusPagoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomEstatusPagoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstatusPagoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomEstatusPagoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstatusPagoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomFactorIntAppService(global::EG.Business.Services.Nomina.NomFactorIntOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomFactorIntResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomFactorIntResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomFactorIntResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomFactorIntResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomFactorIntResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomFactorIntResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomFactorIntResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomFactorIntResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomTablaFiscalAppService(global::EG.Business.Services.Nomina.NomTablaFiscalOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomTablaFiscalResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTablaFiscalResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomTablaFiscalResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTablaFiscalResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTablaFiscalResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTablaFiscalResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomTablaFiscalResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTablaFiscalResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomInfonavitAppService(global::EG.Business.Services.Nomina.NomInfonavitOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomInfonavitResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomInfonavitResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomInfonavitResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomInfonavitResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomInfonavitResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomInfonavitResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomInfonavitResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomInfonavitResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomPeriodoActivoAppService(global::EG.Business.Services.Nomina.NomPeriodoActivoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomPeriodoActivoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPeriodoActivoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPeriodoActivoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPeriodoActivoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomPeriodoActivoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPeriodoActivoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomPeriodoActivoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomPeriodoActivoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomSalarioMinimoAppService(global::EG.Business.Services.Nomina.NomSalarioMinimoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomSalarioMinimoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSalarioMinimoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSalarioMinimoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSalarioMinimoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomSalarioMinimoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSalarioMinimoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomSalarioMinimoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSalarioMinimoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomSueldoEspecialAppService(global::EG.Business.Services.Nomina.NomSueldoEspecialOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoEspecialResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoEspecialResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoEspecialResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoEspecialResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomSueldoEspecialResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoEspecialResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomSueldoEspecialResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoEspecialResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomSueldoLiqFinAppService(global::EG.Business.Services.Nomina.NomSueldoLiqFinOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoLiqFinResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoLiqFinResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoLiqFinResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoLiqFinResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomSueldoLiqFinResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoLiqFinResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomSueldoLiqFinResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoLiqFinResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomSueldoMensualAppService(global::EG.Business.Services.Nomina.NomSueldoMensualOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoMensualResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoMensualResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoMensualResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoMensualResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomSueldoMensualResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoMensualResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomSueldoMensualResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoMensualResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomSueldoQuincenalAppService(global::EG.Business.Services.Nomina.NomSueldoQuincenalOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoQuincenalResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoQuincenalResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoQuincenalResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoQuincenalResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomSueldoQuincenalResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoQuincenalResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomSueldoQuincenalResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoQuincenalResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomSueldoSemanalAppService(global::EG.Business.Services.Nomina.NomSueldoSemanalOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoSemanalResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoSemanalResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoSemanalResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoSemanalResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomSueldoSemanalResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoSemanalResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomSueldoSemanalResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomSueldoSemanalResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomTipoIncapacidadAppService(global::EG.Business.Services.Nomina.NomTipoIncapacidadOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncapacidadResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncapacidadResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncapacidadResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncapacidadResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncapacidadResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncapacidadResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncapacidadResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncapacidadResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomTipoPagoAppService(global::EG.Business.Services.Nomina.NomTipoPagoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPagoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPagoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPagoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPagoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomTipoPagoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPagoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomTipoPagoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPagoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomTipoPensionAppService(global::EG.Business.Services.Nomina.NomTipoPensionOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPensionResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPensionResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPensionResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPensionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomTipoPensionResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPensionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomTipoPensionResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoPensionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomCatalogoSimpleAppService(global::EG.Business.Services.Nomina.NomCatalogoSimpleOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomCatalogoSimpleResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCatalogoSimpleResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCatalogoSimpleResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCatalogoSimpleResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCatalogoSimpleResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomCatalogoSimpleResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomCatalogoSimpleResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomCatalogoSimpleResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
}
public class NomEstadoCivilAppService(global::EG.Business.Services.Nomina.NomEstadoCivilOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomEstadoCivilResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstadoCivilResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstadoCivilResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstadoCivilResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomEstadoCivilResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstadoCivilResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomEstadoCivilResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEstadoCivilResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomEscolaridadAppService(global::EG.Business.Services.Nomina.NomEscolaridadOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomEscolaridadResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEscolaridadResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEscolaridadResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEscolaridadResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomEscolaridadResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEscolaridadResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomEscolaridadResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomEscolaridadResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomDiaSemanaAppService(global::EG.Business.Services.Nomina.NomDiaSemanaOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomDiaSemanaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDiaSemanaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDiaSemanaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDiaSemanaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomDiaSemanaResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDiaSemanaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomDiaSemanaResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomDiaSemanaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomMedodoPagoAppService(global::EG.Business.Services.Nomina.NomMedodoPagoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomMedodoPagoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomMedodoPagoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomMedodoPagoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomMedodoPagoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomMedodoPagoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomMedodoPagoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomMedodoPagoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomMedodoPagoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomParentescoAppService(global::EG.Business.Services.Nomina.NomParentescoOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomParentescoResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomParentescoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomParentescoResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomParentescoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomParentescoResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomParentescoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomParentescoResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomParentescoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomTipoContratacionAppService(global::EG.Business.Services.Nomina.NomTipoContratacionOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomTipoContratacionResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoContratacionResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoContratacionResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoContratacionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomTipoContratacionResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoContratacionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomTipoContratacionResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoContratacionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomTipoIncidenciaAppService(global::EG.Business.Services.Nomina.NomTipoIncidenciaOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncidenciaResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncidenciaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncidenciaResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncidenciaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncidenciaResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncidenciaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncidenciaResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoIncidenciaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
public class NomTipoJustificacionAppService(global::EG.Business.Services.Nomina.NomTipoJustificacionOperationsService service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<global::EG.Domain.DTOs.Responses.Nomina.NomTipoJustificacionResponse>

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoJustificacionResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoJustificacionResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoJustificacionResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Nomina.NomTipoJustificacionResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoJustificacionResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Nomina.NomTipoJustificacionResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NomTipoJustificacionResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
