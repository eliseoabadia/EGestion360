namespace EG.Common.Enums;

public enum PermissionAction
{
    View,
    ViewMenu,
    Delete,
    New,
    Update,
    CanExportToExcel,
    Authorize
}

public static class PermissionActionExtensions
{
    private static readonly IReadOnlyDictionary<PermissionAction, string> ClaimValues =
        new Dictionary<PermissionAction, string>
        {
            [PermissionAction.View] = "view",
            [PermissionAction.ViewMenu] = "view-menu",
            [PermissionAction.Delete] = "delete",
            [PermissionAction.New] = "new",
            [PermissionAction.Update] = "update",
            [PermissionAction.CanExportToExcel] = "CanExportToExcel",
            [PermissionAction.Authorize] = "authorize"
        };

    public static string ToClaimValue(this PermissionAction action) => ClaimValues[action];

    public static IReadOnlyList<string> GetAllClaimValues() =>
        Enum.GetValues<PermissionAction>()
            .Select(action => action.ToClaimValue())
            .ToList();
}
