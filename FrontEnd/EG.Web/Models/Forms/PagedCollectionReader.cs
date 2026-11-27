using EG.Web.Models;

namespace EG.Web.Models.Forms;

public static class PagedCollectionReader
{
    public const int MaximumValidationRows = 10_000;

    public static async Task<(List<T> Items, bool Limited)> ReadAsync<T>(
        Func<int, int, Task<ApiResponse<T>>> fetchPage, int requestedPageSize, int maximumRows,
        Func<bool>? isCurrent = null)
    {
        if (maximumRows < 1) throw new ArgumentOutOfRangeException(nameof(maximumRows));
        var pageSize = Math.Clamp(requestedPageSize, 1, EG.Common.GenericModel.PagingPolicy.MaximumPageSize);
        var items = new List<T>();
        int? expectedCount = null;
        for (var page = 1; ; page++)
        {
            if (isCurrent?.Invoke() == false) throw new OperationCanceledException("El contexto de consulta cambió.");
            var response = await fetchPage(page, pageSize);
            if (isCurrent?.Invoke() == false) throw new OperationCanceledException("El contexto de consulta cambió.");
            if (response?.Success != true || response.Items is null || response.TotalCount < 0)
                throw new InvalidOperationException(response?.Message ?? "No fue posible consultar todos los registros.");
            expectedCount ??= response.TotalCount;
            if (expectedCount != response.TotalCount)
                throw new InvalidOperationException("Los registros cambiaron durante la consulta. Actualiza e intenta nuevamente.");
            if (response.Items.Count == 0 && items.Count < expectedCount)
                throw new InvalidOperationException("La consulta paginada está incompleta.");
            items.AddRange(response.Items.Take(maximumRows - items.Count));
            if (items.Count > expectedCount)
                throw new InvalidOperationException("El total recibido no coincide con los registros consultados.");
            if (items.Count >= maximumRows || items.Count == expectedCount)
                return (items, expectedCount > maximumRows);
        }
    }
}
