using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Interfaces;

namespace EG.ApiCoreBS.Services.Contabilidad;

public sealed class ConceptoService(IConceptoOperations service) : IConceptoService
{
    public Task<PagedResult<ConceptoResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<ConceptoResponse?> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<ConceptoResponse> CreateAsync(ConceptoResponse response, int usuarioId) => service.CreateAsync(response, usuarioId);
    public Task<ConceptoResponse?> UpdateAsync(int id, ConceptoResponse response, int usuarioId) => service.UpdateAsync(id, response, usuarioId);
    public Task DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<ConceptoResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
