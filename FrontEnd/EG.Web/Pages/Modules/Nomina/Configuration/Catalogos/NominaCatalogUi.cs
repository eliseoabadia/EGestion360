using System.Globalization;
using System.Reflection;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Web.Pages.Modules.Nomina.Configuration.Catalogos;

public static class NominaCatalogUi
{
    private static class ItemMetadata<TItem>
    {
        internal static readonly PropertyInfo? IdProperty = typeof(TItem).GetProperties()
            .FirstOrDefault(property => property.Name.StartsWith("Pkid", StringComparison.OrdinalIgnoreCase)
                && !property.Name.StartsWith("PkidNom", StringComparison.OrdinalIgnoreCase)
                && property.PropertyType == typeof(int));
    }

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
        "EmpresaNombre",
        "AreaClave",
        "AreaNombre",
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
        => !property.Name.Equals("IdPeriodo", StringComparison.OrdinalIgnoreCase)
            && (HiddenColumns.Contains(property.Name)
            || property.Name.StartsWith("Pkid", StringComparison.OrdinalIgnoreCase)
            || property.Name.StartsWith("Fkid", StringComparison.OrdinalIgnoreCase)
            || property.Name.Equals("Id", StringComparison.OrdinalIgnoreCase)
            || (!property.Name.Equals("PayrollId", StringComparison.OrdinalIgnoreCase)
                && property.Name.EndsWith("Id", StringComparison.OrdinalIgnoreCase))
            || property.Name.Equals("UsuarioCreacion", StringComparison.OrdinalIgnoreCase)
            || property.Name.Equals("UsuarioModificacion", StringComparison.OrdinalIgnoreCase));

    public static bool IsDisplayOnlyDialogColumn(string propertyName)
        => DisplayOnlyDialogColumns.Contains(propertyName);

    public static int GetItemId<TItem>(TItem item)
    {
        if (item == null)
        {
            return 0;
        }

        return ItemMetadata<TItem>.IdProperty?.GetValue(item) as int? ?? 0;
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

    private static readonly IReadOnlyDictionary<string, string> Labels = new Dictionary<string, string>(StringComparer.Ordinal)
    {
        ["PkidConcepto"] = "ID",
        ["PkidConceptoTabulador"] = "ID",
        ["PkidEmpresaNomina"] = "ID",
        ["PkidUniverso"] = "ID",
        ["PkidNivel"] = "ID",
        ["PkidClasePuesto"] = "ID",
        ["PkidPuesto"] = "ID",
        ["PkidPlazaAutorizada"] = "ID",
        ["PkidNombramiento"] = "ID",
        ["PkidImporteNivel"] = "ID",
        ["PkidContratoLaboral"] = "ID",
        ["PkidCatalogoSimple"] = "ID",
        ["PkidEstadoCivil"] = "ID",
        ["PkidEscolaridad"] = "ID",
        ["PkidDiaSemana"] = "ID",
        ["PkidMetodoPago"] = "ID",
        ["FkidEmpresaSis"] = "Empresa",
        ["EmpresaNombre"] = "Empresa",
        ["TipoNomina"] = "Tipo de nómina",
        ["FkidAreaSis"] = "Área",
        ["AreaNombre"] = "Área",
        ["FkidEmpresaNominaNom"] = "Empresa de nómina",
        ["EmpresaNominaNombre"] = "Empresa de nómina",
        ["FkidPersonaNom"] = "Persona",
        ["PersonaClaveNombre"] = "Persona",
        ["FkidConceptoNom"] = "Concepto",
        ["ConceptoClaveNombre"] = "Concepto",
        ["FkidPuestoNom"] = "Puesto",
        ["FkidPuestoPadreNom"] = "Puesto padre",
        ["PuestoNombre"] = "Puesto",
        ["PuestoClaveNombre"] = "Puesto",
        ["PuestoPadreNombre"] = "Puesto padre",
        ["FkidNivelNom"] = "Nivel",
        ["NivelClave"] = "Nivel",
        ["FkidUniversoNom"] = "Universo",
        ["UniversoDescripcion"] = "Universo",
        ["FkidClasePuestoNom"] = "Clase de puesto",
        ["ClasePuestoDescripcion"] = "Clase de puesto",
        ["FkidNombramientoNom"] = "Nombramiento",
        ["NombramientoDescripcion"] = "Nombramiento",
        ["FkidPeriodo"] = "Periodo",
        ["IdPeriodo"] = "Periodo",
        ["FkidPeriodoInicial"] = "Periodo inicial",
        ["FkidPeriodoFinal"] = "Periodo final",
        ["FkidPeriodoPagoSis"] = "Periodo de pago",
        ["FkidTipoPagoNom"] = "Tipo de pago",
        ["FkidContratoTerceroNom"] = "Contrato de tercero",
        ["FkidConceptoProporcionalNom"] = "Concepto proporcional",
        ["FkidFormaCalculoNom"] = "Forma de cálculo",
        ["FkidUnidadInfonavitNom"] = "Unidad Infonavit",
        ["FkidNominaEspecialNom"] = "Nómina especial",
        ["FkidContratoPres"] = "Contrato",
        ["FkidCatalogoPadreNom"] = "Catálogo padre",
        ["FechaIni"] = "Fecha inicial",
        ["FechaFin"] = "Fecha final",
        ["FechaInicio"] = "Fecha inicial",
        ["DescripcionCorta"] = "Descripción corta",
        ["ValorDecimal1"] = "Valor decimal 1",
        ["ValorDecimal2"] = "Valor decimal 2",
        ["ValorEntero1"] = "Valor entero 1",
        ["ValorEntero2"] = "Valor entero 2",
        ["DatoExtra1"] = "Dato extra 1",
        ["DatoExtra2"] = "Dato extra 2",
        ["RegImss"] = "Registro IMSS",
        ["PrimaRiesgoImss"] = "Prima riesgo IMSS",
        ["ImpSdi"] = "Importe SDI",
        ["PerDed"] = "Percepción/Deducción",
        ["TasaInteres"] = "Tasa de interés",
        ["NumeroPagos"] = "Número de pagos",
        ["ImporteMensualFijo"] = "Importe mensual fijo",
        ["EstaCerrado"] = "Cerrado",
        ["EstaComprometido"] = "Comprometido",
        ["EstaDevengado"] = "Devengado",
        ["EstaEjercido"] = "Ejercido",
        ["EstaDescontado"] = "Descontado",
        ["ZonaEconomica"] = "Zona económica",
        ["QuincenaInicio"] = "Quincena inicio",
        ["QuincenaFin"] = "Quincena fin",
        ["TotalPeriodos"] = "Total de periodos",
        ["FormaCalculoDescripcion"] = "Forma de cálculo",
    };

    public static string GetLabel(PropertyInfo property)
        => GetLabel(property.Name, property.DeclaringType);

    public static string GetLabel(string propertyName, Type? itemType = null)
    {
        if (propertyName == "FkidEmpresaSis" && itemType == typeof(NomConceptoTabularResponse))
        {
            return "Tipo de nómina";
        }

        return Labels.TryGetValue(propertyName, out var label) ? label : Humanize(propertyName);
    }

    private static string Humanize(string value)
    {
        var text = value;
        if (text.StartsWith("Fkid", StringComparison.Ordinal))
            text = text[4..];
        else if (text.StartsWith("Pkid", StringComparison.Ordinal))
            text = "ID" + text[4..];

        foreach (var suffix in new[] { "Nom", "Sis", "Pres" })
        {
            if (text.EndsWith(suffix, StringComparison.Ordinal))
            {
                text = text[..^suffix.Length];
                break;
            }
        }

        return System.Text.RegularExpressions.Regex
            .Replace(text, "([a-z])([A-Z])", "$1 $2")
            .Trim();
    }
}
