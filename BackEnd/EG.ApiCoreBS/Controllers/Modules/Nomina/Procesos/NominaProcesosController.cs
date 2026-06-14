using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Modules.Nomina.Procesos
{
    [Route("api/NomProcesos")]
    [ApiController]
    [Authorize]
    public class NominaProcesosController : ControllerBase
    {
        private readonly INominaProcesoAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly Logger.Log4NetLogger _logger = new(typeof(NominaProcesosController));

        public NominaProcesosController(
            INominaProcesoAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpPost("calcular-nomina")]
        public Task<ActionResult<PagedResult<NominaProcesoResponse>>> CalcularNomina([FromBody] NominaProcesoRequest request)
            => ExecuteAsync(request, _appService.CalcularNominaAsync);

        [HttpPost("cerrar-periodo")]
        public Task<ActionResult<PagedResult<NominaProcesoResponse>>> CerrarPeriodo([FromBody] NominaProcesoRequest request)
            => ExecuteAsync(request, _appService.CerrarPeriodoAsync);

        [HttpPost("calcular-aguinaldo")]
        public Task<ActionResult<PagedResult<NominaProcesoResponse>>> CalcularAguinaldo([FromBody] NominaProcesoRequest request)
            => ExecuteAsync(request, _appService.CalcularAguinaldoAsync);

        [HttpPost("prima-vacacional-individual")]
        public Task<ActionResult<PagedResult<NominaProcesoResponse>>> CalcularPrimaVacacionalIndividual([FromBody] NominaProcesoRequest request)
            => ExecuteAsync(request, _appService.CalcularPrimaVacacionalIndividualAsync);

        [HttpPost("crear-comprometido")]
        public Task<ActionResult<PagedResult<NominaProcesoResponse>>> CrearComprometido([FromBody] NominaProcesoRequest request)
            => ExecuteAsync(request, _appService.CrearComprometidoNominaAsync);

        [HttpPost("crear-devengado")]
        public Task<ActionResult<PagedResult<NominaProcesoResponse>>> CrearDevengado([FromBody] NominaProcesoRequest request)
            => ExecuteAsync(request, _appService.CrearDevengadoNominaAsync);

        [HttpPost("crear-ejercido")]
        public Task<ActionResult<PagedResult<NominaProcesoResponse>>> CrearEjercido([FromBody] NominaProcesoRequest request)
            => ExecuteAsync(request, _appService.CrearEjercidoNominaAsync);

        private async Task<ActionResult<PagedResult<NominaProcesoResponse>>> ExecuteAsync(
            NominaProcesoRequest request,
            Func<NominaProcesoRequest, int, Task<PagedResult<NominaProcesoResponse>>> action)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await action(request, usuarioActual);
                return result.Success ? Ok(result) : BadRequest(result);
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error al ejecutar proceso de Nomina: {ex}",
                    (byte)SystemLogTypes.Error,
                    nameof(NominaProcesosController),
                    string.Empty,
                    string.Empty);

                return BadRequest(new PagedResult<NominaProcesoResponse>
                {
                    Success = false,
                    Message = UserFacingMessages.OperationFailed("ejecutar proceso de nomina"),
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}
