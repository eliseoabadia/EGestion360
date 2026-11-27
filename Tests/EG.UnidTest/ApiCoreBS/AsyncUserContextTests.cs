using System.Security.Claims;
using EG.Application.Services.Security;
using EG.Domain.Interfaces;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.ApiCoreBS;

public sealed class AsyncUserContextTests
{
    [Fact]
    public async Task RequestInitializesScopeAsynchronouslyAndReusesItForSynchronousConsumers()
    {
        var queries = new AsyncQueries();
        var service = new UserContextService(new Request(), NullLogger<UserContextService>.Instance, queries);
        await service.InitializeAsync();
        await service.InitializeAsync();
        Assert.Equal(7, service.GetCurrentEmpresaId());
        Assert.Equal(2026, service.GetCurrentAnioPresupuestalId());
        Assert.Equal(1, queries.CompanyReads);
        Assert.Equal(1, queries.YearReads);
    }

    [Fact]
    public async Task DeniedAsyncScopeDoesNotFallBackToSynchronousQuery()
    {
        var service = new UserContextService(new Request(), NullLogger<UserContextService>.Instance, new AsyncQueries(false));
        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => service.InitializeAsync());
    }

    [Fact]
    public async Task CancelledRequestDoesNotQueryDatabase()
    {
        var queries = new AsyncQueries();
        var service = new UserContextService(new Request(), NullLogger<UserContextService>.Instance, queries);
        using var cancellation = new CancellationTokenSource();
        cancellation.Cancel();
        await Assert.ThrowsAnyAsync<OperationCanceledException>(() => service.InitializeAsync(cancellation.Token));
        Assert.Equal(0, queries.CompanyReads);
    }

    private sealed class Request : IUserRequestContext
    {
        public ClaimsPrincipal User { get; } = new(new ClaimsIdentity([new(ClaimTypes.NameIdentifier, "42")], "test"));
        public string? GetHeader(string name) => name switch
        {
            "X-Empresa-Id" => "7", "X-Anio-Presupuestal-Id" => "2026", _ => null
        };
    }

    private sealed class AsyncQueries(bool allowed = true) : IUserContextQueries
    {
        public int CompanyReads { get; private set; }
        public int YearReads { get; private set; }
        public bool CanAccessEmpresa(int usuarioId, int empresaId) => throw new InvalidOperationException("Synchronous database access is not allowed here.");
        public bool IsActiveAnio(int anioId) => throw new InvalidOperationException("Synchronous database access is not allowed here.");
        public async Task<bool> CanAccessEmpresaAsync(int userId, int companyId, CancellationToken token)
        {
            CompanyReads++;
            await Task.Yield();
            return allowed;
        }
        public async Task<bool> IsActiveAnioAsync(int yearId, CancellationToken token)
        {
            YearReads++;
            await Task.Yield();
            return true;
        }
    }
}
