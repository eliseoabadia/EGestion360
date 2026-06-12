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
    public class UnidadResponsableController : ControllerBase
    {
        private readonly IUnidadResponsableAppServices _appService;
        private readonly IUserContextService _userContext;

        public UnidadResponsableController(
            IUnidadResponsableAppServices appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            var lista = result.ToList();
            return Ok(new PagedResult<UnidadResponsableResponse>
            {
                Items = lista,
                TotalCount = lista.Count,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = "Unidad Responsable no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<UnidadResponsableResponse>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Data = result,
                Items = new List<UnidadResponsableResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> Create([FromBody] UnidadResponsableResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(response, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidUnidadResponsable },
                    new PagedResult<UnidadResponsableResponse>
                    {
                        Success = true,
                        Message = "Unidad Responsable creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> Update(int id, [FromBody] UnidadResponsableResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, response, usuarioActual);

                return Ok(new PagedResult<UnidadResponsableResponse>
                {
                    Success = true,
                    Message = "Unidad Responsable actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = $"Unidad Responsable con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UnidadResponsableResponse>
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

                if (!result)
                    return NotFound(new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Unidad Responsable con ID {id} no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Unidad Responsable eliminada correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<bool> { result },
                    TotalCount = 1
                });
            }
            catch (InvalidOperationException ex)
            {
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "HAS_CHILDREN",
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
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);

            if (!result.Success)
                return Ok(result);

            return Ok(new PagedResult<UnidadResponsableResponse>
            {
                Items = result.Items,
                TotalCount = result.TotalCount,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<UnidadResponsableResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            return await GetAllPaginado(pagedRequest);
        }
    }
}
