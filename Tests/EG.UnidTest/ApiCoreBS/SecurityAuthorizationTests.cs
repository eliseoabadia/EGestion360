using EG.ApiCoreBS.Controllers.Account;
using EG.ApiCoreBS.Controllers.General;
using EG.ApiCoreBS.Controllers.PBR;
using EG.ApiCoreBS.Controllers.Reporting;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.RateLimiting;

namespace EG.UnidTest.ApiCoreBS;

public sealed class SecurityAuthorizationTests
{
    [Fact]
    public void Login_Is_Explicitly_Anonymous_And_RateLimited()
    {
        var method = typeof(AuthController).GetMethod(nameof(AuthController.Login))!;

        Assert.NotNull(method.GetCustomAttributes(typeof(AllowAnonymousAttribute), true).SingleOrDefault());
        var rateLimit = method.GetCustomAttributes(typeof(EnableRateLimitingAttribute), true)
            .Cast<EnableRateLimitingAttribute>()
            .Single();
        Assert.Equal("login", rateLimit.PolicyName);
    }

    [Theory]
    [InlineData(nameof(AccessConfigurationController.SaveRole), "Sistema|Configurar_Accesos|update")]
    [InlineData(nameof(AccessConfigurationController.SaveUserRoles), "Sistema|Configurar_Accesos|update")]
    [InlineData(nameof(AccessConfigurationController.SynchronizeMenuRoles), "Sistema|Configurar_Accesos|update")]
    public void AccessConfiguration_Mutations_Require_Update_Claim(string methodName, string policy)
    {
        AssertMethodPolicy(typeof(AccessConfigurationController), methodName, policy);
    }

    [Theory]
    [InlineData(nameof(PbrCrudController<object>.Create), "PBR|PBR|new")]
    [InlineData(nameof(PbrCrudController<object>.Update), "PBR|PBR|update")]
    [InlineData(nameof(PbrCrudController<object>.Delete), "PBR|PBR|delete")]
    public void Pbr_Mutations_Require_Action_Claim(string methodName, string policy)
    {
        AssertMethodPolicy(typeof(PbrCrudController<object>), methodName, policy);
    }

    [Fact]
    public void Report_Designer_And_QueryBuilder_Require_Administrative_Claim()
    {
        AssertTypePolicy(typeof(CustomReportDesignerController), "Sistema|Configurar_Accesos|update");
        AssertTypePolicy(typeof(CustomQueryBuilderController), "Sistema|Configurar_Accesos|update");
    }

    private static void AssertMethodPolicy(Type type, string methodName, string policy)
    {
        var method = type.GetMethods().Single(x => x.Name == methodName);
        var policies = method.GetCustomAttributes(typeof(AuthorizeAttribute), true)
            .Cast<AuthorizeAttribute>()
            .Select(x => x.Policy);

        Assert.Contains(policy, policies);
    }

    private static void AssertTypePolicy(Type type, string policy)
    {
        var policies = type.GetCustomAttributes(typeof(AuthorizeAttribute), true)
            .Cast<AuthorizeAttribute>()
            .Select(x => x.Policy);

        Assert.Contains(policy, policies);
    }
}
