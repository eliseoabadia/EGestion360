using System.Security.Claims;
using EG.Domain.Interfaces;

namespace EG.ApiCoreBS.Services;

public sealed class HttpUserRequestContext(IHttpContextAccessor accessor) : IUserRequestContext
{
    public ClaimsPrincipal? User => accessor.HttpContext?.User;

    public string? GetHeader(string name) =>
        accessor.HttpContext?.Request.Headers.TryGetValue(name, out var value) == true
            ? value.FirstOrDefault()
            : null;
}
