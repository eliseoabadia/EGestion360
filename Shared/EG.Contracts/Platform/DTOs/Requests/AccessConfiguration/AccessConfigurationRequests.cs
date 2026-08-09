namespace EG.Domain.Platform.DTOs.Requests.AccessConfiguration;

public sealed class SaveAccessRoleRequest
{
    public string? Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Code { get; set; }
    public bool ReplaceUsers { get; set; } = true;
    public List<int> AssignedUserIds { get; set; } = new();
    public bool ReplaceClaims { get; set; }
    public List<SaveAccessClaimRequest> Claims { get; set; } = new();
}

public sealed class SaveAccessUserRolesRequest
{
    public int PkIdUsuario { get; set; }
    public List<string> RoleIds { get; set; } = new();
}

public sealed class SaveAccessClaimRequest
{
    public int Id { get; set; }
    public string Group { get; set; } = string.Empty;
    public string SubGroup { get; set; } = string.Empty;
    public string? Name { get; set; }
    public string? Code { get; set; }
    public string? Description { get; set; }
    public int ReferenceId { get; set; }
    public List<string> Values { get; set; } = new();
}
