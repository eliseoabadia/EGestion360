using EG.Application.Interfaces.Almacen;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Almacen
{
    [ApiController]
    [Route("api/[controller]")]
    public class BienController : ControllerBase
    {
        private readonly IBienAppService _bienAppService;

        public BienController(IBienAppService bienAppService)
        {
            _bienAppService = bienAppService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAll()
        {
            var result = await _bienAppService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetById(int id)
        {
            try
            {
                var result = await _bienAppService.GetByIdAsync(id);
                return Ok(new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bien encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<BienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _bienAppService.GetAllPaginadoAsync(pageRequest);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<BienResponse>>> Create([FromBody] BienDto dto, [FromQuery] int usuarioActual)
        {
            try
            {
                var result = await _bienAppService.CreateAsync(dto, usuarioActual);
                return CreatedAtAction(nameof(GetById), new { id = result.PkidBien }, new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bien creado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<BienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<BienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> Update(int id, [FromBody] BienDto dto, [FromQuery] int usuarioActual)
        {
            try
            {
                var result = await _bienAppService.UpdateAsync(id, dto, usuarioActual);
                return Ok(new PagedResult<BienResponse>
                {
                    Success = true,
                    Message = "Bien actualizado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<BienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<BienResponse>
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
                await _bienAppService.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Bien eliminado correctamente",
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