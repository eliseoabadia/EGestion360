using System.Security.Claims;
using EG.Application.Services.Security;
using EG.Domain.Interfaces;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.ApiCoreBS;

public sealed class UserContextBoundaryTests
{
    [Theory]
    [InlineData(true, 9)]
    [InlineData(false, 7)]
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
        Assert.Equal(7, service.TryGetCurrentEmpresaId());
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
        public bool CanAccessEmpresa(int usuarioId, int empresaId)
        {
            AccessCheck = (usuarioId, empresaId);
            if (fail) throw new InvalidOperationException("Unavailable test store");
            return allowed;
        }
        public bool IsActiveAnio(int anioId) => allowed;
    }
}
