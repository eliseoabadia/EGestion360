using System.Security.Claims;
using EG.Application.Services.Security;
using EG.Domain.Interfaces;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.ApiCoreBS;

public sealed class UserContextBoundaryTests
{
    [Theory]
    [InlineData(true, 9)]
    public void SelectedCompanyUsesBusinessAccessCheck(bool allowed, int expected)
    {
        var request = new RequestContext("X-Empresa-Id", "9");
        var queries = new Queries(allowed);
        var service = new UserContextService(request, NullLogger<UserContextService>.Instance, queries);

        Assert.Equal(expected, service.TryGetCurrentEmpresaId());
        Assert.Equal((42, 9), queries.AccessCheck);
    }

    [Theory]
    [InlineData(true, 3)]
    [InlineData(false, null)]
    public void SelectedYearRequiresActiveBusinessResult(bool active, int? expected)
    {
        var service = new UserContextService(new RequestContext("X-Anio-Presupuestal-Id", "3"),
            NullLogger<UserContextService>.Instance, new Queries(active));
        Assert.Equal(expected, service.TryGetCurrentAnioPresupuestalId());
    }

    [Fact]
    public void AccessQueryFailureDoesNotAcceptSelectedCompany()
    {
        var service = new UserContextService(new RequestContext("X-Empresa-Id", "9"),
            NullLogger<UserContextService>.Instance, new Queries(false, true));
        Assert.Throws<UnauthorizedAccessException>(() => service.TryGetCurrentEmpresaId());
    }

    [Theory]
    [InlineData("9")]
    [InlineData("0")]
    [InlineData("-1")]
    [InlineData("company-9")]
    [InlineData("")]
    [InlineData("9,7")]
    public void DeniedOrInvalidSelectionCannotFallBackToTokenCompany(string selected)
    {
        var service = new UserContextService(new RequestContext("X-Empresa-Id", selected),
            NullLogger<UserContextService>.Instance, new Queries(false));
        Assert.Throws<UnauthorizedAccessException>(() => service.TryGetCurrentEmpresaId());
    }

    [Fact]
    public void TokenCompanyAlsoRequiresCurrentAccess()
    {
        var queries = new Queries(false);
        var service = new UserContextService(new RequestContext("unused", ""),
            NullLogger<UserContextService>.Instance, queries);
        Assert.Throws<UnauthorizedAccessException>(() => service.TryGetCurrentEmpresaId());
        Assert.Equal((42, 7), queries.AccessCheck);
    }

    [Fact]
    public void ScopeChecksAreExecutedOncePerRequestServiceInstance()
    {
        var queries = new Queries(true);
        var service = new UserContextService(new RequestContext("X-Empresa-Id", "9"),
            NullLogger<UserContextService>.Instance, queries);
        Assert.Equal(9, service.TryGetCurrentEmpresaId());
        Assert.Equal(9, service.GetCurrentEmpresaId());
        Assert.Equal(1, queries.AccessCheckCount);
    }

    private sealed class RequestContext(string header, string value) : IUserRequestContext
    {
        public ClaimsPrincipal User { get; } = new(new ClaimsIdentity([
            new Claim(ClaimTypes.NameIdentifier, "42"), new Claim("empresaId", "7")], "Test"));
        public string? GetHeader(string name) => name == header ? value : null;
    }

    private sealed class Queries(bool allowed, bool fail = false) : IUserContextQueries
    {
        public (int UserId, int EmpresaId)? AccessCheck { get; private set; }
        public int AccessCheckCount { get; private set; }
        public bool CanAccessEmpresa(int usuarioId, int empresaId)
        {
            AccessCheck = (usuarioId, empresaId);
            AccessCheckCount++;
            if (fail) throw new InvalidOperationException("Unavailable test store");
            return allowed;
        }
        public bool IsActiveAnio(int anioId) => allowed;
    }
}
