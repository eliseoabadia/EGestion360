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
    public class ConteoController : ControllerBase
    {
        private readonly IConteoAppService _appService;
        private readonly IUserContextService _userContext;

        public ConteoController(IConteoAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ConteoResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ConteoResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<ConteoResponse>
                {
                    Success = false,
                    Message = "Conteo no encontrado",
                    Code = "NOT_FOUND"
                });
            }

            return Ok(new PagedResult<ConteoResponse>
            {
                Success = true,
                Message = "Conteo encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ConteoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<ConteoResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            var result = await _appService.GetAllPaginadoAsync(pageRequest);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ConteoResponse>>> Create([FromBody] ConteoResponse response)
        {
            try
            {
                var dto = new ConteoDto
                {
                    FkidTipoBienAlma = response.IdTipoBien ?? 0,
                    FkidPeriodoConteoAlma = response.IdPeriodoConteo,
                    CantidadInventario = response.CantidadInventario,
                    Descripcion = response.Descripcion,
                    FechaInicio = response.FechaInicio,
                    FechaFin = response.FechaFin,
                    Activo = response.Activo
                };
                var result = await _appService.CreateAsync(dto, _userContext.GetCurrentUserId());
                return CreatedAtAction(nameof(GetById), new { id = result.PkidConteo },
                    new PagedResult<ConteoResponse>
                    {
                        Success = true,
                        Message = "Conteo creado correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        Items = new List<ConteoResponse> { result },
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ConteoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ConteoResponse>>> Update(int id, [FromBody] ConteoResponse response)
        {
            try
            {
                var dto = new ConteoDto
                {
                    FkidTipoBienAlma = response.IdTipoBien ?? 0,
                    FkidPeriodoConteoAlma = response.IdPeriodoConteo,
                    CantidadInventario = response.CantidadInventario,
                    Descripcion = response.Descripcion,
                    FechaInicio = response.FechaInicio,
                    FechaFin = response.FechaFin,
                    Activo = response.Activo
                };
                var result = await _appService.UpdateAsync(id, dto, _userContext.GetCurrentUserId());
                return Ok(new PagedResult<ConteoResponse>
                {
                    Success = true,
                    Message = "Conteo actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<ConteoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ConteoResponse>
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
                    Message = "Conteo eliminado correctamente",
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
