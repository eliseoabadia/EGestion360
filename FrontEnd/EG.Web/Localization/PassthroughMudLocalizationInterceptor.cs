using System.Globalization;
using Microsoft.Extensions.Localization;
using MudBlazor;

namespace EG.Web.Localization;

public sealed class PassthroughMudLocalizationInterceptor : ILocalizationInterceptor, ILocalizationEnumInterceptor
{
    public LocalizedString Handle(string key, params object[] arguments)
    {
        var value = arguments is { Length: > 0 }
            ? string.Format(CultureInfo.CurrentUICulture, key, arguments)
            : key;

        return new LocalizedString(key, value, resourceNotFound: true);
    }

    public string Handle(Enum enumeration)
        => enumeration.ToString();
}
