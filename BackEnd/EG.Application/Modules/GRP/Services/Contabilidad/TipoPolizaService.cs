using Mapster;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
namespace EG.ApiCoreBS.Services.Contabilidad;
public class TipoPolizaService(global::EG.Business.Services.Contabilidad.TipoPolizaServiceOperations service) : global::EG.Application.Interfaces.Contabilidad.ITipoPolizaService

{
    public global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Contabilidad.TipoPolizaResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Contabilidad.TipoPolizaResponse?> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Contabilidad.TipoPolizaResponse> AddAsync(global::EG.Domain.DTOs.Requests.Contabilidad.TipoPolizaDto dto, global::System.Int32 usuarioId) => service.AddAsync(dto, usuarioId);
    public global::System.Threading.Tasks.Task UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Contabilidad.TipoPolizaDto dto, global::System.Int32 usuarioId) => service.UpdateAsync(id, dto, usuarioId);
    public global::System.Threading.Tasks.Task DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Contabilidad.TipoPolizaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::System.Boolean> CanAddAsync(global::EG.Domain.DTOs.Requests.Contabilidad.TipoPolizaDto dto) => service.CanAddAsync(dto);
    public global::System.Threading.Tasks.Task<global::System.Boolean> CanUpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Contabilidad.TipoPolizaDto dto) => service.CanUpdateAsync(id, dto);
}
