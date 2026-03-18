using EG.Application.Interfaces.Almacen;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Almacen
{
    [ApiController]
    [Route("api/[controller]")]
    public class TipoBienController : ControllerBase
    {
        private readonly ITipoBienAppService _tipoBienAppService;

        public TipoBienController(ITipoBienAppService tipoBienAppService)
        {
            _tipoBienAppService = tipoBienAppService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetAll()
        {
            var result = await _tipoBienAppService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetById(int id)
        {
            try
            {
                var result = await _tipoBienAppService.GetByIdAsync(id);
                return Ok(new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoBienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _tipoBienAppService.GetAllPaginadoAsync(pageRequest);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> Create([FromBody] TipoBienDto dto, [FromQuery] int usuarioActual)
        {
            try
            {
                var result = await _tipoBienAppService.CreateAsync(dto, usuarioActual);
                return CreatedAtAction(nameof(GetById), new { id = result.PkidTipoBien }, new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien creado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoBienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> Update(int id, [FromBody] TipoBienDto dto, [FromQuery] int usuarioActual)
        {
            try
            {
                var result = await _tipoBienAppService.UpdateAsync(id, dto, usuarioActual);
                return Ok(new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoBienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                await _tipoBienAppService.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Tipo de bien eliminado correctamente",
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
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }
    }
}