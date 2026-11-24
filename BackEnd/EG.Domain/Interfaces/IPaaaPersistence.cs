using EG.Domain.DTOs.Requests.Adquisicion;

namespace EG.Domain.Interfaces;

public enum PaaaWriteAction
{
    Create = 1, Update = 2, Delete = 3,
    CreatePartida = 5, DeletePartida = 6,
    CreateDetalle = 7, UpdateDetalle = 8, DeleteDetalle = 9
}

public sealed class PaaaWriteCommand
{
    public PaaaWriteAction Action { get; init; }
    public int Id { get; init; }
    public int PaaaId { get; init; }
    public int EmpresaId { get; init; }
    public int UsuarioId { get; init; }
    public PaaaDto? Header { get; init; }
    public PaaaspartidaDto? Partida { get; init; }
    public PaaasdetalleDto? Detalle { get; init; }
}

public sealed record PaaaWriteResult(int? Id, string Message);

public interface IPaaaPersistence
{
    Task<PaaaWriteResult> ExecuteAsync(PaaaWriteCommand command);
}
