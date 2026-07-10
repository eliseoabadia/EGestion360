using EG.Application.Services.DocumentRag;
using EG.Domain.Platform.Settings;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EG.ApiCoreBS.Services.DocumentRag
{
    public sealed class DocumentRagCleanupHostedService(
        DocumentRagAppService ragService,
        IOptions<DocumentRagSettings> settings,
        ILogger<DocumentRagCleanupHostedService> logger) : BackgroundService
    {
        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var intervalSeconds = Math.Max(30, settings.Value.CleanupIntervalSeconds);
            using var timer = new PeriodicTimer(TimeSpan.FromSeconds(intervalSeconds));

            while (await timer.WaitForNextTickAsync(stoppingToken))
            {
                try
                {
                    ragService.CleanupExpiredSessions();
                }
                catch (Exception ex)
                {
                    logger.LogError(ex, "No fue posible liberar sesiones RAG expiradas.");
                }
            }
        }
    }
}
