using EG.ApiCoreBS.Controllers.Catalogos.Adquisicion;
using EG.ApiCoreBS.Controllers.Almacen;
using EG.Common.Modules;
using Microsoft.AspNetCore.Authorization;

namespace EG.UnidTest.ApiCoreBS;

public sealed class PurchasingReadPermissionTests
{
    public static IEnumerable<object[]> ReadActions => new[]
    {
        (typeof(OrdenCompraController), PurchasingPermissions.OrderRead),
        (typeof(CotizacionController), PurchasingPermissions.QuoteRead),
        (typeof(AlmacenController), PurchasingPermissions.ReceiptRead)
    }.SelectMany(pair => new[] { "GetAll", "GetById", "GetAllPaginado", "Buscar" }
        .Select(action => new object[] { pair.Item1, action, pair.Item2 }));

    [Theory]
    [MemberData(nameof(ReadActions))]
    public void ReadsRequireTheirModulePermission(Type controller, string action, string policy)
    {
        var attributes = controller.GetMethod(action)!.GetCustomAttributes(typeof(AuthorizeAttribute), true)
            .Cast<AuthorizeAttribute>();
        Assert.Contains(attributes, attribute => attribute.Policy == policy);
    }

    [Fact]
    public void QuoteReceiptRequiresQuoteReadPermission()
    {
        var attributes = typeof(CotizacionController).GetMethod(nameof(CotizacionController.GetRecepcionCotizacion))!
            .GetCustomAttributes(typeof(AuthorizeAttribute), true).Cast<AuthorizeAttribute>();
        Assert.Contains(attributes, attribute => attribute.Policy == PurchasingPermissions.QuoteRead);
    }
}
