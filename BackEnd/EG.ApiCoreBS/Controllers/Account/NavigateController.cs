using EG.Application.Interfaces.Account;
using EG.Common.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;

namespace EG.ApiCoreBS.Controllers.Account
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NavigateController : ControllerBase
    {
        private readonly INavigateAppService _navigateAppService;
        private readonly ILogger<NavigateController> _logger;
        private readonly IConfiguration _configuration;

        public NavigateController(INavigateAppService navigateAppService, ILogger<NavigateController> logger, IConfiguration configuration)
        {
            _navigateAppService = navigateAppService;
            _logger = logger;
            _configuration = configuration;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetMenu(int id)
        {
            try
            {
                var menu = await _navigateAppService.GetMenuAsync(id);
                return Ok(menu);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(Error(ex.Message, ApiResponseCode.NotFound));
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(500, Error(ex.Message));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo menú para usuario {Id}", id);
                return StatusCode(500, Error("Error interno"));
            }
        }

        [HttpGet("claims/{userId}")]
        public async Task<IActionResult> GetAllClaimsByUser(int userId)
        {
            try
            {
                var claims = await _navigateAppService.GetAllClaimsByUser(userId);
                return Ok(claims);
            }
            catch (ArgumentException ex)
            {
                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
            }
            catch (InvalidOperationException ex)
            {
                _logger.LogError(ex, "Error obteniendo claims para usuario {UserId}", userId);
                return StatusCode(500, Error(ex.Message));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error inesperado obteniendo claims para usuario {UserId}", userId);
                return StatusCode(500, Error("Error interno"));
            }
        }

        [HttpPost("ping")]
        [HttpGet("ping")]
        [AllowAnonymous]
        public IActionResult Ping()
        {
            return Ok(new { success = true, message = "pong" });
        }
        
        [HttpGet("version")]
        [AllowAnonymous]
        public IActionResult GetVersion()
        {
            var version = _configuration["ApplicationVersion"] ?? "1.0.0";
            return Ok(new { success = true, version = version });
        }

        private static object Error(string message, ApiResponseCode code = ApiResponseCode.Error) =>
            new { success = false, message, code = code.ToCode() };
    }
}
