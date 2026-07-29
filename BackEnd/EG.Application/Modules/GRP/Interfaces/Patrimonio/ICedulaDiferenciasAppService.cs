using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Application.Interfaces.Patrimonio
{
    public interface ICedulaDiferenciasAppService
    {
        Task<PagedResult<CedulaDiferenciaResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
