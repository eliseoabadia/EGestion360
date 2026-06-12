using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class RamoController : ControllerBase
    {
        private readonly IRamoAppServices _appService;
        private readonly IUserContextService _userContext;

        public RamoController(
            IRamoAppServices appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<RamoResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(new PagedResult<RamoResponse>
            {
                Success = true,
                Message = "Ramos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<RamoResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<RamoResponse>
                {
                    Success = false,
                    Message = "Ramo no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<RamoResponse>
            {
                Success = true,
                Message = "Ramo encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<RamoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<RamoResponse>>> Create([FromBody] RamoResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(response, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidRamo },
                    new PagedResult<RamoResponse>
                    {
                        Success = true,
                        Message = "Ramo creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<RamoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<RamoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<RamoResponse>>> Update(int id, [FromBody] RamoResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, response, usuarioActual);

                return Ok(new PagedResult<RamoResponse>
                {
                    Success = true,
                    Message = "Ramo actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<RamoResponse>
                {
                    Success = false,
                    Message = $"Ramo con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<RamoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<RamoResponse>
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
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.DeleteAsync(id, usuarioActual);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Ramo eliminado correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<bool> { result },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Ramo con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<RamoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<RamoResponse>
            {
                Success = true,
                Message = "Ramos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<RamoResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _appService.GetAllPaginadoAsync(pagedRequest);
            return Ok(new PagedResult<RamoResponse>
            {
                Success = true,
                Message = "Ramos filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
