using EG.Common.GenericModel;
using EG.Domain.Interfaces;
using EG.Infrastructure;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.UnidTest.ApiCoreBS;

public sealed class CatalogQueryTranslationTests
{
    public static IEnumerable<object[]> Catalogs => Enum.GetValues<CatalogLookupKind>().Select(kind => new object[] { kind });

    [Theory]
    [MemberData(nameof(Catalogs))]
    public void SearchAndPagingTranslateToSqlWithoutOpeningAConnection(CatalogLookupKind kind)
    {
        using var context = new EGestionContext(new DbContextOptionsBuilder<EGestionContext>()
            .UseSqlServer("Server=localhost;Database=SqlTranslationOnly;Integrated Security=true;").Options);
        var query = new CatalogLookupQueries(context).Query(kind, 1, 1)
            .Select(x => new LookupItem { Id = x.Id, Text = x.Text })
            .Where(x => x.Text.Contains("test")).Skip(10).Take(25);

        var sql = query.ToQueryString();

        Assert.Contains("SELECT", sql);
        Assert.Contains("OFFSET", sql);
    }

    [Theory]
    [InlineData(CatalogLookupKind.Programa)]
    [InlineData(CatalogLookupKind.Partida)]
    [InlineData(CatalogLookupKind.CuentaAprobado)]
    [InlineData(CatalogLookupKind.CuentaPorEjercer)]
    [InlineData(CatalogLookupKind.CuentaModificado)]
    [InlineData(CatalogLookupKind.CuentaComprometido)]
    [InlineData(CatalogLookupKind.CuentaDevengado)]
    [InlineData(CatalogLookupKind.CuentaEjercido)]
    [InlineData(CatalogLookupKind.CuentaPagado)]
    [InlineData(CatalogLookupKind.CuentaGasto)]
    public void LegacyLookupProjectionAlsoTranslatesWithoutOpeningAConnection(CatalogLookupKind kind)
    {
        using var context = new EGestionContext(new DbContextOptionsBuilder<EGestionContext>()
            .UseSqlServer("Server=localhost;Database=SqlTranslationOnly;Integrated Security=true;").Options);
        var query = new CatalogLookupQueries(context).QueryLegacy(kind, 1);

        Assert.Contains("SELECT DISTINCT", query.ToQueryString());
    }
}
