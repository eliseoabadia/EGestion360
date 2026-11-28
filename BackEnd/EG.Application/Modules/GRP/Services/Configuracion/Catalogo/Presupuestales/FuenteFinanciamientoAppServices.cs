using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales;
public class FuenteFinanciamientoAppServices(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.FuenteFinanciamientoOperationsServices service) : global::EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales.IFuenteFinanciamientoAppServices

{
    public global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Presupuestales.FuenteFinanciamientoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.FuenteFinanciamientoResponse> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Presupuestales.FuenteFinanciamientoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest pageRequest, global::System.Func<global::EG.Domain.DTOs.Responses.Presupuestales.FuenteFinanciamientoResponse,global::System.Boolean>? predicate = default) => service.GetAllPaginadoAsync(pageRequest, predicate);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.FuenteFinanciamientoResponse> CreateAsync(global::EG.Domain.DTOs.Responses.Presupuestales.FuenteFinanciamientoResponse response, global::System.Int32 usuarioCreacion) => service.CreateAsync(response, usuarioCreacion);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.FuenteFinanciamientoResponse> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Presupuestales.FuenteFinanciamientoResponse response, global::System.Int32 usuarioModificacion) => service.UpdateAsync(id, response, usuarioModificacion);
    public global::System.Threading.Tasks.Task<global::System.Boolean> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::System.Boolean> ExistsAsync(global::System.Int32 id) => service.ExistsAsync(id);
}
