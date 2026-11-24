using EG.Application.Interfaces.Nomina;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.Interfaces;

namespace EG.Application.Services.Nomina;

public sealed class NominaRhIncidenciaListadoAppService(IRhIncidenciaQueries queries, IUserContextService userContext)
    : INominaRhIncidenciaListadoAppService
{
    public async Task<PagedResult<VwRhIncidenciaResponse>> GetAllPaginadoAsync(PagedRequest request)
    {
        var filter = new RhIncidenciaFilter(request.Page, request.PageSize,
            (request.Filtro ?? request.SearchString ?? string.Empty).Trim(), request.SortLabel, request.SortDirection);
        var page = await queries.GetAsync(filter, userContext.GetCurrentEmpresaId());
        return new()
        {
            Success = true,
            Code = "SUCCESS",
            Message = "Incidencias obtenidas correctamente.",
            Items = page.Items,
            Data = page.Items.FirstOrDefault(),
            TotalCount = page.TotalCount
        };
    }
}
