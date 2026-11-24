using EG.Application.Interfaces.Account;
using EG.Domain.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;

namespace EG.ApiCoreBS.Controllers.Account;

[ApiController]
[AllowAnonymous]
[Route("api/Auth")]
public sealed class PasswordResetController(IPasswordResetAppService service) : ControllerBase
{
    [HttpPost("forgot-password")]
    [EnableRateLimiting("password-reset")]
    public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        var result = await service.RequestAsync(request, cancellationToken);
        if (result.Code == "RECOVERY_UNAVAILABLE")
        {
            return StatusCode(StatusCodes.Status503ServiceUnavailable, result);
        }
        return result.Success ? Ok(result) : BadRequest(result);
    }

    [HttpPost("reset-password")]
    [EnableRateLimiting("login")]
    public async Task<IActionResult> ResetPassword(ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        var result = await service.ResetAsync(request, cancellationToken);
        return result.Success ? Ok(result) : BadRequest(result);
    }
}
