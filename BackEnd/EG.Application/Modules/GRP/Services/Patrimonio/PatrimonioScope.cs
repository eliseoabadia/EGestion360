using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio;

internal readonly record struct PatrimonioScope(int EmpresaId, int Anio);

internal static class PatrimonioScopeResolver
{
    public static async Task<PatrimonioScope> RequireAsync(EGestionContext context, IUserContextService userContext)
    {
        var empresaId = userContext.GetCurrentEmpresaId();
        var anioId = userContext.GetCurrentAnioPresupuestalId();
        var anio = await context.Anios
            .AsNoTracking()
            .Where(x => x.PkidAnio == anioId && x.Activo)
            .Select(x => (int?)x.Clave)
            .SingleOrDefaultAsync();

        if (!anio.HasValue || anio.Value <= 0)
            throw new InvalidOperationException("El ejercicio presupuestal seleccionado no existe o está inactivo.");

        return new PatrimonioScope(empresaId, anio.Value);
    }
}
