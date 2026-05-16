using EG.Application.Interfaces.Account;
using EG.Common.Enums;
using EG.Domain.DTOs.Requests;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Account
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
                    return BadRequest(Error("Solicitud invalida", ApiResponseCode.InvalidData));

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

                    return Unauthorized(Error(response?.Message ?? "Credenciales incorrectas", ApiResponseCode.Unauthorized));
                }
            }
            catch (ArgumentException ex)
            {
                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
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

                return StatusCode(500, Error("Error interno del servidor"));
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

                return StatusCode(500, Error("Error interno del servidor"));
            }
        }

        private static object Error(string message, ApiResponseCode code = ApiResponseCode.Error) =>
            new { success = false, message, code = code.ToCode() };
    }
}
