using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DepartamentoController : ControllerBase
    {
        private readonly IDepartamentoAppService _appService;
        private readonly IUserContextService _userContext;

        public DepartamentoController(
            IDepartamentoAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetById(int id)
        {
            try
            {
                var result = await _appService.GetByIdAsync(id);
                return Ok(new PagedResult<DepartamentoResponse>
                {
                    Success = true,
                    Message = "Departamento encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<DepartamentoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<DepartamentoResponse>
                {
                    Success = false,
                    Message = "Departamento no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
        }

        [HttpGet("empresa/{empresaId}")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetByEmpresaId(int empresaId)
        {
            var result = await _appService.GetAllByEmpresaAsync(empresaId);
            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> Create([FromBody] DepartamentoResponse response)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(response, usuarioActual);
                return CreatedAtAction(nameof(GetById), new { id = result.PkidDepartamento }, result);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<DepartamentoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE_DEPARTMENT",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<DepartamentoResponse>
                {
                    Success = false,
                    Message = $"Error al crear departamento: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> Update(int id, [FromBody] DepartamentoResponse response)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, response, usuarioActual);
                return Ok(result);
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<DepartamentoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE_DEPARTMENT",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<DepartamentoResponse>
                {
                    Success = false,
                    Message = $"Departamento con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<DepartamentoResponse>
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
                    Message = "Departamento eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Departamento con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
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

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var result = await _appService.BuscarAsync(request);
            return Ok(result);
        }
    }
}
