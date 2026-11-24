using EG.ApiCoreBS.Controllers.Contabilidad;
using EG.ApiCoreBS.Controllers.Patrimonio;
using Microsoft.AspNetCore.Authorization;

namespace EG.UnidTest.ApiCoreBS;

public sealed class AccountingPermissionTests
{
    [Theory]
    [InlineData(nameof(PolizaController.GetAll), "view")]
    [InlineData(nameof(PolizaController.GetById), "view")]
    [InlineData(nameof(PolizaController.GetAllPaginado), "view")]
    [InlineData(nameof(PolizaController.Buscar), "view")]
    [InlineData(nameof(PolizaController.Create), "new")]
    [InlineData(nameof(PolizaController.Update), "update")]
    [InlineData(nameof(PolizaController.Delete), "delete")]
    [InlineData(nameof(PolizaController.PreviewAiImport), "new")]
    [InlineData(nameof(PolizaController.ConfirmAiImport), "new")]
    public void PolizaEndpointsDeclareTheirActualAction(string method, string action)
    {
        var policy = typeof(PolizaController).GetMethod(method)!
            .GetCustomAttributes(typeof(AuthorizeAttribute), true).Cast<AuthorizeAttribute>();
        Assert.Contains(policy, attribute => attribute.Policy == $"Contabilidad|Polizas|{action}");
    }

    [Fact]
    public void ResguardoHistoryRequiresItsOwnReadPermission()
    {
        var attributes = typeof(ResguardoMovimientoController)
            .GetCustomAttributes(typeof(AuthorizeAttribute), true).Cast<AuthorizeAttribute>();
        Assert.Contains(attributes, attribute => attribute.Policy == "Patrimonio|Resguardo_Historico|view");
    }
}
