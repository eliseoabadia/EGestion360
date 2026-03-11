using EG.Application.Interfaces.Account;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Account
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
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error obteniendo menú para usuario {Id}", id);
                return StatusCode(500, new { success = false, message = "Error interno" });
            }
        }

        [HttpPost("ping")]
        public IActionResult Ping()
        {
            return Ok(new { success = true, message = "pong" });
        }
    }
}
