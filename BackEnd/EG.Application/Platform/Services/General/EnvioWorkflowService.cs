using System.Data;
using EG.Application.Interfaces.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General;

public sealed class EnvioWorkflowService : IEnvioWorkflowService
{
    private const int MaxProcesoLength = 60;
    private readonly EGestionContext _context;

    public EnvioWorkflowService(EGestionContext context)
    {
        _context = context;
    }

    public async Task<EnvioWorkflowEstadoResponse> GetAsync(
        string proceso,
        long entidadId,
        CancellationToken cancellationToken = default)
    {
        Validate(proceso, entidadId);

        var states = await GetManyAsync(proceso, new[] { entidadId }, cancellationToken);
        return states[entidadId];
    }

    public async Task<IReadOnlyDictionary<long, EnvioWorkflowEstadoResponse>> GetManyAsync(
        string proceso,
        IEnumerable<long> entidadIds,
        CancellationToken cancellationToken = default)
    {
        ValidateProcess(proceso);
        var ids = entidadIds.Where(x => x > 0).Distinct().ToArray();
        var result = ids.ToDictionary(x => x, Pending);
        if (ids.Length == 0)
        {
            return result;
        }

        var connection = _context.Database.GetDbConnection();
        var shouldClose = connection.State != ConnectionState.Open;
        if (shouldClose)
        {
            await connection.OpenAsync(cancellationToken);
        }

        try
        {
            await using var command = connection.CreateCommand();
            command.CommandText = $"""
                SELECT EntidadId, Estado, FechaEnvio, FechaRechazo, MotivoRechazo
                FROM [SIS].[EnvioWorkflow]
                WHERE Proceso = @Proceso
                  AND EntidadId IN ({string.Join(", ", ids.Select((_, index) => $"@Id{index}"))});
                """;
            command.Parameters.Add(new SqlParameter("@Proceso", SqlDbType.VarChar, MaxProcesoLength) { Value = proceso });
            for (var index = 0; index < ids.Length; index++)
            {
                command.Parameters.Add(new SqlParameter($"@Id{index}", SqlDbType.BigInt) { Value = ids[index] });
            }

            await using var reader = await command.ExecuteReaderAsync(cancellationToken);
            while (await reader.ReadAsync(cancellationToken))
            {
                var state = ReadState(reader);
                result[state.EntidadId] = state;
            }
        }
        finally
        {
            if (shouldClose)
            {
                await connection.CloseAsync();
            }
        }

        return result;
    }

    public async Task<EnvioWorkflowClaimResult> TryBeginAsync(
        string proceso,
        long entidadId,
        int usuarioId,
        CancellationToken cancellationToken = default)
    {
        Validate(proceso, entidadId);
        var token = Guid.NewGuid();
        var now = DateTime.Now;

        await _context.Database.ExecuteSqlRawAsync(
            """
            SET XACT_ABORT ON;
            BEGIN TRANSACTION;

            UPDATE [SIS].[EnvioWorkflow] WITH (UPDLOCK, HOLDLOCK)
               SET Estado = 'PROCESANDO',
                   EstadoAnterior = Estado,
                   TokenOperacion = @Token,
                   UsuarioEnvio = @Usuario,
                   FechaActualizacion = @Ahora
             WHERE Proceso = @Proceso
               AND EntidadId = @EntidadId
               AND Estado IN ('PENDIENTE', 'RECHAZADO');

            IF @@ROWCOUNT = 0
               AND NOT EXISTS (
                   SELECT 1
                   FROM [SIS].[EnvioWorkflow] WITH (UPDLOCK, HOLDLOCK)
                   WHERE Proceso = @Proceso AND EntidadId = @EntidadId
               )
            BEGIN
                INSERT INTO [SIS].[EnvioWorkflow]
                    (Proceso, EntidadId, Estado, EstadoAnterior, TokenOperacion, UsuarioEnvio, FechaActualizacion)
                VALUES
                    (@Proceso, @EntidadId, 'PROCESANDO', 'PENDIENTE', @Token, @Usuario, @Ahora);
            END;

            COMMIT TRANSACTION;
            """,
            new SqlParameter("@Token", SqlDbType.UniqueIdentifier) { Value = token },
            new SqlParameter("@Usuario", SqlDbType.Int) { Value = usuarioId },
            new SqlParameter("@Ahora", SqlDbType.DateTime2) { Value = now },
            new SqlParameter("@Proceso", SqlDbType.VarChar, MaxProcesoLength) { Value = proceso },
            new SqlParameter("@EntidadId", SqlDbType.BigInt) { Value = entidadId });

        var state = await GetAsync(proceso, entidadId, cancellationToken);
        var claimed = await OwnsClaimAsync(proceso, entidadId, token, cancellationToken);
        return new EnvioWorkflowClaimResult(claimed, claimed ? token : null, state);
    }

    public async Task CompleteAsync(
        string proceso,
        long entidadId,
        Guid operationToken,
        CancellationToken cancellationToken = default)
    {
        Validate(proceso, entidadId);
        var affected = await _context.Database.ExecuteSqlRawAsync(
            """
            UPDATE [SIS].[EnvioWorkflow]
               SET Estado = 'ENVIADO',
                   EstadoAnterior = NULL,
                   TokenOperacion = NULL,
                   FechaEnvio = @Ahora,
                   FechaRechazo = NULL,
                   UsuarioRechazo = NULL,
                   MotivoRechazo = NULL,
                   FechaActualizacion = @Ahora
             WHERE Proceso = @Proceso
               AND EntidadId = @EntidadId
               AND Estado = 'PROCESANDO'
               AND TokenOperacion = @Token;
            """,
            new SqlParameter("@Ahora", SqlDbType.DateTime2) { Value = DateTime.Now },
            new SqlParameter("@Proceso", SqlDbType.VarChar, MaxProcesoLength) { Value = proceso },
            new SqlParameter("@EntidadId", SqlDbType.BigInt) { Value = entidadId },
            new SqlParameter("@Token", SqlDbType.UniqueIdentifier) { Value = operationToken });

        EnsureTransitionOwned(affected);
    }

    public async Task CancelAsync(
        string proceso,
        long entidadId,
        Guid operationToken,
        CancellationToken cancellationToken = default)
    {
        Validate(proceso, entidadId);
        var affected = await _context.Database.ExecuteSqlRawAsync(
            """
            UPDATE [SIS].[EnvioWorkflow]
               SET Estado = COALESCE(EstadoAnterior, 'PENDIENTE'),
                   EstadoAnterior = NULL,
                   TokenOperacion = NULL,
                   FechaActualizacion = @Ahora
             WHERE Proceso = @Proceso
               AND EntidadId = @EntidadId
               AND Estado = 'PROCESANDO'
               AND TokenOperacion = @Token;
            """,
            new SqlParameter("@Ahora", SqlDbType.DateTime2) { Value = DateTime.Now },
            new SqlParameter("@Proceso", SqlDbType.VarChar, MaxProcesoLength) { Value = proceso },
            new SqlParameter("@EntidadId", SqlDbType.BigInt) { Value = entidadId },
            new SqlParameter("@Token", SqlDbType.UniqueIdentifier) { Value = operationToken });

        EnsureTransitionOwned(affected);
    }

    public async Task<EnvioWorkflowEstadoResponse> RejectAsync(
        string proceso,
        long entidadId,
        int usuarioId,
        string? motivo,
        CancellationToken cancellationToken = default)
    {
        Validate(proceso, entidadId);

        var affected = await _context.Database.ExecuteSqlRawAsync(
            """
            UPDATE [SIS].[EnvioWorkflow]
               SET Estado = 'RECHAZADO',
                   EstadoAnterior = NULL,
                   TokenOperacion = NULL,
                   FechaRechazo = @Ahora,
                   UsuarioRechazo = @Usuario,
                   MotivoRechazo = @Motivo,
                   FechaActualizacion = @Ahora
             WHERE Proceso = @Proceso
               AND EntidadId = @EntidadId
               AND Estado = 'ENVIADO';
            """,
            new SqlParameter("@Ahora", SqlDbType.DateTime2) { Value = DateTime.Now },
            new SqlParameter("@Usuario", SqlDbType.Int) { Value = usuarioId },
            new SqlParameter("@Motivo", SqlDbType.NVarChar, 500) { Value = (object?)motivo?.Trim() ?? DBNull.Value },
            new SqlParameter("@Proceso", SqlDbType.VarChar, MaxProcesoLength) { Value = proceso },
            new SqlParameter("@EntidadId", SqlDbType.BigInt) { Value = entidadId });

        var state = await GetAsync(proceso, entidadId, cancellationToken);
        if (affected == 0)
        {
            throw new InvalidOperationException(
                state.Estado == EnvioWorkflowEstados.Rechazado
                    ? "El envío ya estaba rechazado."
                    : "Solo se puede rechazar un envío que se encuentre ENVIADO.");
        }

        return state;
    }

    private async Task<bool> OwnsClaimAsync(
        string proceso,
        long entidadId,
        Guid token,
        CancellationToken cancellationToken)
    {
        var connection = _context.Database.GetDbConnection();
        var shouldClose = connection.State != ConnectionState.Open;
        if (shouldClose)
        {
            await connection.OpenAsync(cancellationToken);
        }

        try
        {
            await using var command = connection.CreateCommand();
            command.CommandText = """
                SELECT COUNT(1)
                FROM [SIS].[EnvioWorkflow]
                WHERE Proceso = @Proceso
                  AND EntidadId = @EntidadId
                  AND Estado = 'PROCESANDO'
                  AND TokenOperacion = @Token;
                """;
            command.Parameters.Add(new SqlParameter("@Proceso", SqlDbType.VarChar, MaxProcesoLength) { Value = proceso });
            command.Parameters.Add(new SqlParameter("@EntidadId", SqlDbType.BigInt) { Value = entidadId });
            command.Parameters.Add(new SqlParameter("@Token", SqlDbType.UniqueIdentifier) { Value = token });
            return Convert.ToInt32(await command.ExecuteScalarAsync(cancellationToken)) == 1;
        }
        finally
        {
            if (shouldClose)
            {
                await connection.CloseAsync();
            }
        }
    }

    private static void EnsureTransitionOwned(int affected)
    {
        if (affected == 0)
        {
            throw new InvalidOperationException("La operación de envío ya no posee el bloqueo vigente.");
        }
    }

    private static EnvioWorkflowEstadoResponse ReadState(IDataRecord reader)
    {
        return new EnvioWorkflowEstadoResponse
        {
            EntidadId = reader.GetInt64(0),
            Estado = EnvioWorkflowEstados.Normalizar(reader.GetString(1)),
            FechaEnvio = reader.IsDBNull(2) ? null : reader.GetDateTime(2),
            FechaRechazo = reader.IsDBNull(3) ? null : reader.GetDateTime(3),
            MotivoRechazo = reader.IsDBNull(4) ? null : reader.GetString(4)
        };
    }

    private static EnvioWorkflowEstadoResponse Pending(long entidadId)
    {
        return new EnvioWorkflowEstadoResponse { EntidadId = entidadId };
    }

    private static void Validate(string proceso, long entidadId)
    {
        ValidateProcess(proceso);
        if (entidadId <= 0)
        {
            throw new ArgumentOutOfRangeException(nameof(entidadId));
        }
    }

    private static void ValidateProcess(string proceso)
    {
        if (string.IsNullOrWhiteSpace(proceso) || proceso.Length > MaxProcesoLength)
        {
            throw new ArgumentException("El proceso de envío no es válido.", nameof(proceso));
        }
    }
}
