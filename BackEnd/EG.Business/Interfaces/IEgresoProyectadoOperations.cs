using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Business.Interfaces;

public interface IEgresoProyectadoOperations
{
    Task<PagedResult<EgresoProyectadoResponse>> GetAllAsync();
    Task<PagedResult<EgresoProyectadoResponse>> GetByIdAsync(int id);
    Task<PagedResult<EgresoProyectadoResponse>> CreateAsync(EgresoProyectadoResponse response, int usuarioActual);
    Task<PagedResult<EgresoProyectadoResponse>> UpdateAsync(int id, EgresoProyectadoResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<EgresoProyectadoResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<bool>> EstaAutorizadoAsync(int id);
    Task<PagedResult<LookupItem>> GetFuenteFinanciamientoLookupPaginadoAsync(int page, int pageSize, string? filter);
    Task<PagedResult<LookupItem>> GetTipoGastoLookupPaginadoAsync(int page, int pageSize, string? filter);
    Task<PagedResult<LookupItem>> GetDigitoIdentificadorLookupPaginadoAsync(int page, int pageSize, string? filter);
    Task<PagedResult<LookupItem>> GetDestinoGastoLookupPaginadoAsync(int page, int pageSize, string? filter);
    Task<PagedResult<LookupItem>> GetPyLookupPaginadoAsync(int page, int pageSize, string? filter);
    Task<PagedResult<EgresoProyectadoAiImportPreviewResponse>> PreviewAiImportAsync(EgresoProyectadoAiImportUploadRequest request, int usuarioActual);
    Task<PagedResult<EgresoProyectadoAiImportPreviewResponse>> ConfirmAiImportAsync(EgresoProyectadoAiImportConfirmRequest request, int usuarioActual);
}
