using Microsoft.AspNetCore.Http;

namespace EG.Common.Util;

public interface IUserIpService
{
    string GetUserIpAddress(HttpContext context);
}

public class UserIpService : IUserIpService
{
    public string GetUserIpAddress(HttpContext context)
    {
        if (!string.IsNullOrEmpty(context.Request.Headers["CF-CONNECTING-IP"]))
            return context.Request.Headers["CF-CONNECTING-IP"];

        if (!string.IsNullOrEmpty(context.Request.Headers["X-Forwarded-For"]))
            return context.Request.Headers["X-Forwarded-For"];

        return context.Connection.RemoteIpAddress?.ToString();
    }
}

