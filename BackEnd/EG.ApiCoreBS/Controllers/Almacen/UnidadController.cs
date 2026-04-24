using EG.Application.Interfaces.Almacen;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Almacen
{
    [ApiController]
    [Route("api/[controller]")]
    public class UnidadController : ControllerBase
    {
        private readonly IUnidadAppService _appService;

        public UnidadController(IUnidadAppService appService)
        {
            _appService = appService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<UnidadResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<UnidadResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<UnidadResponse>
                {
                    Success = false,
                    Message = "Unidad no encontrada",
                    Code = "NOT_FOUND"
                });
            }

            return Ok(new PagedResult<UnidadResponse>
            {
                Success = true,
                Message = "Unidad encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<UnidadResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<UnidadResponse>>> Create([FromBody] UnidadResponse response)
        {
            try
            {
                var dto = new UnidadDto
                {
                    Descripcion = response.Descripcion,
                    Activo = response.Activo
                };
                var result = await _appService.CreateAsync(dto, response.UsuarioCreacion);
                return CreatedAtAction(nameof(GetById), new { id = result.PkidUnidades },
                    new PagedResult<UnidadResponse>
                    {
                        Success = true,
                        Message = "Unidad creada correctamente",
                        Code = "SUCCESS",
                        Data = result,
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UnidadResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<UnidadResponse>>> Update(int id, [FromBody] UnidadResponse response)
        {
            try
            {
                var dto = new UnidadDto
                {
                    Descripcion = response.Descripcion,
                    Activo = response.Activo
                };
                var result = await _appService.UpdateAsync(id, dto, response.UsuarioModificacion ?? 0);
                return Ok(new PagedResult<UnidadResponse>
                {
                    Success = true,
                    Message = "Unidad actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UnidadResponse>
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
                    Message = "Unidad eliminada correctamente",
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

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<UnidadResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(pageRequest);
                return Ok(new PagedResult<UnidadResponse>
                {
                    Success = true,
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UnidadResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }
    }
}