using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IEgresoProyectadoAppService : IAdquisicionCrudAppService<EgresoProyectadoResponse>
    {
        Task<PagedResult<bool>> EstaAutorizadoAsync(int id);
        Task<PagedResult<LookupItem>> GetFuenteFinanciamientoLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetTipoGastoLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetDigitoIdentificadorLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetDestinoGastoLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<LookupItem>> GetPyLookupPaginadoAsync(int page, int pageSize, string? filter);
        Task<PagedResult<EgresoProyectadoAiImportPreviewResponse>> PreviewAiImportAsync(EgresoProyectadoAiImportUploadRequest request, int usuarioActual);
        Task<PagedResult<EgresoProyectadoAiImportPreviewResponse>> ConfirmAiImportAsync(EgresoProyectadoAiImportConfirmRequest request, int usuarioActual);
    }
}
