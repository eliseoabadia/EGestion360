using EG.Web.Pages.Modules.Nomina.Configuration.Catalogos;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.UnidTest.Presentation;

public class NominaCatalogUiTests
{
    [Fact]
    public void IdentityUsesCurrentRowAndIgnoresLegacyKey()
    {
        Assert.Equal(12, NominaCatalogUi.GetItemId(new Row { PkidConcepto = 12 }));
        Assert.Equal(37, NominaCatalogUi.GetItemId(new Row { PkidConcepto = 37 }));
        Assert.Equal(0, NominaCatalogUi.GetItemId<Row>(null!));
        Assert.Equal(0, NominaCatalogUi.GetItemId(new { Nombre = "Sin identificador" }));
    }

    [Fact]
    public void LabelsUseCachedKnownNamesAndKeepHumanizedFallback()
    {
        Assert.Equal("ID", NominaCatalogUi.GetLabel(typeof(Row).GetProperty(nameof(Row.PkidConcepto))!));
        Assert.Equal("Fecha inicial", NominaCatalogUi.GetLabel(typeof(Row).GetProperty(nameof(Row.FechaIni))!));
        Assert.Equal("Nombre", NominaCatalogUi.GetLabel(typeof(Row).GetProperty(nameof(Row.Nombre))!));
    }

    [Fact]
    public void LabelsRespectCatalogContextAndSharedLookups()
    {
        Assert.Equal("Empresa", NominaCatalogUi.GetLabel("FkidEmpresaSis"));
        Assert.Equal("Tipo de nómina", NominaCatalogUi.GetLabel("FkidEmpresaSis", typeof(NomConceptoTabularResponse)));
        Assert.Equal("Periodo de pago", NominaCatalogUi.GetLabel("FkidPeriodoPagoSis"));
    }

    private sealed class Row
    {
        public int PkidNomLegacy { get; set; } = 99;
        public int PkidConcepto { get; set; }
        public DateTime FechaIni { get; set; }
        public string Nombre { get; set; } = string.Empty;
    }
}
