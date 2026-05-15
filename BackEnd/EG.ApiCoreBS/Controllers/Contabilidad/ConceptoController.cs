using Mapster;
using EG.Application.Interfaces.Contabilidad;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Contabilidad
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ConceptoController : EG.ApiCoreBS.Controllers.BaseApiController
    {
        private readonly IConceptoService _service;

        public ConceptoController(
            IConceptoService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<ConceptoResponse>
                {
                    Success = false,
                    Message = "Concepto no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<ConceptoResponse>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ConceptoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> Create([FromBody] ConceptoResponse response)
        {
            try
            {
                var created = await _service.CreateAsync(response, GetCurrentUserId());
                return CreatedAtAction(nameof(GetById), new { id = created?.PkidConcepto },
                    new PagedResult<ConceptoResponse>
                    {
                        Success = true,
                        Message = "Concepto creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<ConceptoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ConceptoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> Update(int id, [FromBody] ConceptoResponse response)
        {
            try
            {
                var updated = await _service.UpdateAsync(id, response, GetCurrentUserId());
                if (updated == null)
                    return NotFound(new PagedResult<ConceptoResponse>
                    {
                        Success = false,
                        Message = $"Concepto con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<ConceptoResponse>
                {
                    Success = true,
                    Message = "Concepto actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<ConceptoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ConceptoResponse>
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
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Concepto eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = ex.Message,
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
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<ConceptoResponse>>> Buscar([FromBody] BusquedaRequest request)
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
    }
}
