using EG.Application.Interfaces.Account;
using EG.Common.Enums;
using EG.Domain.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Account
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : ControllerBase
    {
        private readonly IAuthAppService _authAppService;
        private readonly Logger.Log4NetLogger _logger;

        public AuthController(IAuthAppService authAppService)
        {
            _authAppService = authAppService ?? throw new ArgumentNullException(nameof(authAppService));
            _logger = new Logger.Log4NetLogger(typeof(AuthController));
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto loginRequest)
        {
            try
            {
                if (loginRequest == null)
                    return BadRequest(new { success = false, message = "Solicitud inválida" });

                var response = await _authAppService.LoginAsync(loginRequest);

                if (response?.IsAuthenticated == true)
                {
                    _logger.LogMessage(
                        LogLevelGRP.Info,
                        $"Login exitoso: {loginRequest.Email}",
                        (byte)SystemLogTypes.Information,
                        "Login",
                        response.PkIdUsuario.ToString(),
                        "");

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
                        "");

                    return Unauthorized(new { success = false, message = response?.Message ?? "Credenciales incorrectas" });
                }
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error en login: {ex.Message}",
                    (byte)SystemLogTypes.Error,
                    "Login",
                    "0",
                    ex.StackTrace ?? "");

                return StatusCode(500, new { success = false, message = "Error interno del servidor" });
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error inesperado en login: {ex.Message}",
                    (byte)SystemLogTypes.Error,
                    "Login",
                    "0",
                    ex.StackTrace ?? "");

                return StatusCode(500, new { success = false, message = "Error interno del servidor" });
            }
        }
    }
}