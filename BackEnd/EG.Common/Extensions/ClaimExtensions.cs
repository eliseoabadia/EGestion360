using System.Security.Claims;
using EG.Common.GenericModel;

public static class ClaimExtensions
{
    public static IEnumerable<Claim> ToClaims(this IEnumerable<ClaimItemModel> items)
    {
        if (items == null) yield break;

        foreach (var item in items)
        {
            // ClaimType: combinación de Group/SubGroup
            var type = string.IsNullOrWhiteSpace(item.SubGroup)
                ? item.Group
                : $"{item.Group}:{item.SubGroup}";

            // ClaimValue: CSV de acciones
            yield return new Claim(type, item.Values ?? string.Empty);
        }
    }
}