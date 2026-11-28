using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
namespace EG.ApiCoreBS.Services.Catalogos.ClavePrograma;
public class GfService(global::EG.Business.Services.Catalogos.ClavePrograma.GfServiceOperations service) : global::EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma.IGfService

{
    public global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Presupuestales.GfResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.GfResponse> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.GfResponse> AddAsync(global::EG.Domain.DTOs.Requests.Presupuestales.GfDto dto, global::System.Int32 usuarioCreacion) => service.AddAsync(dto, usuarioCreacion);
    public global::System.Threading.Tasks.Task UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Presupuestales.GfDto dto, global::System.Int32 usuarioModificacion) => service.UpdateAsync(id, dto, usuarioModificacion);
    public global::System.Threading.Tasks.Task DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Presupuestales.GfResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::System.Boolean> CanAddAsync(global::EG.Domain.DTOs.Requests.Presupuestales.GfDto dto) => service.CanAddAsync(dto);
    public global::System.Threading.Tasks.Task<global::System.Boolean> CanUpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Presupuestales.GfDto dto) => service.CanUpdateAsync(id, dto);
}
