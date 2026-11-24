namespace EG.Domain.Interfaces;

public sealed class AccountingAccountReference
{
    public int Id { get; set; }
    public string? Clave { get; set; }
    public int? Nivel { get; set; }
    public bool Activo { get; set; }
}

public interface IMatrizConversionReferences
{
    Task<bool> ProgramaMatchesExerciseAsync(int programaId, int anioId);
    Task<bool> PartidaActiveAsync(int partidaId);
    Task<bool> TipoGastoActiveAsync(int tipoGastoId);
    Task<IReadOnlyList<AccountingAccountReference>> CuentasAsync(IEnumerable<int> ids);
}
