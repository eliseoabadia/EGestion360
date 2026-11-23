using EG.Domain.Platform.Licensing;

namespace EG.ApiCoreBS.Services.Licensing;

public sealed class LicenseClockPersistenceService(
    IServiceScopeFactory scopeFactory,
    ILogger<LicenseClockPersistenceService> logger) : BackgroundService
{
    private static readonly TimeSpan Interval = TimeSpan.FromMinutes(10);

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        using var timer = new PeriodicTimer(Interval);

        while (await timer.WaitForNextTickAsync(stoppingToken))
        {
            try
            {
                await using var scope = scopeFactory.CreateAsyncScope();
                var licensing = scope.ServiceProvider.GetRequiredService<ILicensingService>();
                await licensing.PersistTrustedClockAsync(stoppingToken);
            }
            catch (OperationCanceledException) when (stoppingToken.IsCancellationRequested)
            {
                return;
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "No se pudo persistir el reloj protegido de licenciamiento.");
            }
        }
    }
}
