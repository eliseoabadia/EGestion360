using EG.Application.Interfaces.ConteoCiclico;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.ConteoCiclico
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PeriodoConteoController : ControllerBase
    {
        private readonly IPeriodoConteoAppService _appService;
        private readonly IUserContextService _userContext;

        public PeriodoConteoController(IPeriodoConteoAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = "Período de conteo no encontrado",
                    Code = "NOT_FOUND"
                });
            }

            return Ok(new PagedResult<PeriodoConteoResponse>
            {
                Success = true,
                Message = "Período de conteo encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<PeriodoConteoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(pageRequest);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> Create([FromBody] PeriodoConteoResponse response)
        {
            try
            {
                var dto = new PeriodoConteoDto
                {
                    FkidSucursalSis = response.IdSucursal ?? 0,
                    FkidTipoConteoAlma = response.IdTipoConteo ?? 0,
                    FkidEstatusAlma = response.IdEstatusPeriodo ?? 0,
                    CodigoPeriodo = response.CodigoPeriodo,
                    Nombre = response.Nombre,
                    Descripcion = response.Descripcion,
                    FechaInicio = response.FechaInicio,
                    FechaFin = response.FechaFin,
                    MaximoConteosPorArticulo = response.MaximoConteosPorArticulo,
                    RequiereAprobacionSupervisor = response.RequiereAprobacionSupervisor,
                    FkidResponsableSis = response.IdResponsable,
                    FkidSupervisorSis = response.IdSupervisor,
                    Activo = response.Activo
                };
                var result = await _appService.CreateAsync(dto, _userContext.GetCurrentUserId());
                return CreatedAtAction(nameof(GetById), new { id = result.PkidPeriodoConteo },
                    new PagedResult<PeriodoConteoResponse>
                    {
                        Success = true,
                        Message = "Período de conteo creado correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        Items = new List<PeriodoConteoResponse> { result },
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> Update(int id, [FromBody] PeriodoConteoResponse response)
        {
            try
            {
                var dto = new PeriodoConteoDto
                {
                    FkidSucursalSis = response.IdSucursal ?? 0,
                    FkidTipoConteoAlma = response.IdTipoConteo ?? 0,
                    FkidEstatusAlma = response.IdEstatusPeriodo ?? 0,
                    CodigoPeriodo = response.CodigoPeriodo,
                    Nombre = response.Nombre,
                    Descripcion = response.Descripcion,
                    FechaInicio = response.FechaInicio,
                    FechaFin = response.FechaFin,
                    MaximoConteosPorArticulo = response.MaximoConteosPorArticulo,
                    RequiereAprobacionSupervisor = response.RequiereAprobacionSupervisor,
                    FkidResponsableSis = response.IdResponsable,
                    FkidSupervisorSis = response.IdSupervisor,
                    Activo = response.Activo
                };
                var result = await _appService.UpdateAsync(id, dto, _userContext.GetCurrentUserId());
                return Ok(new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = "Período de conteo actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<PeriodoConteoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                await _appService.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Período de conteo eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpPost("IniciarConteo/{id}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> IniciarConteo(int id)
            => await ExecuteTransitionAsync(id, _appService.IniciarAsync, "Periodo iniciado correctamente");

        [HttpPost("CompletarConteo/{id}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> CompletarConteo(int id)
            => await ExecuteTransitionAsync(id, _appService.CompletarAsync, "Periodo completado correctamente");

        [HttpPost("CerrarConteo/{id}")]
        public async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> CerrarConteo(int id)
            => await ExecuteTransitionAsync(id, _appService.CerrarAsync, "Periodo cerrado correctamente");

        [HttpGet("Planificacion")]
        public async Task<ActionResult<PagedResult<ConteoPlanificacionResponse>>> GetPlanificacion()
        {
            try
            {
                var items = await _appService.GetPlanificacionAsync();
                return Ok(PlanResult(items, "Planificacion obtenida correctamente"));
            }
            catch (Exception ex)
            {
                return BadRequest(PlanFailure(ex.Message));
            }
        }

        [HttpPost("ActualizarClasificacionABC")]
        public async Task<ActionResult<PagedResult<ConteoPlanificacionResponse>>> ActualizarClasificacionABC()
        {
            try
            {
                var items = await _appService.ActualizarClasificacionAbcAsync(_userContext.GetCurrentUserId());
                return Ok(PlanResult(items, $"Clasificacion ABC actualizada para {items.Count} articulos"));
            }
            catch (Exception ex)
            {
                return BadRequest(PlanFailure(ex.Message));
            }
        }

        [HttpPost("ActualizarPlan/{id}")]
        public async Task<ActionResult<PagedResult<ConteoPlanificacionResponse>>> ActualizarPlan(
            int id,
            [FromBody] ConteoPlanificacionUpdateRequest request)
        {
            try
            {
                var item = await _appService.ActualizarPlanAsync(id, request, _userContext.GetCurrentUserId());
                return Ok(PlanResult(new[] { item }, "Programacion del conteo actualizada correctamente"));
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(PlanFailure(ex.Message, "NOT_FOUND"));
            }
            catch (Exception ex) when (ex is ArgumentException or InvalidOperationException)
            {
                return BadRequest(PlanFailure(ex.Message, "INVALID_OPERATION"));
            }
        }

        [HttpPost("GenerarSugeridos/{id}")]
        public async Task<ActionResult<PagedResult<ConteoPlanificacionResponse>>> GenerarSugeridos(int id)
        {
            try
            {
                var generated = await _appService.GenerarConteosSugeridosAsync(id, _userContext.GetCurrentUserId());
                var message = generated == 0
                    ? "No hay articulos vencidos o bajo minimo pendientes de generar"
                    : $"Se generaron {generated} conteos por programacion ABC o umbral de existencia";
                return Ok(PlanResult(Array.Empty<ConteoPlanificacionResponse>(), message));
            }
            catch (Exception ex) when (ex is ArgumentException or InvalidOperationException)
            {
                return BadRequest(PlanFailure(ex.Message, "INVALID_OPERATION"));
            }
            catch (Exception ex)
            {
                return BadRequest(PlanFailure(ex.Message));
            }
        }

        private static PagedResult<ConteoPlanificacionResponse> PlanResult(
            IEnumerable<ConteoPlanificacionResponse> source,
            string message)
        {
            var items = source.ToList();
            return new PagedResult<ConteoPlanificacionResponse>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Data = items.FirstOrDefault(),
                Items = items,
                TotalCount = items.Count
            };
        }

        private static PagedResult<ConteoPlanificacionResponse> PlanFailure(string message, string code = "ERROR")
            => new()
            {
                Success = false,
                Message = message,
                Code = code,
                Items = new List<ConteoPlanificacionResponse>()
            };

        private async Task<ActionResult<PagedResult<PeriodoConteoResponse>>> ExecuteTransitionAsync(
            int id,
            Func<int, int, Task<PeriodoConteoResponse>> action,
            string successMessage)
        {
            try
            {
                var result = await action(id, _userContext.GetCurrentUserId());
                return Ok(new PagedResult<PeriodoConteoResponse>
                {
                    Success = true,
                    Message = successMessage,
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<PeriodoConteoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex) when (ex is ArgumentException or InvalidOperationException)
            {
                return BadRequest(new PagedResult<PeriodoConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "INVALID_OPERATION"
                });
            }
        }
    }
}
