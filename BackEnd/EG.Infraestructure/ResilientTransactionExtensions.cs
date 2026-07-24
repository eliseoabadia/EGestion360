using System.Data;
using Microsoft.EntityFrameworkCore;

namespace EG.Infraestructure.Models;

/// <summary>
/// Ejecuta una transaccion manual dentro de la estrategia de reintentos
/// configurada para SQL Server.
/// </summary>
public static class ResilientTransactionExtensions
{
    public static async Task<TResult> ExecuteResilientTransactionAsync<TResult>(
        this DbContext context,
        Func<CancellationToken, Task<TResult>> operation,
        IsolationLevel isolationLevel = IsolationLevel.ReadCommitted,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(context);
        ArgumentNullException.ThrowIfNull(operation);

        if (context.Database.CurrentTransaction != null)
        {
            return await operation(cancellationToken);
        }

        var strategy = context.Database.CreateExecutionStrategy();
        return await strategy.ExecuteAsync(async () =>
        {
            await using var transaction = await context.Database.BeginTransactionAsync(
                isolationLevel,
                cancellationToken);

            var result = await operation(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
            return result;
        });
    }

    public static async Task ExecuteResilientTransactionAsync(
        this DbContext context,
        Func<CancellationToken, Task> operation,
        IsolationLevel isolationLevel = IsolationLevel.ReadCommitted,
        CancellationToken cancellationToken = default)
    {
        await context.ExecuteResilientTransactionAsync(
            async token =>
            {
                await operation(token);
                return true;
            },
            isolationLevel,
            cancellationToken);
    }
}
