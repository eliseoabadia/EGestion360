using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;

namespace EG.Business.Interfaces;

public interface IDocumentSummaryQueries
{
    Task<List<DocumentoResumenResponse>> ReadBatchAsync(IReadOnlyList<DocumentoEntidadRequest> requests, int empresaId);
}
