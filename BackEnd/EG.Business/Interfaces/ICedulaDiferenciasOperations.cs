using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface ICedulaDiferenciasOperations
{
    Task<PagedResult<CedulaDiferenciaResponse>> GetAllPaginadoAsync(PagedRequest request);
}
