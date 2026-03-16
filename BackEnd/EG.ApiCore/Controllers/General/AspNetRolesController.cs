using EG.Application.Interfaces.General;
using EG.Domain.DTOs.Responses.General;
using EG.ApiCore.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using EG.Common.GenericModel;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class AspNetRolesController : ControllerBase
    {
        private readonly IAspNetRolesAppService _appService;
        private readonly IUserContextService _userContext;

        public AspNetRolesController(
            IAspNetRolesAppService appService,
            IUserContextService userContext)
        {
            _appService = appService ?? throw new ArgumentNullException(nameof(appService));
            _userContext = userContext ?? throw new ArgumentNullException(nameof(userContext));
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<AspNetRoleResponse>>> GetAll()
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
        public async Task<ActionResult<AspNetRoleResponse>> GetById(int id)
        {
            try
            {
                var result = await _appService.GetByIdAsync(id.ToString());
                return Ok(new { success = true, data = result });
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

        //[HttpPost("GetAllPaginado")]
        //public async Task<ActionResult<PagedResult<AspNetRoleResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        //{
        //    try
        //    {
        //        var result = await _appService.Get(request);
        //        return Ok(result);
        //    }
        //    catch (Exception ex)
        //    {
        //        return StatusCode(500, new { success = false, message = ex.Message });
        //    }
        //}

        [HttpPost]
        public async Task<ActionResult<AspNetRoleResponse>> Create([FromBody] AspNetRoleResponse dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(dto, usuarioActual);
                return CreatedAtAction(nameof(GetById), new { id = result }, new { success = true, data = result });
            }
            catch (ArgumentNullException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { success = false, message = ex.Message });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<AspNetRoleResponse>> Update(int id, [FromBody] AspNetRoleResponse dto)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id.ToString(), dto, usuarioActual);
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

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                await _appService.DeleteAsync(id.ToString());
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