using System.Security.Claims;
using System.Reflection;
using System.IdentityModel.Tokens.Jwt;
using EG.Common.Security;
using EG.Common.GenericModel;
using EG.Application.Services;
using EG.ApiCoreBS.Filters;
using EG.ApiCoreBS.Services.Licensing;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Controllers;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Routing;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.ApiCoreBS;

public sealed class SuperAdminAccessTests
{
    [Theory]
    [InlineData(true, "SuperAdmin", true)]
    [InlineData(true, "Operador", false)]
    [InlineData(false, "SuperAdmin", false)]
    public async Task OnlyAuthenticatedSuperAdminCanOpenModuleWithoutLicense(bool authenticated, string role, bool allowed)
    {
        var http = new DefaultHttpContext
        {
            User = new ClaimsPrincipal(new ClaimsIdentity([new(ClaimTypes.Role, role)], authenticated ? "test" : null))
        };
        var descriptor = new ControllerActionDescriptor
        {
            ControllerTypeInfo = typeof(EG.ApiCoreBS.Controllers.PBR.PbrCrudController<object>).GetTypeInfo(),
            ControllerName = "PbrCrud", ActionName = "Get"
        };
        var action = new ActionContext(http, new RouteData(), descriptor);
        var filters = new List<IFilterMetadata>();
        var context = new ActionExecutingContext(action, filters, new Dictionary<string, object?>(), new object());
        var invoked = false;
        var filter = new ModuleLicenseFilter(new LicenseRuntimeState(), NullLogger<ModuleLicenseFilter>.Instance);

        await filter.OnActionExecutionAsync(context, () =>
        {
            invoked = true;
            return Task.FromResult(new ActionExecutedContext(action, filters, new object()));
        });

        Assert.Equal(allowed, invoked);
        if (!allowed) Assert.Equal(403, Assert.IsType<ObjectResult>(context.Result).StatusCode);
    }

    [Fact]
    public void LoginTokenCarriesOnlyRolesProvidedByServer()
    {
        var service = new TokenService(new ConfigurationBuilder().Build());
        var settings = new JwtSettings
        {
            IssuerSigningKey = new string('x', 64), ValidIssuer = "test", ValidAudience = "test", ExpiryMinutes = 5
        };
        var token = service.GenTokenkey(42, "employee", "Test", "", 1, settings, [SystemRoles.SuperAdmin]);
        var claims = new JwtSecurityTokenHandler().ReadJwtToken(token.AccessToken).Claims;
        Assert.Contains(claims, claim => (claim.Type == "role" || claim.Type == ClaimTypes.Role) && claim.Value == SystemRoles.SuperAdmin);
        var ordinary = service.GenTokenkey(42, "employee", "Test", "", 1, settings);
        Assert.DoesNotContain(new JwtSecurityTokenHandler().ReadJwtToken(ordinary.AccessToken).Claims,
            claim => claim.Value == SystemRoles.SuperAdmin);
    }
}
