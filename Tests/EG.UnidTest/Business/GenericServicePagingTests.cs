using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.Interfaces;
using EG.UnidTest.Support;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.Business;

public sealed class GenericServicePagingTests
{
    [Fact]
    public async Task GetAllPaginadoAsync_Normalizes_InvalidPage_And_Clamps_PageSize()
    {
        var request = new PagedRequest
        {
            Page = 0,
            PageSize = 9999,
            SortLabel = nameof(CatalogEntity.Nombre),
            SortDirection = "asc"
        };
        var service = CreateService(
        [
            new CatalogEntity { Id = 1, Nombre = "Zeta", Activo = true, FkidEmpresaSis = 1 },
            new CatalogEntity { Id = 2, Nombre = "Alpha", Activo = true, FkidEmpresaSis = 2 },
            new CatalogEntity { Id = 3, Nombre = "Inactive", Activo = false, FkidEmpresaSis = 1 }
        ]);

        var result = await service.GetAllPaginadoAsync(request);

        Assert.True(result.Success);
        Assert.Equal(1, request.Page);
        Assert.Equal(250, request.PageSize);
        Assert.Equal(2, result.TotalCount);
        Assert.Collection(
            result.Items,
            item => Assert.Equal("Alpha", item.Nombre),
            item => Assert.Equal("Zeta", item.Nombre));
    }

    [Fact]
    public async Task GetAllPaginadoAsync_Applies_EmpresaFilter_And_ActivoFilter()
    {
        var request = new PagedRequest
        {
            Page = 1,
            PageSize = 10,
            SortLabel = nameof(CatalogEntity.Id),
            SortDirection = "asc"
        };
        var service = CreateService(
        [
            new CatalogEntity { Id = 1, Nombre = "Empresa 7 activo", Activo = true, FkidEmpresaSis = 7 },
            new CatalogEntity { Id = 2, Nombre = "Empresa 8 activo", Activo = true, FkidEmpresaSis = 8 },
            new CatalogEntity { Id = 3, Nombre = "Empresa 7 inactivo", Activo = false, FkidEmpresaSis = 7 }
        ],
        new FixedUserContext(userId: 99, empresaId: 7));

        var result = await service.GetAllPaginadoAsync(request);

        Assert.True(result.Success);
        Assert.Equal(1, result.TotalCount);
        var item = Assert.Single(result.Items);
        Assert.Equal(1, item.Id);
        Assert.Equal(7, item.FkidEmpresaSis);
    }

    [Fact]
    public void ApplyCurrentEmpresaIfPresent_Sets_Empresa_When_Target_Has_SupportedProperty()
    {
        var service = CreateService([], new FixedUserContext(userId: 99, empresaId: 33));
        var dto = new CatalogDto();

        service.ApplyCurrentEmpresaIfPresent(dto);

        Assert.Equal(33, dto.FkidEmpresaSis);
    }

    [Fact]
    public async Task GetAllPaginadoAsync_Applies_AdditionalFilters()
    {
        var request = new PagedRequest
        {
            Page = 1,
            PageSize = 10,
            AdditionalFilters = new Dictionary<string, object>
            {
                [nameof(CatalogEntity.FkidEmpresaSis)] = 5
            }
        };
        var service = CreateService(
        [
            new CatalogEntity { Id = 1, Nombre = "Empresa 5", Activo = true, FkidEmpresaSis = 5 },
            new CatalogEntity { Id = 2, Nombre = "Empresa 6", Activo = true, FkidEmpresaSis = 6 },
            new CatalogEntity { Id = 3, Nombre = "Empresa 5 inactive", Activo = false, FkidEmpresaSis = 5 }
        ]);

        var result = await service.GetAllPaginadoAsync(request);

        Assert.True(result.Success);
        var item = Assert.Single(result.Items);
        Assert.Equal("Empresa 5", item.Nombre);
    }

    [Fact]
    public async Task GetAllPaginadoAsync_Applies_TextFilter()
    {
        var request = new PagedRequest
        {
            Page = 1,
            PageSize = 10,
            Filtro = "Compra"
        };
        var service = CreateService(
        [
            new CatalogEntity { Id = 1, Nombre = "Orden de Compra", Activo = true, FkidEmpresaSis = 1 },
            new CatalogEntity { Id = 2, Nombre = "Contrato", Activo = true, FkidEmpresaSis = 1 }
        ]);

        var result = await service.GetAllPaginadoAsync(request);

        Assert.True(result.Success);
        var item = Assert.Single(result.Items);
        Assert.Equal(1, item.Id);
    }

    [Fact]
    public async Task GetAllPaginadoAsync_WithWhereCondition_Applies_CustomPredicate()
    {
        var request = new PagedRequest
        {
            Page = -10,
            PageSize = 0,
            SortLabel = nameof(CatalogEntity.Id),
            SortDirection = "desc"
        };
        var service = CreateService(
        [
            new CatalogEntity { Id = 1, Nombre = "Pendiente", Activo = true, FkidEmpresaSis = 1 },
            new CatalogEntity { Id = 2, Nombre = "Autorizado", Activo = true, FkidEmpresaSis = 1 },
            new CatalogEntity { Id = 3, Nombre = "Rechazado", Activo = true, FkidEmpresaSis = 1 }
        ]);

        var result = await service.GetAllPaginadoAsync(request, entity => entity.Id >= 2);

        Assert.True(result.Success);
        Assert.Equal(1, request.Page);
        Assert.Equal(10, request.PageSize);
        Assert.Equal(2, result.TotalCount);
        Assert.Collection(
            result.Items,
            item => Assert.Equal(3, item.Id),
            item => Assert.Equal(2, item.Id));
    }

    [Fact]
    public async Task ExportIncludesMoreThanOnePageAndPreservesCompanyScopeAndSearch()
    {
        var entities = Enumerable.Range(1, 320).Select(id => new CatalogEntity
        {
            Id = id, Nombre = "Menú " + id, Activo = true, FkidEmpresaSis = 7
        }).Concat([
            new() { Id = 900, Nombre = "Menú de otra empresa", Activo = true, FkidEmpresaSis = 8 },
            new() { Id = 901, Nombre = "Menú inactivo", Activo = false, FkidEmpresaSis = 7 },
            new() { Id = 902, Nombre = "Otro registro", Activo = true, FkidEmpresaSis = 7 }
        ]);
        var service = CreateService(entities, new FixedUserContext(7, 7));

        var result = await service.GetAllForExportAsync(new()
        {
            Page = 1, PageSize = 10, Filtro = "Menú", SortLabel = nameof(CatalogEntity.Id), SortDirection = "Ascending"
        });

        Assert.Equal(320, result.Count);
        Assert.All(result, item => Assert.Equal(7, item.FkidEmpresaSis));
        Assert.Equal(1, result[0].Id);
        Assert.Equal(320, result[^1].Id);
    }

    private static GenericService<CatalogEntity, CatalogDto, CatalogResponse> CreateService(
        IEnumerable<CatalogEntity> entities,
        IUserContextService? userContext = null)
    {
        var service = new GenericService<CatalogEntity, CatalogDto, CatalogResponse>(
            new InMemoryRepository<CatalogEntity>(entities),
            userContext,
            NullLogger<GenericService<CatalogEntity, CatalogDto, CatalogResponse>>.Instance);
        if (userContext == null)
            service.DisableEmpresaFilter();
        return service;
    }

    public sealed class CatalogEntity
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int FkidEmpresaSis { get; set; }
    }

    public sealed class CatalogDto
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public int FkidEmpresaSis { get; set; }
    }

    public sealed class CatalogResponse
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public int FkidEmpresaSis { get; set; }
    }
}
