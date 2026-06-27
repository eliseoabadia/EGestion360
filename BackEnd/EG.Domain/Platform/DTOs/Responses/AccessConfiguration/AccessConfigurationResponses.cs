namespace EG.Domain.Platform.DTOs.Responses.AccessConfiguration;

public sealed class AccessConfigurationSnapshotResponse
{
    public List<AccessRoleSummaryResponse> Roles { get; set; } = new();
    public List<AccessUserSummaryResponse> Users { get; set; } = new();
    public List<AccessMenuSummaryResponse> Menus { get; set; } = new();
    public List<string> PermissionActions { get; set; } = new();
    public int MenuRoleCount { get; set; }
}

public sealed class AccessRoleSummaryResponse
{
    public string Id { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public int ClaimCount { get; set; }
    public int UserCount { get; set; }
    public int MenuCount { get; set; }
}

public sealed class AccessUserSummaryResponse
{
    public int PkIdUsuario { get; set; }
    public string AspNetUserId { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string? PayrollId { get; set; }
    public string? AccessNumber { get; set; }
    public int RoleCount { get; set; }
}

public sealed class AccessMenuSummaryResponse
{
    public int PkIdMenu { get; set; }
    public int? ParentMenuId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string LegacyName { get; set; } = string.Empty;
    public string? Route { get; set; }
    public string? Icon { get; set; }
    public int Type { get; set; }
    public int? Order { get; set; }
}

public sealed class AccessRoleDetailResponse
{
    public AccessRoleSummaryResponse Role { get; set; } = new();
    public List<int> AssignedUserIds { get; set; } = new();
    public List<AccessMenuSummaryResponse> Menus { get; set; } = new();
    public List<AccessClaimResponse> Claims { get; set; } = new();
}

public sealed class AccessClaimResponse
{
    public int Id { get; set; }
    public string Group { get; set; } = string.Empty;
    public string SubGroup { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public string? Description { get; set; }
    public string Values { get; set; } = string.Empty;
    public int ReferenceId { get; set; }
    public List<string> ValueList { get; set; } = new();
}
