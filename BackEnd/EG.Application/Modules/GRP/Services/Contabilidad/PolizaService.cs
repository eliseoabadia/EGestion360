using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Interfaces;

namespace EG.ApiCoreBS.Services.Contabilidad;

public sealed class PolizaService(IPolizaOperations service) : IPolizaService
{
    public Task<PagedResult<PolizaResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<PagedResult<PolizaResponse>> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<PagedResult<PolizaResponse>> CreateAsync(PolizaResponse response, int usuarioActual) => service.CreateAsync(response, usuarioActual);
    public Task<PagedResult<PolizaResponse>> UpdateAsync(int id, PolizaResponse response, int usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public Task<PagedResult<bool>> DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<PolizaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
    public Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public Task<PagedResult<PolizaAiImportPreviewResponse>> PreviewAiImportAsync(PolizaAiImportUploadRequest request, int usuarioActual) => service.PreviewAiImportAsync(request, usuarioActual);
    public Task<PagedResult<PolizaAiImportPreviewResponse>> ConfirmAiImportAsync(PolizaAiImportConfirmRequest request, int usuarioActual) => service.ConfirmAiImportAsync(request, usuarioActual);
}
