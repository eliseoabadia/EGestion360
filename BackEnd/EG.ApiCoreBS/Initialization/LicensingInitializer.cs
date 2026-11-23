using System.Reflection;
using EG.Domain.Platform.Licensing;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Initialization;

internal static class LicensingInitializer
{
    private const string ScriptSuffix = "20260912_Licenciamiento_Modular_Local.sql";

    internal static async Task EnsureAsync(
        IServiceProvider services,
        ILogger logger,
        CancellationToken cancellationToken = default)
    {
        await using var scope = services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<EGestionContext>();
        var assembly = Assembly.GetExecutingAssembly();
        var resourceName = assembly.GetManifestResourceNames()
            .SingleOrDefault(name => name.EndsWith(ScriptSuffix, StringComparison.Ordinal));

        if (resourceName is null)
            throw new InvalidOperationException("No se encontró el script integrado de licenciamiento.");

        await using var stream = assembly.GetManifestResourceStream(resourceName)
            ?? throw new InvalidOperationException("No se pudo abrir el script integrado de licenciamiento.");
        using var reader = new StreamReader(stream);
        var script = await reader.ReadToEndAsync(cancellationToken);

        await context.Database.ExecuteSqlRawAsync(script, cancellationToken);

        var licensing = scope.ServiceProvider.GetRequiredService<ILicensingService>();
        await licensing.EnsureInitializedAsync(cancellationToken);

        logger.LogInformation("Esquema y estado local de licenciamiento verificados.");
    }
}
