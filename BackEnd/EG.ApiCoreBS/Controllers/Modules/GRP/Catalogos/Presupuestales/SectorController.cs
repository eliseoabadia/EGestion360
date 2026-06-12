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
    public class SectorController : ControllerBase
    {
        private readonly ISectorAppServices _appService;
        private readonly IUserContextService _userContext;

        public SectorController(
            ISectorAppServices appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<SectorResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(new PagedResult<SectorResponse>
            {
                Success = true,
                Message = "Sectores obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<SectorResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<SectorResponse>
                {
                    Success = false,
                    Message = "Sector no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<SectorResponse>
            {
                Success = true,
                Message = "Sector encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<SectorResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<SectorResponse>>> Create([FromBody] SectorResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(response, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidSector },
                    new PagedResult<SectorResponse>
                    {
                        Success = true,
                        Message = "Sector creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<SectorResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SectorResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<SectorResponse>>> Update(int id, [FromBody] SectorResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, response, usuarioActual);

                return Ok(new PagedResult<SectorResponse>
                {
                    Success = true,
                    Message = "Sector actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<SectorResponse>
                {
                    Success = false,
                    Message = $"Sector con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<SectorResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SectorResponse>
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
                    Message = "Sector eliminado correctamente",
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
                    Message = $"Sector con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<SectorResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<SectorResponse>
            {
                Success = true,
                Message = "Sectores obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<SectorResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<SectorResponse>
            {
                Success = true,
                Message = "Sectores filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
