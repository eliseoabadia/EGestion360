using System.Globalization;
using System.Reflection;

namespace EG.Web.Pages.Modules.Nomina.Configuration.Catalogos;

public static class NominaCatalogUi
{
    private static readonly HashSet<string> HiddenColumns = new(StringComparer.OrdinalIgnoreCase)
    {
        "ClaveNombre",
        "Catalogo",
        "LegacyTable",
        "LegacyId",
        "FechaCreacion",
        "UsuarioCreacion",
        "FechaModificacion",
        "UsuarioModificacion"
    };

    private static readonly HashSet<string> DisplayOnlyDialogColumns = new(StringComparer.OrdinalIgnoreCase)
    {
        "EmpresaNominaNombre",
        "ConceptoClaveNombre",
        "PuestoNombre",
        "PuestoClaveNombre",
        "PuestoPadreNombre",
        "NivelClave",
        "UniversoDescripcion",
        "ClasePuestoDescripcion",
        "PersonaClaveNombre",
        "NombramientoDescripcion"
    };

    public static IEnumerable<PropertyInfo> VisibleColumns(Type type, params string[] preferredColumns)
    {
        if (preferredColumns.Length > 0)
        {
            return preferredColumns
                .Select(name => type.GetProperty(name, BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase))
                .Where(property => property != null && property.CanRead && !IsHiddenColumn(property))
                .Cast<PropertyInfo>();
        }

        return type.GetProperties(BindingFlags.Instance | BindingFlags.Public)
            .Where(property => property.CanRead && !IsHiddenColumn(property))
            .Take(8);
    }

    public static bool IsHiddenColumn(PropertyInfo property)
        => HiddenColumns.Contains(property.Name) || property.Name.StartsWith("PkidNom", StringComparison.OrdinalIgnoreCase);

    public static bool IsDisplayOnlyDialogColumn(string propertyName)
        => DisplayOnlyDialogColumns.Contains(propertyName);

    public static int GetItemId<TItem>(TItem item)
    {
        if (item == null)
        {
            return 0;
        }

        var property = typeof(TItem).GetProperties()
            .FirstOrDefault(p => p.Name.StartsWith("Pkid", StringComparison.OrdinalIgnoreCase)
                                 && !p.Name.StartsWith("PkidNom", StringComparison.OrdinalIgnoreCase)
                                 && p.PropertyType == typeof(int));
        return property?.GetValue(item) as int? ?? 0;
    }

    public static string FormatValue(object? value)
    {
        return value switch
        {
            null => string.Empty,
            DateTime date => date.ToString("dd/MM/yyyy", CultureInfo.InvariantCulture),
            DateOnly date => date.ToString("dd/MM/yyyy", CultureInfo.InvariantCulture),
            decimal number => number.ToString("0.00", CultureInfo.InvariantCulture),
            bool flag => flag ? "Si" : "No",
            _ => value.ToString() ?? string.Empty
        };
    }

    public static string GetLabel(PropertyInfo property)
    {
        return property.Name switch
        {
            "PkidConcepto" => "ID",
            "PkidConceptoTabulador" => "ID",
            "PkidEmpresaNomina" => "ID",
            "PkidUniverso" => "ID",
            "PkidNivel" => "ID",
            "PkidClasePuesto" => "ID",
            "PkidPuesto" => "ID",
            "PkidNombramiento" => "ID",
            "PkidImporteNivel" => "ID",
            "PkidContratoLaboral" => "ID",
            "PkidCatalogoSimple" => "ID",
            "FkidEmpresaSis" => "Empresa nomina",
            "FkidEmpresaNominaNom" => "Empresa nomina",
            "EmpresaNominaNombre" => "Empresa nomina",
            "FkidPersonaNom" => "Persona",
            "PersonaClaveNombre" => "Persona",
            "FkidConceptoNom" => "Concepto",
            "ConceptoClaveNombre" => "Concepto",
            "FkidPuestoNom" => "Puesto",
            "FkidPuestoPadreNom" => "Puesto padre",
            "PuestoNombre" => "Puesto",
            "PuestoClaveNombre" => "Puesto",
            "PuestoPadreNombre" => "Puesto padre",
            "FkidNivelNom" => "Nivel",
            "NivelClave" => "Nivel",
            "FkidUniversoNom" => "Universo",
            "UniversoDescripcion" => "Universo",
            "FkidClasePuestoNom" => "Clase de puesto",
            "ClasePuestoDescripcion" => "Clase de puesto",
            "FkidNombramientoNom" => "Nombramiento",
            "NombramientoDescripcion" => "Nombramiento",
            "FkidPeriodo" => "Periodo",
            "FkidPeriodoInicial" => "Periodo inicial",
            "FkidPeriodoFinal" => "Periodo final",
            "FkidContratoTerceroNom" => "Contrato de tercero",
            "FkidConceptoProporcionalNom" => "Concepto proporcional",
            "FkidFormaCalculoNom" => "Forma de calculo",
            "FkidUnidadInfonavitNom" => "Unidad Infonavit",
            "FkidNominaEspecialNom" => "Nomina especial",
            "FkidContratoPres" => "Contrato",
            "FkidCatalogoPadreNom" => "Catalogo padre",
            "FechaIni" => "Fecha inicial",
            "FechaFin" => "Fecha final",
            "FechaInicio" => "Fecha inicial",
            "DescripcionCorta" => "Descripcion corta",
            "ValorDecimal1" => "Valor decimal 1",
            "ValorDecimal2" => "Valor decimal 2",
            "ValorEntero1" => "Valor entero 1",
            "ValorEntero2" => "Valor entero 2",
            "DatoExtra1" => "Dato extra 1",
            "DatoExtra2" => "Dato extra 2",
            "RegImss" => "Registro IMSS",
            "PrimaRiesgoImss" => "Prima riesgo IMSS",
            "ImpSdi" => "Importe SDI",
            "PerDed" => "Percepcion/Deduccion",
            "TasaInteres" => "Tasa de interes",
            "NumeroPagos" => "Numero de pagos",
            "ImporteMensualFijo" => "Importe mensual fijo",
            "EstaCerrado" => "Cerrado",
            "EstaComprometido" => "Comprometido",
            "EstaDevengado" => "Devengado",
            "EstaEjercido" => "Ejercido",
            "EstaDescontado" => "Descontado",
            "ZonaEconomica" => "Zona economica",
            "QuincenaInicio" => "Quincena inicio",
            "QuincenaFin" => "Quincena fin",
            "TotalPeriodos" => "Total de periodos",
            _ => Humanize(property.Name)
        };
    }

    private static string Humanize(string value)
    {
        var text = value
            .Replace("Fkid", string.Empty, StringComparison.Ordinal)
            .Replace("Pkid", "ID", StringComparison.Ordinal)
            .Replace("Nom", string.Empty, StringComparison.Ordinal)
            .Replace("Sis", string.Empty, StringComparison.Ordinal)
            .Replace("Pres", string.Empty, StringComparison.Ordinal);

        return System.Text.RegularExpressions.Regex
            .Replace(text, "([a-z])([A-Z])", "$1 $2")
            .Trim();
    }
}
