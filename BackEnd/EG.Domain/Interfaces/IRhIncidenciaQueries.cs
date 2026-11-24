using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Domain.Interfaces;

public sealed record RhIncidenciaFilter(int Page, int PageSize, string Filter, string? SortLabel, string? SortDirection);
public sealed record RhIncidenciaPage(IList<VwRhIncidenciaResponse> Items, int TotalCount);

public interface IRhIncidenciaQueries
{
    Task<RhIncidenciaPage> GetAsync(RhIncidenciaFilter request, int empresaId);
}
