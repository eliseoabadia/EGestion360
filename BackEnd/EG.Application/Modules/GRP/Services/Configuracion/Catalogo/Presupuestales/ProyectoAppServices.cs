using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Services;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales;
public class ProyectoAppServices(global::EG.Business.Services.Configuracion.Catalogo.Presupuestales.ProyectoOperationsServices service) : global::EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales.IProyectoAppServices

{
    public global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Presupuestales.ProyectoResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.ProyectoResponse> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Presupuestales.ProyectoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest pageRequest, global::System.Func<global::EG.Domain.DTOs.Responses.Presupuestales.ProyectoResponse,global::System.Boolean>? predicate = default) => service.GetAllPaginadoAsync(pageRequest, predicate);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.ProyectoResponse> CreateAsync(global::EG.Domain.DTOs.Responses.Presupuestales.ProyectoResponse response, global::System.Int32 usuarioCreacion) => service.CreateAsync(response, usuarioCreacion);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.ProyectoResponse> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Presupuestales.ProyectoResponse response, global::System.Int32 usuarioModificacion) => service.UpdateAsync(id, response, usuarioModificacion);
    public global::System.Threading.Tasks.Task<global::System.Boolean> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::System.Boolean> ExistsAsync(global::System.Int32 id) => service.ExistsAsync(id);
}
