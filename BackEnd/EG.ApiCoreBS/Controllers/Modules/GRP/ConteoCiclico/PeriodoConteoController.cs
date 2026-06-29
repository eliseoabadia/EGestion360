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
    }
}
