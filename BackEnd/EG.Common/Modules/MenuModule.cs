namespace EG.Common.Modules;

public static class MenuModule
{
    public const string Group = "Sistema";
    public const string SubGroup = "Menu";
    public const string ApiRoute = "api/Menu";
    public const string ExportAction = "exportar";
    public const string ViewPolicy = Group + "|" + SubGroup + "|view";
    public const string CreatePolicy = Group + "|" + SubGroup + "|new";
    public const string UpdatePolicy = Group + "|" + SubGroup + "|update";
    public const string DeletePolicy = Group + "|" + SubGroup + "|delete";
    public const string ExportPolicy = Group + "|" + SubGroup + "|CanExportToExcel";
}
