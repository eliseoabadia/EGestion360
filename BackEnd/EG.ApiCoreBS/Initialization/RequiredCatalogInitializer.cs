using System.Data;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Initialization;

/// <summary>
/// Garantiza los catalogos minimos que la aplicacion necesita para operar.
/// Es idempotente y respeta cualquier catalogo que ya haya sido configurado.
/// </summary>
internal static class RequiredCatalogInitializer
{
    internal static async Task EnsureAsync(
        IServiceProvider services,
        ILogger logger,
        CancellationToken cancellationToken = default)
    {
        await using var scope = services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<EGestionContext>();

        await EnsureDestinoGastoAsync(context, logger, cancellationToken);
    }

    private static async Task EnsureDestinoGastoAsync(
        EGestionContext context,
        ILogger logger,
        CancellationToken cancellationToken)
    {
        await context.ExecuteResilientTransactionAsync(
            async token =>
            {
                if (await context.DestinoGastos.AnyAsync(token))
                {
                    return;
                }

                var usuarioId = await context.Usuarios
                    .AsNoTracking()
                    .Where(usuario => usuario.Activo)
                    .OrderByDescending(usuario => usuario.EsAdministrador)
                    .ThenBy(usuario => usuario.PkIdUsuario)
                    .Select(usuario => usuario.PkIdUsuario)
                    .FirstOrDefaultAsync(token);

                if (usuarioId <= 0)
                {
                    logger.LogWarning(
                        "No se inicializo PRES.DestinoGasto porque no existe un usuario activo para la auditoria.");
                    return;
                }

                var now = DateTime.Now;
                context.DestinoGastos.AddRange(
                    new DestinoGasto
                    {
                        Clave = "1",
                        Descripcion = "DestinoGasto 1",
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioId
                    },
                    new DestinoGasto
                    {
                        Clave = "2",
                        Descripcion = "DestinoGasto 2",
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioId
                    },
                    new DestinoGasto
                    {
                        Clave = "3",
                        Descripcion = "DestinoGasto 3",
                        Activo = true,
                        FechaCreacion = now,
                        UsuarioCreacion = usuarioId
                    });

                await context.SaveChangesAsync(token);

                logger.LogInformation(
                    "Catalogo PRES.DestinoGasto inicializado con {Total} registros base.",
                    3);
            },
            IsolationLevel.Serializable,
            cancellationToken);
    }
}
