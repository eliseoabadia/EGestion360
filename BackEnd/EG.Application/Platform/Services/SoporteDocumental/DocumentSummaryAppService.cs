using EG.Business.Interfaces;
using EG.Application.Interfaces.SoporteDocumental;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;
using EG.Domain.Interfaces;

namespace EG.Application.Services.SoporteDocumental;

public sealed class DocumentSummaryAppService(IDocumentSummaryQueries queries, IUserContextService userContext) : IDocumentSummaryAppService
{
    public async Task<PagedResult<DocumentoResumenResponse>> ReadBatchAsync(IReadOnlyList<DocumentoEntidadRequest> requests)
    {
        if (requests is null || requests.Count is < 1 or > 100 || requests.Any(request => request is null ||
            request.EntidadId <= 0 || string.IsNullOrWhiteSpace(request.Modulo) ||
            new[] { request.Modulo, request.SubModulo, request.Controlador, request.Servicio }.Any(value => value?.Length > 150)))
            throw new ArgumentException("El lote de resúmenes documentales no es válido.");
        var items = await queries.ReadBatchAsync(requests, userContext.GetCurrentEmpresaId());
        return new() { Success = true, Code = "SUCCESS", Message = "Resúmenes consultados", Items = items, TotalCount = items.Count };
    }
}
