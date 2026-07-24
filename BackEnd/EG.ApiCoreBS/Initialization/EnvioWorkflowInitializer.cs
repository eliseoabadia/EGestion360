using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Initialization;

internal static class EnvioWorkflowInitializer
{
    internal static async Task EnsureAsync(
        IServiceProvider services,
        ILogger logger,
        CancellationToken cancellationToken = default)
    {
        await using var scope = services.CreateAsyncScope();
        var context = scope.ServiceProvider.GetRequiredService<EGestionContext>();

        await context.Database.ExecuteSqlRawAsync(
            """
            IF SCHEMA_ID('SIS') IS NULL
                EXEC('CREATE SCHEMA [SIS]');

            IF OBJECT_ID('[SIS].[EnvioWorkflow]', 'U') IS NULL
            BEGIN
                CREATE TABLE [SIS].[EnvioWorkflow]
                (
                    [PKIdEnvioWorkflow] BIGINT IDENTITY(1,1) NOT NULL,
                    [Proceso] VARCHAR(60) NOT NULL,
                    [EntidadId] BIGINT NOT NULL,
                    [Estado] VARCHAR(20) NOT NULL,
                    [EstadoAnterior] VARCHAR(20) NULL,
                    [TokenOperacion] UNIQUEIDENTIFIER NULL,
                    [FechaEnvio] DATETIME2 NULL,
                    [FechaRechazo] DATETIME2 NULL,
                    [UsuarioEnvio] INT NULL,
                    [UsuarioRechazo] INT NULL,
                    [MotivoRechazo] NVARCHAR(500) NULL,
                    [FechaActualizacion] DATETIME2 NOT NULL
                        CONSTRAINT [DF_SIS_EnvioWorkflow_FechaActualizacion] DEFAULT (SYSDATETIME()),
                    CONSTRAINT [PK_SIS_EnvioWorkflow] PRIMARY KEY ([PKIdEnvioWorkflow]),
                    CONSTRAINT [UQ_SIS_EnvioWorkflow_ProcesoEntidad] UNIQUE ([Proceso], [EntidadId]),
                    CONSTRAINT [CK_SIS_EnvioWorkflow_Estado]
                        CHECK ([Estado] IN ('PENDIENTE', 'PROCESANDO', 'ENVIADO', 'RECHAZADO'))
                );
            END;
            """,
            cancellationToken);

        logger.LogInformation("Persistencia de estados de envío verificada.");
    }
}
