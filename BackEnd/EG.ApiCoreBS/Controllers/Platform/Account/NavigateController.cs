using EG.Application.Interfaces.Account;
using EG.Common.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Account
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NavigateController : ControllerBase
    {
        private readonly INavigateAppService _navigateAppService;
        private readonly ILogger<NavigateController> _logger;

        public NavigateController(INavigateAppService navigateAppService, ILogger<NavigateController> logger)
        {
            _navigateAppService = navigateAppService;
            _logger = logger;
        }

        [HttpGet("{id:int}")]
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

        private static object Error(string message, ApiResponseCode code = ApiResponseCode.Error) =>
            new { success = false, message, code = code.ToCode() };
    }
}
