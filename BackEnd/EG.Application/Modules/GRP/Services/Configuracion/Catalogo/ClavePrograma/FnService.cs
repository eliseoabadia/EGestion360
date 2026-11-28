using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
namespace EG.ApiCoreBS.Services.Catalogos.ClavePrograma;
public class FnService(global::EG.Business.Services.Catalogos.ClavePrograma.FnServiceOperations service) : global::EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma.IFnService

{
    public global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Presupuestales.FnResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.FnResponse?> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.FnResponse> AddAsync(global::EG.Domain.DTOs.Requests.Presupuestales.FnDto dto, global::System.Int32 usuarioId) => service.AddAsync(dto, usuarioId);
    public global::System.Threading.Tasks.Task UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Presupuestales.FnDto dto, global::System.Int32 usuarioId) => service.UpdateAsync(id, dto, usuarioId);
    public global::System.Threading.Tasks.Task DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::System.String?> GetDeleteBlockReasonAsync(global::System.Int32 id) => service.GetDeleteBlockReasonAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Presupuestales.FnResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::System.Boolean> CanAddAsync(global::EG.Domain.DTOs.Requests.Presupuestales.FnDto dto) => service.CanAddAsync(dto);
    public global::System.Threading.Tasks.Task<global::System.Boolean> CanUpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Presupuestales.FnDto dto) => service.CanUpdateAsync(id, dto);
}
