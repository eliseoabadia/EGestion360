using EG.ApiCoreBS.Services.Licensing;
using EG.ApiCoreBS.Filters;
using EG.Contracts.Platform.Licensing;
using EG.Domain.Platform.Licensing;

namespace EG.UnidTest.ApiCoreBS;

public sealed class LicensingTests
{
    private static readonly DateTimeOffset Now = new(2026, 9, 12, 12, 0, 0, TimeSpan.Zero);
    private const string SignedFixture = "eyJhbGciOiJQUzI1NiIsInR5cCI6IkdFMzYwLUxJQyIsImtpZCI6IjIwMjYtMDEifQ.ew0KICAicHJvZHVjdCI6ICJHRTM2MCIsDQogICJmb3JtYXRWZXJzaW9uIjogMSwNCiAgImxpY2Vuc2VJZCI6ICJlMTc2YTE5YS0wMjQzLTQ1ZDItOWJjMi0zYmVlMjM4MzhmODIiLA0KICAiaW5zdGFsbGF0aW9uSWQiOiAiMTExMTExMTEtMTExMS0xMTExLTExMTEtMTExMTExMTExMTExIiwNCiAgImluc3RhbGxhdGlvbkZpbmdlcnByaW50IjogIjAxMjM0NTY3ODlhYmNkZWYwMTIzNDU2Nzg5YWJjZGVmMDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWYiLA0KICAic2VyaWFsIjogMSwNCiAgImlzc3VlZEF0VXRjIjogIjIwMjYtMDktMTJUMjA6MTk6NTkuMTA0MTc0NiswMDowMCIsDQogICJtb2R1bGVzIjogWw0KICAgIHsNCiAgICAgICJjb2RlIjogIkdSUC5BTE1BIiwNCiAgICAgICJzdGFydHNBdFV0YyI6ICIyMDI2LTA5LTEyVDE4OjAwOjAwKzAwOjAwIiwNCiAgICAgICJlbmRzQXRVdGMiOiAiMjAyNi0xMC0xMlQxODowMDowMCswMDowMCINCiAgICB9LA0KICAgIHsNCiAgICAgICJjb2RlIjogIkdSUC5DT05UQSIsDQogICAgICAic3RhcnRzQXRVdGMiOiAiMjAyNi0wOS0xMlQxODowMDowMCswMDowMCIsDQogICAgICAiZW5kc0F0VXRjIjogbnVsbA0KICAgIH0NCiAgXQ0KfQ.W3KiXXki7LFkizWowFdHjxZ9fW1qsa4m7zGNn2bz33DQlBYOCLkmCzEOPB6CTKhVCo5tNe8zCQwATG9Cg0Qaeor1mDe6Vc2vSjbOMuOR3-d3pOWEeYHqu-MjFKUwBdsJSk-9BvbArhqcuZZ_G5GwYMHLr9s863WLxq9C7uPGPSHEaTOgs3ZLKax-_uziPaRIYnXihbTHKNhbS0JqPeSrWyB8jzIoiUdxFVkY9eoDQ-2FoLQ8HKNoYFYUH30E2cg-ERITPVZo2x080ZqhtTSENbK1KiJWuIHl_khxSGl7lEfzeFYBs3vksq6ezpW7GQKpiD8YtFaL7IpukKk-bUuNJXqnhBYcyHpw8Bp_0Ip5AcWnytKvYS1kdMHGT1xf3WtnTpOEvDpajZ_0qhGibUvhKizJ_0bPuaN4xrpwEa9fxJaXVy8xiH3gJafMuVb5FpTch805rw9Qy38pY1p7VG8caaCPc-sCe17kjPTjIU3bGraPZcWNIB1LGvsskeRdk3Kq";

    [Fact]
    public void Verifier_Accepts_An_Authentic_License_And_Rejects_A_Tampered_One()
    {
        var authentic = LicenseTokenVerifier.Verify(SignedFixture);
        var segments = SignedFixture.Split('.');
        var tamperedPayload = segments[1][..^1] + (segments[1][^1] == 'A' ? 'B' : 'A');
        var tampered = LicenseTokenVerifier.Verify($"{segments[0]}.{tamperedPayload}.{segments[2]}");

        Assert.True(authentic.Valid);
        Assert.Equal("2026-01", authentic.KeyId);
        Assert.False(tampered.Valid);
        Assert.Equal("LIC_SIGNATURE_INVALID", tampered.Code);
    }

    [Fact]
    public void Runtime_Allows_Only_Signed_Contracted_Current_And_Locally_Active_Module()
    {
        var runtime = CreateRuntime(new LicenseRuntimeGrant(
            LicenseModuleCodes.GrpAlmacen,
            Now.AddDays(-1),
            Now.AddDays(10),
            true));

        Assert.Equal("LIC_ALLOWED", runtime.Evaluate(LicenseModuleCodes.GrpAlmacen, Now).Code);
        Assert.Equal("LIC_MODULE_NOT_CONTRACTED", runtime.Evaluate(LicenseModuleCodes.Nomina, Now).Code);
    }

    [Fact]
    public void Runtime_Rejects_Local_Activation_When_Grant_Is_Expired()
    {
        var runtime = CreateRuntime(new LicenseRuntimeGrant(
            LicenseModuleCodes.GrpAlmacen,
            Now.AddDays(-10),
            Now,
            true));

        var decision = runtime.Evaluate(LicenseModuleCodes.GrpAlmacen, Now);

        Assert.False(decision.Allowed);
        Assert.Equal("LIC_MODULE_EXPIRED", decision.Code);
    }

    [Fact]
    public void Runtime_Latches_A_Clock_Rollback_And_Blocks_Commercial_Modules()
    {
        var runtime = CreateRuntime(new LicenseRuntimeGrant(
            LicenseModuleCodes.GrpAlmacen,
            Now.AddDays(-1),
            Now.AddDays(10),
            true));

        var decision = runtime.Evaluate(LicenseModuleCodes.GrpAlmacen, Now.AddMinutes(-6));
        var afterCorrection = runtime.Evaluate(LicenseModuleCodes.GrpAlmacen, Now.AddMinutes(1));

        Assert.Equal("LIC_CLOCK_SUSPICIOUS", decision.Code);
        Assert.Equal("LIC_CLOCK_SUSPICIOUS", afterCorrection.Code);
    }

    [Theory]
    [InlineData("EG.ApiCoreBS.Controllers.Almacen", LicenseModuleCodes.GrpAlmacen)]
    [InlineData("EG.ApiCoreBS.Controllers.ConteoCiclico", LicenseModuleCodes.GrpAlmacen)]
    [InlineData("EG.ApiCoreBS.Controllers.Catalogos.Adquisicion", LicenseModuleCodes.GrpAdquisiciones)]
    [InlineData("EG.ApiCoreBS.Controllers.Planeacion", LicenseModuleCodes.GrpAdquisiciones)]
    [InlineData("EG.ApiCoreBS.Controllers.Contratos", LicenseModuleCodes.GrpAdquisiciones)]
    [InlineData("EG.ApiCoreBS.Controllers.Contabilidad", LicenseModuleCodes.GrpContabilidad)]
    [InlineData("EG.ApiCore.Controllers.Contabilidad", LicenseModuleCodes.GrpContabilidad)]
    [InlineData("EG.ApiCoreBS.Controllers.Patrimonio", LicenseModuleCodes.GrpPatrimonio)]
    [InlineData("EG.ApiCoreBS.Controllers.Catalogos.Presupuestales", LicenseModuleCodes.GrpPresupuesto)]
    [InlineData("EG.ApiCoreBS.Controllers.Catalogos.Tesoreria", LicenseModuleCodes.GrpPresupuesto)]
    [InlineData("EG.ApiCoreBS.Controllers.PresupuestoModificado", LicenseModuleCodes.GrpPresupuesto)]
    [InlineData("EG.ApiCoreBS.Controllers.Modules.Nomina.RH", LicenseModuleCodes.Nomina)]
    [InlineData("EG.ApiCoreBS.Controllers.PBR", LicenseModuleCodes.Pbr)]
    public void Resolver_Maps_Legacy_And_Current_Controller_Namespaces(string controllerNamespace, string expected)
    {
        Assert.Equal(expected, LicenseModuleResolver.ResolveControllerModule(controllerNamespace));
        Assert.True(LicenseModuleResolver.IsCommercialControllerNamespace(controllerNamespace));
    }

    [Fact]
    public void Resolver_Keeps_Platform_Endpoints_Outside_Commercial_Licensing()
    {
        const string platformNamespace = "EG.ApiCoreBS.Controllers.Platform.Licensing";

        Assert.Null(LicenseModuleResolver.ResolveControllerModule(platformNamespace));
        Assert.False(LicenseModuleResolver.IsCommercialControllerNamespace(platformNamespace));
    }

    [Fact]
    public void Every_Api_Controller_Is_Explicitly_Core_Or_Assigned_To_A_Commercial_Module()
    {
        var unmapped = typeof(ModuleLicenseFilter).Assembly
            .GetTypes()
            .Where(type => type.IsClass && !type.IsAbstract &&
                           type.Name.EndsWith("Controller", StringComparison.Ordinal))
            .Where(type => LicenseModuleResolver.ResolveControllerModule(type.Namespace) is null &&
                           !LicenseModuleResolver.IsCoreControllerNamespace(type.Namespace))
            .Select(type => type.FullName)
            .OrderBy(name => name)
            .ToArray();

        Assert.Empty(unmapped);
    }

    [Theory]
    [InlineData("SolicitudSuficiencia", "Create", LicenseModuleCodes.GrpPresupuesto)]
    [InlineData("AutorizacionSuficiencia", "Authorize", LicenseModuleCodes.GrpAdquisiciones)]
    [InlineData("Almacen", "Create", LicenseModuleCodes.GrpAdquisiciones)]
    [InlineData("Bien", "GenerarDesdeDetalle", LicenseModuleCodes.GrpAdquisiciones)]
    [InlineData("NominaProcesos", "CrearComprometido", LicenseModuleCodes.GrpPresupuesto)]
    public void Resolver_Requires_The_Other_Module_For_Known_Integrations(
        string controller,
        string action,
        string expected)
    {
        Assert.Contains(expected, LicenseModuleResolver.ResolveAdditionalControllerModules(controller, action));
    }

    private static LicenseRuntimeState CreateRuntime(params LicenseRuntimeGrant[] grants)
    {
        var runtime = new LicenseRuntimeState();
        runtime.Replace(new LicenseRuntimeSnapshot(
            Guid.NewGuid(),
            "fingerprint",
            Guid.NewGuid(),
            1,
            true,
            Now,
            false,
            grants));
        return runtime;
    }
}
