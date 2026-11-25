using EG.Application.Services.General;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Rules;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.UnidTest.Domain;

public sealed class MenuRulesTests
{
    private static MenuItemsDto ValidMenu(int? parent = null) => new()
    {
        Nombre = "Nuevo", Tipo = 2, Ruta = "/nuevo", Activo = true, FkidMenuSis = parent
    };

    [Fact]
    public void MenuCannotBecomeItsOwnParent() => Assert.Throws<InvalidOperationException>(() =>
        MenuRules.Validate(ValidMenu(1), [new() { PkidMenu = 1, Nombre = "Padre", Activo = true }], 1));

    [Fact]
    public void MenuCannotMoveUnderOneOfItsDescendants() => Assert.Throws<InvalidOperationException>(() =>
        MenuRules.Validate(ValidMenu(3),
        [
            new() { PkidMenu = 1, Nombre = "Raíz", Activo = true },
            new() { PkidMenu = 2, Nombre = "Hijo", FkidMenuSis = 1, Activo = true },
            new() { PkidMenu = 3, Nombre = "Nieto", FkidMenuSis = 2, Activo = true }
        ], 1));

    [Fact]
    public void MissingOrInactiveParentIsRejected() => Assert.Throws<InvalidOperationException>(() =>
        MenuRules.Validate(ValidMenu(99), [], null));

    [Fact]
    public void DuplicateNameIgnoresCaseAndSurroundingWhitespace() => Assert.Throws<InvalidOperationException>(() =>
        MenuRules.Validate(ValidMenu(), [new() { PkidMenu = 1, Nombre = " NUEVO ", Activo = true }], null));

    [Fact]
    public void NameCanBeReusedUnderDifferentParents() => MenuRules.Validate(ValidMenu(1),
    [
        new() { PkidMenu = 1, Nombre = "Padre", Activo = true },
        new() { PkidMenu = 2, Nombre = "Nuevo", Activo = true }
    ], null);

    [Theory]
    [InlineData(false, 1)]
    [InlineData(true, 2)]
    public void ParentWithActiveChildrenMustRemainAnActiveContainer(bool active, int type)
    {
        var dto = ValidMenu();
        dto.Activo = active;
        dto.Tipo = type;
        Assert.Throws<InvalidOperationException>(() => MenuRules.Validate(dto,
            [new() { PkidMenu = 2, Nombre = "Hijo", FkidMenuSis = 1, Activo = true }], 1));
    }

    [Theory]
    [InlineData(null)]
    [InlineData(-1)]
    public void ReorderRequiresANonnegativePosition(int? order) => Assert.Throws<InvalidOperationException>(() =>
        MenuRules.ValidateOrder([new() { PkidMenu = 1, Orden = order }], [1]));

    [Fact]
    public void ReorderRejectsDuplicateMenuIds() => Assert.Throws<InvalidOperationException>(() =>
        MenuRules.ValidateOrder([new() { PkidMenu = 1, Orden = 1 }, new() { PkidMenu = 1, Orden = 2 }], [1]));

    [Fact]
    public void ReorderRejectsTheEntireBatchIfOneMenuIsMissing() => Assert.Throws<KeyNotFoundException>(() =>
        MenuRules.ValidateOrder([new() { PkidMenu = 1, Orden = 1 }, new() { PkidMenu = 99, Orden = 2 }], [1]));

    [Fact]
    public void ExistingCycleIsRejectedBeforeSerializingTheTree() => Assert.Throws<InvalidOperationException>(() =>
        MenuTreeBuilder.Build([
            new() { PkidMenu = 1, FkidMenuSis = 2 }, new() { PkidMenu = 2, FkidMenuSis = 1 }
        ]));

    [Fact]
    public void TreeRetainsChildrenAndOrdersSiblings()
    {
        var roots = MenuTreeBuilder.Build([
            new() { PkidMenu = 1, Nombre = "Padre" },
            new() { PkidMenu = 3, Nombre = "Segundo", FkidMenuSis = 1, Orden = 2 },
            new() { PkidMenu = 2, Nombre = "Primero", FkidMenuSis = 1, Orden = 1 }
        ]);
        Assert.Single(roots);
        Assert.Equal(new[] { 2, 3 }, roots[0].Children.Select(menu => menu.PkidMenu));
    }

    [Fact]
    public void EnglishCreationAuditCannotBeReplacedByClientValues()
    {
        var created = new DateTime(2020, 1, 1);
        var existing = new Menu { PkidMenu = 7, Nombre = "Anterior", CreatedByOperatorId = 4, CreatedDateTime = created };
        EntityUpdateMapper.Apply(new MenuItemsDto
        {
            PkidMenu = 99, Nombre = "Actualizado", CreatedByOperatorId = 999, CreatedDateTime = DateTime.Now
        }, existing);
        Assert.Equal(7, existing.PkidMenu);
        Assert.Equal(4, existing.CreatedByOperatorId);
        Assert.Equal(created, existing.CreatedDateTime);
        Assert.Equal("Actualizado", existing.Nombre);
    }
}
