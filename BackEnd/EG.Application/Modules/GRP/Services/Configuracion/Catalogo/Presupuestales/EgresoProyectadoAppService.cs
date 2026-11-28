using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Interfaces;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales;

public sealed class EgresoProyectadoAppService(IEgresoProyectadoOperations service) : IEgresoProyectadoAppService
{
    public Task<PagedResult<EgresoProyectadoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<EgresoProyectadoResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<EgresoProyectadoResponse>> CreateAsync(EgresoProyectadoResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<EgresoProyectadoResponse>> UpdateAsync(int id, EgresoProyectadoResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<EgresoProyectadoResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<bool>> EstaAutorizadoAsync(int id) => service.EstaAutorizadoAsync(id);
    public Task<PagedResult<LookupItem>> GetFuenteFinanciamientoLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetFuenteFinanciamientoLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<LookupItem>> GetTipoGastoLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetTipoGastoLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<LookupItem>> GetDigitoIdentificadorLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetDigitoIdentificadorLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<LookupItem>> GetDestinoGastoLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetDestinoGastoLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<LookupItem>> GetPyLookupPaginadoAsync(int page, int pageSize, string? filter) => service.GetPyLookupPaginadoAsync(page, pageSize, filter);
    public Task<PagedResult<EgresoProyectadoAiImportPreviewResponse>> PreviewAiImportAsync(EgresoProyectadoAiImportUploadRequest request, int usuarioActual) => service.PreviewAiImportAsync(request, usuarioActual);
    public Task<PagedResult<EgresoProyectadoAiImportPreviewResponse>> ConfirmAiImportAsync(EgresoProyectadoAiImportConfirmRequest request, int usuarioActual) => service.ConfirmAiImportAsync(request, usuarioActual);
}
