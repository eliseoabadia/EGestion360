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
    public class TipoRecursoController : ControllerBase
    {
        private readonly ITipoRecursoAppServices _appService;
        private readonly IUserContextService _userContext;

        public TipoRecursoController(
            ITipoRecursoAppServices appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoRecursoResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(new PagedResult<TipoRecursoResponse>
            {
                Success = true,
                Message = "Tipos de Recurso obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoRecursoResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<TipoRecursoResponse>
                {
                    Success = false,
                    Message = "Tipo de Recurso no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<TipoRecursoResponse>
            {
                Success = true,
                Message = "Tipo de Recurso encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<TipoRecursoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoRecursoResponse>>> Create([FromBody] TipoRecursoResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(response, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidTipoRecurso },
                    new PagedResult<TipoRecursoResponse>
                    {
                        Success = true,
                        Message = "Tipo de Recurso creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<TipoRecursoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoRecursoResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoRecursoResponse>>> Update(int id, [FromBody] TipoRecursoResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, response, usuarioActual);

                return Ok(new PagedResult<TipoRecursoResponse>
                {
                    Success = true,
                    Message = "Tipo de Recurso actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<TipoRecursoResponse>
                {
                    Success = false,
                    Message = $"Tipo de Recurso con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<TipoRecursoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoRecursoResponse>
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
                    Message = "Tipo de Recurso eliminado correctamente",
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
                    Message = $"Tipo de Recurso con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<TipoRecursoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<TipoRecursoResponse>
            {
                Success = true,
                Message = "Tipos de Recurso obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<TipoRecursoResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<TipoRecursoResponse>
            {
                Success = true,
                Message = "Tipos de Recurso filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
