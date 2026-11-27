using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;

namespace EG.Application.Interfaces.SoporteDocumental;

public interface IDocumentSummaryAppService
{
    Task<PagedResult<DocumentoResumenResponse>> ReadBatchAsync(IReadOnlyList<DocumentoEntidadRequest> requests);
}
