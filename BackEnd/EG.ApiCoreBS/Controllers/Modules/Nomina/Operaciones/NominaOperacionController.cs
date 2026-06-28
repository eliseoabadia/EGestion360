using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Modules.Nomina.Operaciones
{
    [ApiController]
    [Authorize]
    [Route("api/NomOperacion")]
    public class NominaOperacionController(
        INominaOperacionAppService appService,
        IUserContextService userContext) : ControllerBase
    {
        private readonly INominaOperacionAppService _appService = appService;
        private readonly IUserContextService _userContext = userContext;
        private readonly Logger.Log4NetLogger _logger = new(typeof(NominaOperacionController));

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<NominaOperacionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                return Ok(await _appService.GetAllPaginadoAsync(request));
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error al obtener operaciones de nomina: {ex}",
                    (byte)SystemLogTypes.Error,
                    nameof(NominaOperacionController),
                    string.Empty,
                    string.Empty);

                return BadRequest(new PagedResult<NominaOperacionResponse>
                {
                    Success = false,
                    Code = "ERROR",
                    Message = UserFacingMessages.OperationFailed("obtener operaciones de nomina"),
                    TotalCount = 0
                });
            }
        }

        [HttpPost("{id:int}/vacaciones/enviar-autorizar")]
        public async Task<ActionResult<PagedResult<NominaOperacionResponse>>> EnviarVacacionAAutorizar(int id)
        {
            var result = await _appService.EnviarVacacionAAutorizarAsync(id, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:int}/vacaciones/autorizar")]
        public async Task<ActionResult<PagedResult<NominaOperacionResponse>>> AutorizarVacacion(int id)
        {
            var result = await _appService.AutorizarVacacionAsync(id, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }
    }
}
