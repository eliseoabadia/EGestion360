using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Modules.Nomina.RH
{
    [ApiController]
    [Authorize]
    [Route("api/NomRhEmpleado")]
    public class NominaRhEmpleadoController(
        INominaRhEmpleadoAppService appService,
        IUserContextService userContext) : ControllerBase
    {
        private readonly INominaRhEmpleadoAppService _appService = appService;
        private readonly IUserContextService _userContext = userContext;
        private readonly Logger.Log4NetLogger _logger = new(typeof(NominaRhEmpleadoController));

        [HttpGet]
        public async Task<ActionResult<PagedResult<NominaRhEmpleadoResponse>>> GetAll()
        {
            try
            {
                return Ok(await _appService.GetAllAsync(null));
            }
            catch (Exception ex)
            {
                LogException("obtener empleados", ex);
                return BadRequest(Failure<NominaRhEmpleadoResponse>(UserFacingMessages.OperationFailed("obtener empleados")));
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<NominaRhEmpleadoResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
            {
                return NotFound(result);
            }

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<NominaRhEmpleadoResponse>>> Create([FromBody] NominaRhEmpleadoResponse response)
        {
            try
            {
                var result = await _appService.CreateAsync(
                    response,
                    _userContext.GetCurrentUserId(),
                    null);

                return result.Success ? Ok(result) : BadRequest(result);
            }
            catch (Exception ex)
            {
                LogException("crear empleado", ex);
                return BadRequest(Failure<NominaRhEmpleadoResponse>(UserFacingMessages.OperationFailed("crear empleado")));
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<NominaRhEmpleadoResponse>>> Update(int id, [FromBody] NominaRhEmpleadoResponse response)
        {
            try
            {
                var result = await _appService.UpdateAsync(
                    id,
                    response,
                    _userContext.GetCurrentUserId(),
                    null);

                if (!result.Success && result.Code == "NOT_FOUND")
                {
                    return NotFound(result);
                }

                return result.Success ? Ok(result) : BadRequest(result);
            }
            catch (Exception ex)
            {
                LogException("actualizar empleado", ex);
                return BadRequest(Failure<NominaRhEmpleadoResponse>(UserFacingMessages.OperationFailed("actualizar empleado")));
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var result = await _appService.DeleteAsync(id, _userContext.GetCurrentUserId());
                if (!result.Success && result.Code == "NOT_FOUND")
                {
                    return NotFound(result);
                }

                return result.Success ? Ok(result) : BadRequest(result);
            }
            catch (Exception ex)
            {
                LogException("eliminar empleado", ex);
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Code = "ERROR",
                    Message = UserFacingMessages.OperationFailed("eliminar empleado"),
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<NominaRhEmpleadoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                return Ok(await _appService.GetAllPaginadoAsync(request, null));
            }
            catch (Exception ex)
            {
                LogException("obtener empleados paginados", ex);
                return BadRequest(Failure<NominaRhEmpleadoResponse>(UserFacingMessages.OperationFailed("obtener empleados")));
            }
        }

        private PagedResult<T> Failure<T>(string message) => new()
        {
            Success = false,
            Code = "ERROR",
            Message = message,
            TotalCount = 0
        };

        private void LogException(string operation, Exception ex)
        {
            _logger.LogMessage(
                LogLevelGRP.Error,
                $"Error al {operation} RH nomina: {ex}",
                (byte)SystemLogTypes.Error,
                nameof(NominaRhEmpleadoController),
                string.Empty,
                string.Empty);
        }
    }

    [ApiController]
    [Authorize]
    [Route("api/NomRhEmpleadoDetalle")]
    public class NominaRhEmpleadoDetalleController(
        INominaRhEmpleadoDetalleAppService appService,
        IUserContextService userContext) : ControllerBase
    {
        private readonly INominaRhEmpleadoDetalleAppService _appService = appService;
        private readonly IUserContextService _userContext = userContext;
        private readonly Logger.Log4NetLogger _logger = new(typeof(NominaRhEmpleadoDetalleController));

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<NominaRhEmpleadoDetalleResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                return Ok(await _appService.GetAllPaginadoAsync(request, null));
            }
            catch (Exception ex)
            {
                _logger.LogMessage(
                    LogLevelGRP.Error,
                    $"Error al obtener detalle RH nomina: {ex}",
                    (byte)SystemLogTypes.Error,
                    nameof(NominaRhEmpleadoDetalleController),
                    string.Empty,
                    string.Empty);

                return BadRequest(new PagedResult<NominaRhEmpleadoDetalleResponse>
                {
                    Success = false,
                    Code = "ERROR",
                    Message = UserFacingMessages.OperationFailed("obtener detalle de empleado"),
                    TotalCount = 0
                });
            }
        }
    }
}
