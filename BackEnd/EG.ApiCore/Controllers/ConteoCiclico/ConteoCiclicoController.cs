using EG.ApiCore.Services;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico.EG.Domain.DTOs.ConteoCiclico;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.ConteoCiclico
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ConteoCiclicoController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(ConteoCiclicoController));
        private readonly IConteoCiclicoService _conteoCiclicoService;
        private readonly IUserContextService _userContext;

        public ConteoCiclicoController(IConteoCiclicoService conteoCiclicoService, IUserContextService userContext)
        {
            _conteoCiclicoService = conteoCiclicoService;
            _userContext = userContext;
        }

        // POST: api/ConteoCiclico/generar
        [HttpPost("generar")]
        public async Task<ActionResult<ConteoResult>> GenerarConteo([FromBody] GenerarConteoRequest request)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _conteoCiclicoService.GenerarConteoAsync(request, usuarioActual);
                if (result.Success)
                    return Ok(result);
                return BadRequest(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GenerarConteo: {ex.Message}", ex);
                return StatusCode(500, new ConteoResult { Success = false, Message = ex.Message });
            }
        }

        // POST: api/ConteoCiclico/iniciar/{id}
        [HttpPost("iniciar/{id}")]
        public async Task<ActionResult<ConteoResult>> IniciarConteo(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _conteoCiclicoService.IniciarConteoAsync(id, usuarioActual);
                if (result.Success)
                    return Ok(result);
                return BadRequest(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en IniciarConteo: {ex.Message}", ex);
                return StatusCode(500, new ConteoResult { Success = false, Message = ex.Message });
            }
        }

        // POST: api/ConteoCiclico/registrar
        [HttpPost("registrar")]
        public async Task<ActionResult<ConteoResult>> RegistrarConteo([FromBody] RegistrarConteoRequest request)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _conteoCiclicoService.RegistrarConteoAsync(request, usuarioActual);
                if (result.Success)
                    return Ok(result);
                return BadRequest(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en RegistrarConteo: {ex.Message}", ex);
                return StatusCode(500, new ConteoResult { Success = false, Message = ex.Message });
            }
        }

        // POST: api/ConteoCiclico/cerrar
        [HttpPost("cerrar")]
        public async Task<ActionResult<ConteoResult>> CerrarConteo([FromBody] CerrarConteoRequest request)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _conteoCiclicoService.CerrarConteoAsync(request, usuarioActual);
                if (result.Success)
                    return Ok(result);
                return BadRequest(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en CerrarConteo: {ex.Message}", ex);
                return StatusCode(500, new ConteoResult { Success = false, Message = ex.Message });
            }
        }

        // GET: api/ConteoCiclico/dashboard
        [HttpGet("dashboard")]
        public async Task<ActionResult<DashboardResponse>> GetDashboard([FromQuery] int? sucursalId = null)
        {
            try
            {
                var result = await _conteoCiclicoService.GetDashboardAsync(sucursalId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error en GetDashboard: {ex.Message}", ex);
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }
}