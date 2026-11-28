using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Application.Modules.GRP.Services.Configuracion.Catalogo;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria;
public class TipoMonedaService(global::EG.Business.Services.Configuracion.Catalogo.Tesoreria.TipoMonedaServiceOperations service) : global::EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria.ITipoMonedaService

{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Tesoreria.TipoMonedaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Tesoreria.TipoMonedaResponse?> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Tesoreria.TipoMonedaResponse> CreateAsync(global::EG.Domain.DTOs.Requests.Tesoreria.TipoMonedaDto dto, global::System.Int32 usuarioId) => service.CreateAsync(dto, usuarioId);
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Tesoreria.TipoMonedaResponse?> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Requests.Tesoreria.TipoMonedaDto dto, global::System.Int32 usuarioId) => service.UpdateAsync(id, dto, usuarioId);
    public global::System.Threading.Tasks.Task DeleteAsync(global::System.Int32 id) => service.DeleteAsync(id);
    public global::System.Threading.Tasks.Task<global::System.Object> GetAllPaginadoAsync(global::System.Int32 page, global::System.Int32 pageSize, global::System.String? sortBy, global::System.String? sortDirection, global::System.String? filter) => service.GetAllPaginadoAsync(page, pageSize, sortBy, sortDirection, filter);
}
