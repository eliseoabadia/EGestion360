using EG.Common.Exceptions;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.PresupuestoModificado;

internal readonly record struct PresupuestoModificadoScope(int EmpresaId, int AnioId, int AnioClave);

internal static class PresupuestoModificadoScopeResolver
{
    public static async Task<PresupuestoModificadoScope> RequireAsync(
        EGestionContext context,
        IUserContextService userContext,
        CancellationToken cancellationToken = default)
    {
        var empresaId = userContext.TryGetCurrentEmpresaId();
        if (empresaId is not > 0)
            throw new UserVisibleException("No se encontro la empresa activa en la sesion.", "EMPRESA_REQUIRED");

        var anioId = userContext.TryGetCurrentAnioPresupuestalId();
        if (anioId is not > 0)
            throw new UserVisibleException("Selecciona un ejercicio presupuestal activo.", "ANIO_REQUIRED");

        var anio = await context.Anios
            .AsNoTracking()
            .Where(x => x.PkidAnio == anioId.Value && x.Activo)
            .Select(x => new { x.PkidAnio, x.Clave })
            .FirstOrDefaultAsync(cancellationToken);

        if (anio == null)
            throw new UserVisibleException("El ejercicio presupuestal seleccionado no esta activo.", "ANIO_INVALID");

        return new PresupuestoModificadoScope(empresaId.Value, anio.PkidAnio, anio.Clave);
    }
}
