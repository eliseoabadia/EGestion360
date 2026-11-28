using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Business.Interfaces;

public interface IPolizaOperations
{
    Task<PagedResult<PolizaResponse>> GetAllAsync();
    Task<PagedResult<PolizaResponse>> GetByIdAsync(int id);
    Task<PagedResult<PolizaResponse>> CreateAsync(PolizaResponse response, int usuarioActual);
    Task<PagedResult<PolizaResponse>> UpdateAsync(int id, PolizaResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<PolizaResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
    Task<PagedResult<PolizaAiImportPreviewResponse>> PreviewAiImportAsync(PolizaAiImportUploadRequest request, int usuarioActual);
    Task<PagedResult<PolizaAiImportPreviewResponse>> ConfirmAiImportAsync(PolizaAiImportConfirmRequest request, int usuarioActual);
}
