using EG.Domain.DTOs.Responses.Nomina;
using EG.Web.Services;

namespace EG.UnidTest.Presentation;

public class ExportProjectionSanitizerTests
{
    [Fact]
    public void ExportRemovesDatabaseKeysAndPreservesFiscalAndBusinessReferences()
    {
        var row = new
        {
            PkidFactura = 42,
            FkidEmpresaSis = 7,
            IdCompromisoNomina = 12,
            UsuarioCreacion = 3,
            Uuid = "fiscal-document-reference",
            PayrollId = "ADMIN001",
            IdPeriodo = 24,
            Importe = 250m
        };

        var exported = Assert.Single(ExportProjectionSanitizer.RemoveInternalIdentifiers([row]));

        Assert.Equal(4, exported.Count);
        Assert.Equal(row.Uuid, exported[nameof(row.Uuid)]);
        Assert.Equal(row.PayrollId, exported[nameof(row.PayrollId)]);
        Assert.Equal(row.IdPeriodo, exported[nameof(row.IdPeriodo)]);
        Assert.Equal(row.Importe, exported[nameof(row.Importe)]);
    }

    [Fact]
    public void DictionaryExportAlsoRemovesInternalReferences()
    {
        var row = new Dictionary<string, object?>
        {
            ["Id"] = 42,
            ["SolicitudId"] = 7,
            ["UsuarioModificacion"] = 3,
            ["Descripcion"] = "Material de oficina",
            ["Importe"] = 250m
        };

        var exported = Assert.Single(ExportProjectionSanitizer.RemoveInternalIdentifiers([row]));

        Assert.Equal(2, exported.Count);
        Assert.Equal(row["Descripcion"], exported["Descripcion"]);
        Assert.Equal(row["Importe"], exported["Importe"]);
    }

    [Fact]
    public void LookupDescriptionsDoNotFallBackToPrimaryKeys()
    {
        var puesto = new NomPuestoResponse { PkidPuesto = 987654, Nombre = "Analista", NivelClave = "A1" };
        var plaza = new NomPlazaAutorizadaResponse { PkidPlazaAutorizada = 987654, PuestoNombre = "Analista" };
        var empresa = new NomEmpresaNominaResponse { PkidEmpresaNomina = 987654, RazonSocial = "Empresa de ejemplo" };

        Assert.Equal("Analista - Nivel A1", puesto.ClaveNombre);
        Assert.Equal("Plaza sin número - Analista", plaza.ClaveNombre);
        Assert.Equal("Empresa de ejemplo", empresa.ClaveNombre);
    }
}
