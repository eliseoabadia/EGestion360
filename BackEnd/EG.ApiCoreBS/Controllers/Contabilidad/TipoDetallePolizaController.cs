using AutoMapper;
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
    public class TipoDetallePolizaController : ControllerBase
    {
        private readonly ITipoDetallePolizaService _service;
        private readonly IMapper _mapper;

        public TipoDetallePolizaController(
            ITipoDetallePolizaService service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoDetallePolizaResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<TipoDetallePolizaResponse>
            {
                Success = true,
                Message = "Tipos de detalle de pÃ³liza obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoDetallePolizaResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<TipoDetallePolizaResponse>
                {
                    Success = false,
                    Message = "Tipo de detalle de pÃ³liza no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<TipoDetallePolizaResponse>
            {
                Success = true,
                Message = "Tipo de detalle de pÃ³liza encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<TipoDetallePolizaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoDetallePolizaResponse>>> Create([FromBody] TipoDetallePolizaResponse response)
        {
            try
            {
                var created = await _service.CreateAsync(response, GetCurrentUserId());
                return CreatedAtAction(nameof(GetById), new { id = created?.PkidTipoDetallePoliza },
                    new PagedResult<TipoDetallePolizaResponse>
                    {
                        Success = true,
                        Message = "Tipo de detalle de pÃ³liza creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<TipoDetallePolizaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoDetallePolizaResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoDetallePolizaResponse>>> Update(int id, [FromBody] TipoDetallePolizaResponse response)
        {
            try
            {
                var updated = await _service.UpdateAsync(id, response, GetCurrentUserId());
                if (updated == null)
                    return NotFound(new PagedResult<TipoDetallePolizaResponse>
                    {
                        Success = false,
                        Message = $"Tipo de detalle de pÃ³liza con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<TipoDetallePolizaResponse>
                {
                    Success = true,
                    Message = "Tipo de detalle de pÃ³liza actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<TipoDetallePolizaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<TipoDetallePolizaResponse>
                {
                    Success = false,
                    Message = $"Tipo de detalle de pÃ³liza con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoDetallePolizaResponse>
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
                    Message = "Tipo de detalle de pÃ³liza eliminado correctamente",
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
                    Message = $"Tipo de detalle de pÃ³liza con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<TipoDetallePolizaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<TipoDetallePolizaResponse>
            {
                Success = true,
                Message = "Tipos de detalle de pÃ³liza obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<TipoDetallePolizaResponse>>> Buscar([FromBody] BusquedaRequest request)
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

            return Ok(new PagedResult<TipoDetallePolizaResponse>
            {
                Success = true,
                Message = "Tipos de detalle de pÃ³liza filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        private int GetCurrentUserId()
        {
            var claim = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier);
            return claim != null ? int.Parse(claim.Value) : 0;
        }
    }
}
