using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class CedulaDiferenciasAppService(ICedulaDiferenciasOperations service) : ICedulaDiferenciasAppService
{
    public Task<PagedResult<CedulaDiferenciaResponse>> GetAllPaginadoAsync(PagedRequest request) => service.GetAllPaginadoAsync(request);
}
