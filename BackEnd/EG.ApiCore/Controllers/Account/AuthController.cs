using EG.Application.CommonModel;
using EG.Business.Interfaces;
using EG.Common.Enums;
using EG.Domain.DTOs.Requests;
using EG.Filters;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace EG.ApiCore.Controllers.Account
{
    [Route("api/[controller]")]
    [ServiceFilter(typeof(InitializeUserFilter))]
    [ApiController]
    public class AuthController(IOptions<JwtSettings> jwtSettings, IAuthService authService) : BaseController
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(AuthController));
        private readonly IAuthService _authService = authService;
        private readonly IOptions<JwtSettings> _jwtSettings = jwtSettings;

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto loginRequest)
        {
            if (loginRequest == null)
            {
                return BadRequest("Invalid login request");
            }
            var response = await _authService.Login(loginRequest, _jwtSettings.Value);
            if (response.IsAuthenticated.Value)
            {
                _logger.LogMessage(LogLevelGRP.Info, $"Log Login {ControllerName} {loginRequest.Email}", (byte)SystemLogTypes.Information, "Login", UserId.ToString(), IpAddress);
                return Ok(response);
            }
            else
            {
                _logger.LogMessage(LogLevelGRP.Info, $"Log Login {ControllerName} {loginRequest.Email}", (byte)SystemLogTypes.Error, "Login", UserId.ToString(), IpAddress);
                return Unauthorized(response.Message);
            }
        }

        //[HttpPost("register")]
        //public async Task<IActionResult> Register([FromBody] CreateUserDto createUser)
        //{
        //    if (createUser == null)
        //    {
        //        return BadRequest("Invalid registration request");
        //    }
        //    try
        //    {
        //        var response = await _authService.Register(createUser);
        //        if (response != null)
        //        {
        //            return CreatedAtAction(nameof(Register), new { id = response.Id }, response);
        //        }
        //        else
        //        {
        //            return BadRequest("Registration failed");
        //        }
        //    }
        //    catch (DbUpdateException ex)
        //    {
        //        if (ex.InnerException!.Message.Contains("duplicate"))
        //        {
        //            return Conflict(new { Message = "Ese correo ya esta siendo utilizado por otro usuario", isSuccess = false });
        //        }
        //        return StatusCode(StatusCodes.Status500InternalServerError, ex.InnerException!.Message);
        //    }
        //    catch (Exception ex)
        //    {
        //        return StatusCode(StatusCodes.Status500InternalServerError, ex.Message);
        //    }
        //}
    }
}