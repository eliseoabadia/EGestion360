using EG.Application.Interfaces.Account;
using EG.Common;
using EG.Common.Enums;
using EG.Common.Util;
using EG.Domain.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Account
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthAppService _authAppService;
        private readonly IUserIpService _userIpService;
        private readonly Logger.Log4NetLogger _logger;

        public AuthController(IAuthAppService authAppService, IUserIpService userIpService)
        {
            _authAppService = authAppService ?? throw new ArgumentNullException(nameof(authAppService));
            _userIpService = userIpService ?? throw new ArgumentNullException(nameof(userIpService));
            _logger = new Logger.Log4NetLogger(typeof(AuthController));
        }

        [HttpPost("login")]
        [AllowAnonymous]
        [EnableRateLimiting("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto loginRequest)
        {
            var clientIp = _userIpService.GetUserIpAddress(HttpContext);

            try
            {
                if (loginRequest == null)
                {
                    _logger.LogMessage(
                        LogLevelGRP.Warn,
                        $"Login invalido. TraceId={HttpContext.TraceIdentifier}",
                        (byte)SystemLogTypes.Warning,
                        "Login",
                        "0",
                        clientIp);

                    return BadRequest(Error("Solicitud invalida", ApiResponseCode.InvalidData));
                }

                var response = await _authAppService.LoginAsync(loginRequest);

                if (response?.IsAuthenticated == true)
                {
                    _logger.LogMessage(
                        LogLevelGRP.Info,
                        $"Login exitoso: {loginRequest.Email}",
                        (byte)SystemLogTypes.Information,
                        "Login",
                        response.PkIdUsuario.ToString(),
                        clientIp);

                    return Ok(response);
                }
                else
                {
                    _logger.LogMessage(
                        LogLevelGRP.Info,
                        $"Login fallido: {loginRequest.Email}",
                        (byte)SystemLogTypes.Warning,
                        "Login",
                        "0",
                        clientIp);

                    return Unauthorized(Error(response?.Message ?? "Credenciales incorrectas", ApiResponseCode.Unauthorized));
                }
            }
            catch (ArgumentException ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Warn,
                    $"Solicitud de login invalida para {loginRequest?.Email}. TraceId={HttpContext.TraceIdentifier}; Error={ex.Message}",
                    (byte)SystemLogTypes.Warning,
                    "Login",
                    "0",
                    clientIp);

                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error en login. TraceId={HttpContext.TraceIdentifier}; Error={ex}",
                    (byte)SystemLogTypes.Error,
                    "Login",
                    "0",
                    clientIp);

                return StatusCode(500, Error(UserFacingMessages.UnexpectedError));
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error inesperado en login. TraceId={HttpContext.TraceIdentifier}; Error={ex}",
                    (byte)SystemLogTypes.Error,
                    "Login",
                    "0",
                    clientIp);

                return StatusCode(500, Error(UserFacingMessages.UnexpectedError));
            }
        }

        private static object Error(string message, ApiResponseCode code = ApiResponseCode.Error) =>
            new { success = false, message, code = code.ToCode() };
    }
}
