using Mapster;
using EG.Application.Interfaces.Contabilidad;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Contabilidad
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class MatrizIngresoController : EG.ApiCoreBS.Controllers.BaseApiController
    {
        private readonly IMatrizIngresoService _service;

        public MatrizIngresoController(
            IMatrizIngresoService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> GetAll()
        {
            var items = await _service.GetAllAsync();
            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = $"No se encontrÃ³ el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<MatrizIngresoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Create([FromBody] MatrizIngresoResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = "Datos invÃ¡lidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var created = await _service.CreateAsync(request, GetCurrentUserId());

            return CreatedAtAction(nameof(GetById), new { id = created?.PkidMatrizIngreso },
                new PagedResult<MatrizIngresoResponse>
                {
                    Success = true,
                    Message = "Registro creado exitosamente",
                    Code = "SUCCESS",
                    Data = created,
                    TotalCount = 1
                });
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Update(int id, [FromBody] MatrizIngresoResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = "Datos invÃ¡lidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var updated = await _service.UpdateAsync(id, request, GetCurrentUserId());
            if (updated == null)
            {
                return NotFound(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = $"No se encontrÃ³ el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<MatrizIngresoResponse>
            {
                Success = true,
                Message = "Registro actualizado correctamente",
                Code = "SUCCESS",
                Data = updated,
                TotalCount = 1
            });
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<MatrizIngresoResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<MatrizIngresoResponse>
                {
                    Success = false,
                    Message = $"No se encontrÃ³ el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<MatrizIngresoResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _service.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }

        [HttpGet("GetPrograma")]
        public async Task<IActionResult> GetPrograma()
        {
            var programas = await _service.GetProgramasAsync();
            return Ok(programas);
        }

        [HttpGet("GetProgramaLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetProgramaLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _service.GetProgramaLookupPaginadoAsync(page, pageSize, filter));
        }

        [HttpGet("GetOrigen")]
        public async Task<IActionResult> GetOrigen()
        {
            var origenes = await _service.GetOrigenAsync();
            return Ok(origenes);
        }

        [HttpGet("GetOrigenLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetOrigenLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _service.GetOrigenLookupPaginadoAsync(page, pageSize, filter));
        }

        [HttpGet("GetCuentaContable")]
        public async Task<IActionResult> GetCuentaContable()
        {
            var cuentas = await _service.GetCuentaContableAsync();
            return Ok(cuentas);
        }

        [HttpGet("GetCuentaContableLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetCuentaContableLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _service.GetCuentaContableLookupPaginadoAsync(page, pageSize, filter));
        }
    }
}
