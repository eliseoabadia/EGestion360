using System.Security.Claims;
using EG.ApiCoreBS.Controllers.Modules.Nomina.RH;
using EG.Application.Interfaces.Nomina;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace EG.UnidTest.ApiCoreBS;

public sealed class NominaIncidenciaAccessTests
{
    [Fact]
    public async Task MissingReadPermissionNeverLoadsCompanyIncidences()
    {
        var service = new Incidencias();
        var controller = Controller(service, new Permissions(null));

        var result = await controller.GetAllPaginado(new PagedRequest());

        Assert.IsType<ForbidResult>(result.Result);
        Assert.Equal(0, service.Calls);
    }

    [Theory]
    [InlineData("Incidencias|Captura_Incidencias|view")]
    [InlineData("Incidencias|Justificacion_Incidencias|view")]
    [InlineData("Incidencias|Reporte_Incidencias|view")]
    public async Task AnyExistingIncidenceScreenPermissionAllowsTheSharedList(string allowed)
    {
        var service = new Incidencias();
        var controller = Controller(service, new Permissions(allowed));

        var result = await controller.GetAllPaginado(new PagedRequest());

        Assert.IsType<OkObjectResult>(result.Result);
        Assert.Equal(1, service.Calls);
    }

    private static NominaRhIncidenciaListadoController Controller(Incidencias service, Permissions permissions) => new(service, permissions)
    {
        ControllerContext = new ControllerContext { HttpContext = new DefaultHttpContext() }
    };

    private sealed class Incidencias : INominaRhIncidenciaListadoAppService
    {
        public int Calls { get; private set; }
        public Task<PagedResult<VwRhIncidenciaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            Calls++;
            return Task.FromResult(new PagedResult<VwRhIncidenciaResponse> { Success = true });
        }
    }

    private sealed class Permissions(string? allowed) : IAuthorizationService
    {
        public Task<AuthorizationResult> AuthorizeAsync(ClaimsPrincipal user, object? resource, string policyName)
            => Task.FromResult(policyName == allowed ? AuthorizationResult.Success() : AuthorizationResult.Failed());

        public Task<AuthorizationResult> AuthorizeAsync(ClaimsPrincipal user, object? resource, IEnumerable<IAuthorizationRequirement> requirements)
            => Task.FromResult(AuthorizationResult.Failed());
    }
}
