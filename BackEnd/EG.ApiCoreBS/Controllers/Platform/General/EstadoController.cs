using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EstadoController : ControllerBase
    {
        private readonly IEstadoAppService _appService;
        private readonly IUserContextService _userContext;

        public EstadoController(IEstadoAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<EstadoResponse>
                {
                    Success = false,
                    Message = "Estado no encontrado",
                    Code = "NOTFOUND_ESTADO",
                    TotalCount = 0
                });

            return Ok(new PagedResult<EstadoResponse>
            {
                Success = true,
                Message = "Estado encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<EstadoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> Create([FromBody] EstadoResponse response)
        {
            try
            {
                var dto = new EstadoDto
                {
                    FkidPaisSis = response.FkidPaisSis,
                    Nombre = response.Nombre,
                    CodigoEstado = response.CodigoEstado,
                    Activo = response.Activo
                };
                var result = await _appService.CreateAsync(dto, _userContext.GetCurrentUserId());
                return CreatedAtAction(nameof(GetById), new { id = result.PkidEstado },
                    new PagedResult<EstadoResponse>
                    {
                        Success = true,
                        Message = "Estado creado correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        Items = new List<EstadoResponse> { result },
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstadoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EstadoResponse>>> Update(int id, [FromBody] EstadoResponse response)
        {
            try
            {
                var dto = new EstadoDto
                {
                    FkidPaisSis = response.FkidPaisSis,
                    Nombre = response.Nombre,
                    CodigoEstado = response.CodigoEstado,
                    Activo = response.Activo
                };
                var result = await _appService.UpdateAsync(id, dto, _userContext.GetCurrentUserId());
                return Ok(new PagedResult<EstadoResponse>
                {
                    Success = true,
                    Message = "Estado actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<EstadoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstadoResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
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
                    Message = "Estado eliminado correctamente",
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
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}
