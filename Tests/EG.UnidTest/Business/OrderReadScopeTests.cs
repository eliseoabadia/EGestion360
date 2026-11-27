using EG.Business.Services;
using EG.Business.Services.Adquisicion;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infrastructure;
using EG.Infraestructure.Models;
using EG.UnidTest.Support;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.Business;

public sealed class OrderReadScopeTests
{
    [Theory]
    [InlineData(2025)]
    [InlineData(2026)]
    public void EveryReadUsesServerYearEvenWithoutClientFilter(int year)
    {
        using var context = new EGestionContext(new DbContextOptionsBuilder<EGestionContext>()
            .UseSqlServer("Server=localhost;Database=SqlTranslationOnly;Integrated Security=true;").Options);
        var service = new OrdenCompraReadService(new Repository<VwOrdenCompra>(context), new FixedUserContext(42, 7, year),
            context, NullLogger<GenericService<VwOrdenCompra, OrdenCompraDto, OrdenCompraResponse>>.Instance);

        var sql = service.GetQueryWithIncludes().ToQueryString();

        Assert.Contains("EXISTS", sql);
        Assert.Contains("Requisicion", sql);
        Assert.Contains(year.ToString(), sql);
        Assert.Contains("Anio", sql, StringComparison.OrdinalIgnoreCase);
    }
}
