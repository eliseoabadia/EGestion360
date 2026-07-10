using System.Globalization;
using Microsoft.Extensions.Localization;
using MudBlazor;

namespace EG.Web.Localization;

public sealed class PassthroughMudLocalizationInterceptor : ILocalizationInterceptor, ILocalizationEnumInterceptor
{
    private static readonly IReadOnlyDictionary<string, string> Translations = new Dictionary<string, string>(StringComparer.Ordinal)
    {
        ["MudDataGrid_Unsort"] = "Quitar ordenamiento",
        ["MudDataGrid_Hide"] = "Ocultar columna",
        ["MudDataGrid_HideAll"] = "Ocultar todas",
        ["MudDataGrid_ShowAll"] = "Mostrar todas",
        ["MudDataGrid_Columns"] = "Columnas",
        ["MudDataGrid_ShowColumnOptions"] = "Opciones de columnas",
        ["MudDataGrid_Filter"] = "Filtrar",
        ["MudDataGrid_Clear"] = "Limpiar",
        ["MudDataGrid_Apply"] = "Aplicar",
        ["MudDataGrid_Sort"] = "Ordenar",
        ["MudDataGrid_Group"] = "Agrupar",
        ["MudDataGrid_Ungroup"] = "Quitar agrupacion",
        ["MudDataGrid_MoveUp"] = "Mover arriba",
        ["MudDataGrid_MoveDown"] = "Mover abajo"
    };

    public LocalizedString Handle(string key, params object[] arguments)
    {
        var template = Translations.TryGetValue(key, out var translation) ? translation : key;
        var value = arguments is { Length: > 0 }
            ? string.Format(CultureInfo.CurrentUICulture, template, arguments)
            : template;

        return new LocalizedString(key, value, resourceNotFound: true);
    }

    public string Handle(Enum enumeration)
        => enumeration.ToString();
}
