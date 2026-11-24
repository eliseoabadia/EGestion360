using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Domain.Interfaces;

public interface IResguardoMovimientoQueries
{
    Task<ResguardoMovimientoPage> GetAllAsync(int empresaId, int anioId);
    Task<ResguardoMovimientoResponse?> GetByIdAsync(int id, int empresaId, int anioId);
    Task<ResguardoMovimientoPage> GetAllPaginadoAsync(ResguardoMovimientoFilter request, int empresaId, int anioId);
}

public sealed record ResguardoMovimientoPage(IList<ResguardoMovimientoResponse> Items, int TotalCount);
public sealed record ResguardoMovimientoFilter(int Page, int PageSize, string? SearchString, string? SortLabel, string? SortDirection);
