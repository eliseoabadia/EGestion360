using System.Globalization;
using System.Text;
using EG.Contracts.Platform.Licensing;

namespace EG.Domain.Platform.Licensing;

public static class LicenseModuleResolver
{
    public static string? ResolveControllerModule(string? controllerNamespace)
    {
        if (string.IsNullOrWhiteSpace(controllerNamespace))
        {
            return null;
        }

        if (Contains(controllerNamespace, ".Controllers.Modules.Nomina"))
            return LicenseModuleCodes.Nomina;
        if (Contains(controllerNamespace, ".Controllers.Modules.PBR") ||
            Contains(controllerNamespace, ".Controllers.PBR"))
            return LicenseModuleCodes.Pbr;
        if (Contains(controllerNamespace, ".Controllers.Modules.GRP.Administracion"))
            return LicenseModuleCodes.GrpAdministracion;
        if (Contains(controllerNamespace, ".Controllers.Modules.GRP.Almacen") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.ConteoCiclico") ||
            Contains(controllerNamespace, ".Controllers.Almacen") ||
            Contains(controllerNamespace, ".Controllers.ConteoCiclico"))
            return LicenseModuleCodes.GrpAlmacen;
        if (Contains(controllerNamespace, ".Controllers.Modules.GRP.Contabilidad") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.Catalogos.Contabilidad") ||
            Contains(controllerNamespace, ".Controllers.Contabilidad") ||
            Contains(controllerNamespace, ".Controllers.Catalogos.Contabilidad"))
            return LicenseModuleCodes.GrpContabilidad;
        if (Contains(controllerNamespace, ".Controllers.Modules.GRP.Patrimonio") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.Catalogos.Patrimonio") ||
            Contains(controllerNamespace, ".Controllers.Patrimonio") ||
            Contains(controllerNamespace, ".Controllers.Catalogos.Patrimonio"))
            return LicenseModuleCodes.GrpPatrimonio;
        if (Contains(controllerNamespace, ".Controllers.Modules.GRP.Presupuesto") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.PresupuestoComprometido") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.PresupuestoModificado") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.CuentasXPagar") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.Catalogos.Presupuestales") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.Catalogos.Tesoreria") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.Catalogos.ClavePrograma") ||
            Contains(controllerNamespace, ".Controllers.Presupuesto") ||
            Contains(controllerNamespace, ".Controllers.PresupuestoComprometido") ||
            Contains(controllerNamespace, ".Controllers.PresupuestoModificado") ||
            Contains(controllerNamespace, ".Controllers.CuentasXPagar") ||
            Contains(controllerNamespace, ".Controllers.Catalogos.Presupuestales") ||
            Contains(controllerNamespace, ".Controllers.Catalogos.Tesoreria") ||
            Contains(controllerNamespace, ".Controllers.Catalogos.ClavePrograma"))
            return LicenseModuleCodes.GrpPresupuesto;
        if (Contains(controllerNamespace, ".Controllers.Modules.GRP.Planeacion") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.Contratos") ||
            Contains(controllerNamespace, ".Controllers.Modules.GRP.Catalogos.Adquisicion") ||
            Contains(controllerNamespace, ".Controllers.Planeacion") ||
            Contains(controllerNamespace, ".Controllers.Contratos") ||
            Contains(controllerNamespace, ".Controllers.Catalogos.Adquisicion"))
            return LicenseModuleCodes.GrpAdquisiciones;

        return null;
    }

    public static bool IsCommercialControllerNamespace(string? controllerNamespace) =>
        !string.IsNullOrWhiteSpace(controllerNamespace) &&
        (Contains(controllerNamespace, ".Controllers.Modules.GRP") ||
         Contains(controllerNamespace, ".Controllers.Modules.Nomina") ||
         Contains(controllerNamespace, ".Controllers.Modules.PBR") ||
         Contains(controllerNamespace, ".Controllers.PBR") ||
         Contains(controllerNamespace, ".Controllers.Almacen") ||
         Contains(controllerNamespace, ".Controllers.ConteoCiclico") ||
         Contains(controllerNamespace, ".Controllers.Contabilidad") ||
         Contains(controllerNamespace, ".Controllers.Catalogos.Contabilidad") ||
         Contains(controllerNamespace, ".Controllers.Patrimonio") ||
         Contains(controllerNamespace, ".Controllers.Catalogos.Patrimonio") ||
         Contains(controllerNamespace, ".Controllers.Presupuesto") ||
         Contains(controllerNamespace, ".Controllers.PresupuestoComprometido") ||
         Contains(controllerNamespace, ".Controllers.PresupuestoModificado") ||
         Contains(controllerNamespace, ".Controllers.CuentasXPagar") ||
         Contains(controllerNamespace, ".Controllers.Catalogos.Presupuestales") ||
         Contains(controllerNamespace, ".Controllers.Catalogos.Tesoreria") ||
         Contains(controllerNamespace, ".Controllers.Catalogos.ClavePrograma") ||
         Contains(controllerNamespace, ".Controllers.Planeacion") ||
         Contains(controllerNamespace, ".Controllers.Contratos") ||
         Contains(controllerNamespace, ".Controllers.Catalogos.Adquisicion"));

    public static bool IsCoreControllerNamespace(string? controllerNamespace) =>
        !string.IsNullOrWhiteSpace(controllerNamespace) &&
        (string.Equals(controllerNamespace, "EG.ApiCoreBS.Controllers", StringComparison.Ordinal) ||
         Contains(controllerNamespace, ".Controllers.Platform") ||
         Contains(controllerNamespace, ".Controllers.Account") ||
         Contains(controllerNamespace, ".Controllers.General") ||
         Contains(controllerNamespace, ".Controllers.Reporting") ||
         Contains(controllerNamespace, ".Controllers.SoporteDocumental") ||
         Contains(controllerNamespace, ".Controllers.ProGeneralfile"));

    public static IReadOnlyList<string> ResolveAdditionalControllerModules(
        string? controllerName,
        string? actionName)
    {
        if (string.IsNullOrWhiteSpace(controllerName))
            return [];

        if (controllerName.StartsWith("SolicitudSuficiencia", StringComparison.OrdinalIgnoreCase))
            return [LicenseModuleCodes.GrpPresupuesto];

        if (controllerName.StartsWith("AutorizacionSuficiencia", StringComparison.OrdinalIgnoreCase))
            return [LicenseModuleCodes.GrpAdquisiciones];

        if (string.Equals(controllerName, "Almacen", StringComparison.OrdinalIgnoreCase) &&
            actionName is "Create" or "Update")
            return [LicenseModuleCodes.GrpAdquisiciones];

        if (string.Equals(controllerName, "Bien", StringComparison.OrdinalIgnoreCase) &&
            actionName is "GenerarDesdeDetalle" or "RegistrarRecepcion")
            return [LicenseModuleCodes.GrpAdquisiciones];

        if (string.Equals(controllerName, "NominaProcesos", StringComparison.OrdinalIgnoreCase) &&
            actionName is "CrearComprometido" or "CrearDevengado" or "CrearEjercido")
            return [LicenseModuleCodes.GrpPresupuesto];

        return [];
    }

    public static string? ResolveMenuModule(
        string? name,
        string? legacyName,
        string? route,
        string? ancestorContext = null)
    {
        var normalizedRoute = Normalize(route);
        var normalized = Normalize($"{ancestorContext} {name} {legacyName} {route}");

        if (StartsWithAny(normalizedRoute, "pbr") || HasWord(normalized, "pbr"))
            return LicenseModuleCodes.Pbr;

        if (StartsWithAny(normalizedRoute, "nomina", "nom", "rh", "aux") ||
            HasAny(normalized, "nomina", "recibonomina", "calcnomina", "incidencia nomina"))
            return LicenseModuleCodes.Nomina;

        if (StartsWithAny(normalizedRoute, "almacen", "conteociclico", "configuracion almacen") ||
            HasAny(normalized, "almacen", "suministro salida", "conteo ciclico"))
            return LicenseModuleCodes.GrpAlmacen;

        if (StartsWithAny(normalizedRoute, "contabilidad", "configuracion contabilidad") ||
            HasAny(normalized, "contabilidad", "cuenta contable", "poliza contable"))
            return LicenseModuleCodes.GrpContabilidad;

        if (StartsWithAny(normalizedRoute, "patrimonio", "configuracion patrimonio") ||
            HasAny(normalized, "patrimonio", "resguardo", "baja patrimonial", "activo fijo"))
            return LicenseModuleCodes.GrpPatrimonio;

        if (StartsWithAny(normalizedRoute, "adquisiciones", "adquisicion", "configuracion adquisicion") ||
            HasAny(normalized, "adquisiciones", "requisicion", "cotizacion", "orden de compra", "proveedor", "paaas", "estudio de mercado", "contratos"))
            return LicenseModuleCodes.GrpAdquisiciones;

        if (StartsWithAny(normalizedRoute, "presupuesto", "tesoreria", "reportescxc", "configuracion presupuestales") ||
            HasAny(normalized, "presupuesto", "tesoreria", "cuentas por pagar", "cuentas por cobrar", "egreso autorizado", "ingreso autorizado", "reportes cxc"))
            return LicenseModuleCodes.GrpPresupuesto;

        if (StartsWithAny(normalizedRoute, "administracion") || HasWord(normalized, "administracion"))
            return LicenseModuleCodes.GrpAdministracion;

        return null;
    }

    public static bool IsCoreMenu(string? name, string? legacyName, string? route, string? ancestorContext = null)
    {
        var normalizedRoute = Normalize(route);
        var normalized = Normalize($"{ancestorContext} {name} {legacyName}");

        return string.IsNullOrWhiteSpace(normalizedRoute) ||
               normalizedRoute == "/" ||
               StartsWithAny(normalizedRoute, "sistema", "configuracion sistema", "perfil", "ayuda", "soporte") ||
               HasAny(normalized, "configuracion", "sistema", "perfil", "ayuda", "soporte");
    }

    public static string? ResolveReportModule(string? reportName)
    {
        var normalized = Normalize(reportName);
        if (string.IsNullOrWhiteSpace(normalized))
            return null;

        if (HasAny(normalized, "template wizard"))
            return LicenseModuleCodes.GrpAdministracion;
        if (HasAny(normalized, "adquisiciones", "paaas"))
            return LicenseModuleCodes.GrpAdquisiciones;
        if (HasAny(normalized, "alma", "almacen", "suministros salida"))
            return LicenseModuleCodes.GrpAlmacen;
        if (HasAny(normalized, "patrimonio", "activo fijo", "baja patrimonial", "sicop"))
            return LicenseModuleCodes.GrpPatrimonio;
        if (HasAny(normalized, "pres ", "presupuesto", "proyecciones egresos", "resultado egresos"))
            return LicenseModuleCodes.GrpPresupuesto;
        if (HasAny(normalized, "nomina"))
            return LicenseModuleCodes.Nomina;
        if (HasAny(normalized, "pbr"))
            return LicenseModuleCodes.Pbr;

        return LicenseModuleCodes.GrpContabilidad;
    }

    private static bool Contains(string source, string value) =>
        source.Contains(value, StringComparison.OrdinalIgnoreCase);

    private static bool StartsWithAny(string value, params string[] prefixes) =>
        prefixes.Any(prefix => value.StartsWith(prefix, StringComparison.Ordinal));

    private static bool HasAny(string source, params string[] values) =>
        values.Any(value => source.Contains(value, StringComparison.Ordinal));

    private static bool HasWord(string source, string word)
    {
        var padded = $" {source} ";
        return padded.Contains($" {word} ", StringComparison.Ordinal);
    }

    private static string Normalize(string? value)
    {
        if (string.IsNullOrWhiteSpace(value))
            return string.Empty;

        var decomposed = value.Trim().Replace('\\', '/').Normalize(NormalizationForm.FormD);
        var builder = new StringBuilder(decomposed.Length);
        var previousWasSpace = false;

        foreach (var character in decomposed)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(character) == UnicodeCategory.NonSpacingMark)
                continue;

            var normalized = char.IsLetterOrDigit(character) ? char.ToLowerInvariant(character) : ' ';
            if (normalized == ' ')
            {
                if (!previousWasSpace)
                    builder.Append(' ');
                previousWasSpace = true;
                continue;
            }

            builder.Append(normalized);
            previousWasSpace = false;
        }

        return builder.ToString().Trim();
    }
}
