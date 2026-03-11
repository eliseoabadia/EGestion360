using EG.Application.Interfaces.General;
using EG.ApiCore.Services;
using EG.Domain.DTOs.Requests.General;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EmpresaController : ControllerBase
    {
        private readonly IEmpresaAppService _appService;
        private readonly IUserContextService _userContext;

        public EmpresaController(IEmpresaAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EmpresaResponse>> GetById(int id)
        {
            try
            {
                var result = await _appService.GetByIdAsync(id);
                return Ok(new { success = true, data = result });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPost]
        public async Task<ActionResult<EmpresaResponse>> Create([FromBody] EmpresaDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);
                return CreatedAtAction(nameof(GetById), new { id = result.PkidEmpresa }, new { success = true, data = result });
            }
            catch (ArgumentNullException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<EmpresaResponse>> Update(int id, [FromBody] EmpresaDto dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, dto, usuarioActual);
                return Ok(new { success = true, data = result });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                await _appService.DeleteAsync(id);
                return Ok(new { success = true, message = "Eliminado correctamente" });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }
    }
}