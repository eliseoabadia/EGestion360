using EG.Web.Models;

namespace EG.Web.Models.PresupuestoModificado;

public static class BudgetPageReader
{
    public static async Task<List<T>> ReadAllAsync<T>(
        Func<int, int, Task<ApiResponse<T>>> fetchPage,
        Func<T, int> getId,
        Func<bool> isCurrent)
    {
        const int pageSize = 250;
        var items = new List<T>();
        var identifiers = new HashSet<int>();
        int? expectedCount = null;

        for (var page = 1; ; page++)
        {
            EnsureCurrent(isCurrent);
            var response = await fetchPage(page, pageSize);
            EnsureCurrent(isCurrent);
            if (response?.Success != true || response.Items == null || response.TotalCount < 0)
                throw new InvalidOperationException("No fue posible consultar todos los movimientos.");

            expectedCount ??= response.TotalCount;
            if (expectedCount != response.TotalCount)
                throw new InvalidOperationException("Los movimientos cambiaron durante la consulta. Actualiza el tablero.");

            foreach (var item in response.Items)
            {
                if (!identifiers.Add(getId(item)))
                    throw new InvalidOperationException("Los movimientos cambiaron durante la consulta. Actualiza el tablero.");
                items.Add(item);
            }

            if (items.Count == expectedCount)
                return items;
            if (items.Count > expectedCount || response.Items.Count == 0)
                throw new InvalidOperationException("La consulta de movimientos está incompleta. Actualiza el tablero.");
        }
    }

    private static void EnsureCurrent(Func<bool> isCurrent)
    {
        if (!isCurrent())
            throw new OperationCanceledException("El contexto de la consulta cambió.");
    }
}
