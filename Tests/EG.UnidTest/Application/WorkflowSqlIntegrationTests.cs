using EnvioWorkflowService = EG.Business.Services.General.EnvioWorkflowOperationsService;
using EG.Domain.DTOs.Responses.General;
using EG.Infrastructure;
using EG.Infraestructure.Models;
using EG.UnidTest.Support;
using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;

namespace EG.UnidTest.Application;

/// <summary>
/// Ejecuta el repositorio real sin correos ni firmas. Sólo crea estado técnico con
/// una clave única de prueba, que elimina en finally; no modifica documentos de negocio.
/// </summary>
public sealed class WorkflowSqlIntegrationTests
{
    private const string ConnectionString = "Data Source=.;Initial Catalog=GestionEmpresarial;Integrated Security=True;TrustServerCertificate=True;Application Name=EGestion360-Development-WorkflowTest;Connect Timeout=5";

    [DevelopmentSqlFact]
    [Trait("Category", "DevelopmentSql")]
    public async Task RealRepositoryProtectsConcurrentSendRejectResendCancelAndReload()
    {
        var process = $"DEVTEST_{Guid.NewGuid():N}";
        const long entityId = 1;
        await using var context = CreateContext();
        var actor = await context.Usuarios.AsNoTracking().Where(user => user.Activo)
            .OrderBy(user => user.PkIdUsuario).Select(user => user.PkIdUsuario).FirstAsync();
        var service = new EnvioWorkflowService(new EnvioWorkflowRepository(context));
        try
        {
            Assert.Equal(EnvioWorkflowEstados.Pendiente, (await service.GetAsync(process, entityId)).Estado);
            var contenders = await Task.WhenAll(Enumerable.Range(0, 16).Select(async _ =>
            {
                await using var contenderContext = CreateContext();
                var contender = new EnvioWorkflowService(new EnvioWorkflowRepository(contenderContext));
                return await contender.TryBeginAsync(process, entityId, actor);
            }));
            var winner = Assert.Single(contenders, result => result.Claimed);
            var token = winner.OperationToken!.Value;
            Assert.Equal(EnvioWorkflowEstados.Procesando, winner.State.Estado);

            await Assert.ThrowsAsync<InvalidOperationException>(() => service.CompleteAsync(process, entityId, Guid.NewGuid()));
            await Assert.ThrowsAsync<InvalidOperationException>(() => service.RejectAsync(process, entityId, actor, "No procede durante envío"));
            Assert.Equal(EnvioWorkflowEstados.Procesando, (await service.GetAsync(process, entityId)).Estado);

            await service.CompleteAsync(process, entityId, token);
            await Assert.ThrowsAsync<InvalidOperationException>(() => service.CompleteAsync(process, entityId, token));
            Assert.False((await service.TryBeginAsync(process, entityId, actor)).Claimed);

            var rejected = await service.RejectAsync(process, entityId, actor, " Corregir antes de reenviar ");
            Assert.Equal(EnvioWorkflowEstados.Rechazado, rejected.Estado);
            Assert.Equal("Corregir antes de reenviar", rejected.MotivoRechazo);
            Assert.NotNull(rejected.FechaRechazo);

            var retry = await service.TryBeginAsync(process, entityId, actor);
            Assert.True(retry.Claimed);
            await Assert.ThrowsAsync<InvalidOperationException>(() => service.CancelAsync(process, entityId, token));
            await service.CancelAsync(process, entityId, retry.OperationToken!.Value);
            Assert.Equal(EnvioWorkflowEstados.Rechazado, (await service.GetAsync(process, entityId)).Estado);

            var final = await service.TryBeginAsync(process, entityId, actor);
            await service.CompleteAsync(process, entityId, final.OperationToken!.Value);
            await using var reloadedContext = CreateContext();
            var reloaded = await new EnvioWorkflowRepository(reloadedContext).GetAsync(process, entityId);
            Assert.Equal(EnvioWorkflowEstados.Enviado, reloaded.Estado);
            Assert.NotNull(reloaded.FechaEnvio);
            Assert.Null(reloaded.MotivoRechazo);
        }
        finally
        {
            // Se elimina únicamente el estado técnico propiedad de esta ejecución.
            await context.Database.ExecuteSqlRawAsync(
                "DELETE FROM SIS.EnvioWorkflow WHERE Proceso = @Process AND EntidadId = @EntityId",
                new SqlParameter("@Process", process), new SqlParameter("@EntityId", entityId));
        }
    }

    private static EGestionContext CreateContext() => new(new DbContextOptionsBuilder<EGestionContext>()
        .UseSqlServer(ConnectionString, options => options.CommandTimeout(10)).Options);
}
