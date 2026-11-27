using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;

namespace EG.ApiCoreBS.Middleware;

/// <summary>Valida la identidad y empresa antes de que un controlador ejecute su operación.</summary>
public sealed class RequestScopeValidationMiddleware(RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context, IUserContextService userContext)
    {
        if (context.User.Identity?.IsAuthenticated == true &&
            context.GetEndpoint()?.Metadata.GetMetadata<IAllowAnonymous>() is null)
        {
            userContext.GetCurrentUserId();
            userContext.TryGetCurrentEmpresaId();
        }
        await next(context);
    }
}
