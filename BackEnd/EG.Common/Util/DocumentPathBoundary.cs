namespace EG.Common.Util;

public static class DocumentPathBoundary
{
    public static string Resolve(string root, string relativePath)
    {
        var fullRoot = Path.GetFullPath(root);
        var fullPath = Path.GetFullPath(Path.Combine(fullRoot, relativePath));
        var rootPrefix = Path.EndsInDirectorySeparator(fullRoot) ? fullRoot : fullRoot + Path.DirectorySeparatorChar;
        var comparison = OperatingSystem.IsWindows() ? StringComparison.OrdinalIgnoreCase : StringComparison.Ordinal;
        if (Path.IsPathRooted(relativePath) || !fullPath.StartsWith(rootPrefix, comparison))
            throw new UnauthorizedAccessException(EG.Common.ApplicationText.Permissions.ResourceDenied);
        return fullPath;
    }
}
