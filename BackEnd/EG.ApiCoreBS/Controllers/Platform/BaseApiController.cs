using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EG.ApiCoreBS.Controllers
{
    public abstract class BaseApiController : ControllerBase
    {
        protected int GetCurrentUserId()
        {
            var claim = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier);
            return claim != null ? int.Parse(claim.Value) : 0;
        }
    }
}
