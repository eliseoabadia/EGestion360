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
    public class ActividadInstitucionalController : ControllerBase
    {
        private readonly IActividadInstitucionalAppServices _appService;
        private readonly IUserContextService _userContext;

        public ActividadInstitucionalController(
            IActividadInstitucionalAppServices appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(new PagedResult<ActividadInstitucionalResponse>
            {
                Success = true,
                Message = "Actividades Institucionales obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = false,
                    Message = "Actividad Institucional no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<ActividadInstitucionalResponse>
            {
                Success = true,
                Message = "Actividad Institucional encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ActividadInstitucionalResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> Create([FromBody] ActividadInstitucionalResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(response, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidActividadInstitucional },
                    new PagedResult<ActividadInstitucionalResponse>
                    {
                        Success = true,
                        Message = "Actividad Institucional creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> Update(int id, [FromBody] ActividadInstitucionalResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, response, usuarioActual);

                return Ok(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = true,
                    Message = "Actividad Institucional actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = false,
                    Message = $"Actividad Institucional con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<ActividadInstitucionalResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ActividadInstitucionalResponse>
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
                    Message = "Actividad Institucional eliminada correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Actividad Institucional con ID {id} no encontrada",
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
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<ActividadInstitucionalResponse>
            {
                Success = true,
                Message = "Actividades Institucionales obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<ActividadInstitucionalResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<ActividadInstitucionalResponse>
            {
                Success = true,
                Message = "Actividades Institucionales filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
