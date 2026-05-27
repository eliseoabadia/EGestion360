using Microsoft.AspNetCore.Authorization;

namespace EG.ApiCoreBS.Auth
{
    public sealed record PermissionRequirement(string Group, string SubGroup, string Action) : IAuthorizationRequirement;
}
