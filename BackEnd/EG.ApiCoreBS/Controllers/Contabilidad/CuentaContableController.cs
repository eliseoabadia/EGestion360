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
    public class CuentaContableController : EG.ApiCoreBS.Controllers.BaseApiController
    {
        private readonly ICuentaContableService _service;

        public CuentaContableController(
            ICuentaContableService service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<CuentaContableResponse>
            {
                Success = true,
                Message = "Cuentas contables obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<CuentaContableResponse>
                {
                    Success = false,
                    Message = "Cuenta contable no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<CuentaContableResponse>
            {
                Success = true,
                Message = "Cuenta contable encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<CuentaContableResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> Create([FromBody] CuentaContableResponse response)
        {
            try
            {
                var created = await _service.CreateAsync(response, GetCurrentUserId());
                return CreatedAtAction(nameof(GetById), new { id = created?.PkidCuentaContable },
                    new PagedResult<CuentaContableResponse>
                    {
                        Success = true,
                        Message = "Cuenta contable creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<CuentaContableResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<CuentaContableResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> Update(int id, [FromBody] CuentaContableResponse response)
        {
            try
            {
                var updated = await _service.UpdateAsync(id, response, GetCurrentUserId());
                if (updated == null)
                    return NotFound(new PagedResult<CuentaContableResponse>
                    {
                        Success = false,
                        Message = $"Cuenta contable con ID {id} no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<CuentaContableResponse>
                {
                    Success = true,
                    Message = "Cuenta contable actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<CuentaContableResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<CuentaContableResponse>
                {
                    Success = false,
                    Message = $"Cuenta contable con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<CuentaContableResponse>
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
                    Message = "Cuenta contable eliminada correctamente",
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
                    Message = $"Cuenta contable con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<CuentaContableResponse>
            {
                Success = true,
                Message = "Cuentas contables obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> Buscar([FromBody] BusquedaRequest request)
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

            return Ok(new PagedResult<CuentaContableResponse>
            {
                Success = true,
                Message = "Cuentas contables filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpGet("GetLookup")]
        public async Task<ActionResult<List<LookupItem>>> GetLookup()
        {
            var items = await _service.GetLookupAsync();
            return Ok(items);
        }

        [HttpGet("GetLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            return Ok(await _service.GetLookupPaginadoAsync(page, pageSize, filter));
        }
    }
}
