using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Infrastructure;

public sealed class MatrizConversionReferences(EGestionContext context) : IMatrizConversionReferences
{
    public Task<bool> ProgramaMatchesExerciseAsync(int programaId, int anioId) =>
        context.Set<Programa>().AsNoTracking().AnyAsync(x => x.PkidPrograma == programaId && x.FkidAnioSis == anioId && x.Activo);

    public Task<bool> PartidaActiveAsync(int partidaId) =>
        context.Set<Partidum1>().AsNoTracking().AnyAsync(x => x.PkidPartida == partidaId && x.Activo);

    public Task<bool> TipoGastoActiveAsync(int tipoGastoId) =>
        context.TipoGastos.AsNoTracking().AnyAsync(x => x.PkidTipoGasto == tipoGastoId && x.Activo);

    public async Task<IReadOnlyList<AccountingAccountReference>> CuentasAsync(IEnumerable<int> ids)
    {
        var keys = ids.Distinct().ToArray();
        return await context.VwCuentas.AsNoTracking().Where(x => keys.Contains(x.PkIdCuenta))
            .Select(x => new AccountingAccountReference { Id = x.PkIdCuenta, Clave = x.ClaveOrd, Nivel = x.NivelCuenta, Activo = x.Activo })
            .ToListAsync();
    }
}
