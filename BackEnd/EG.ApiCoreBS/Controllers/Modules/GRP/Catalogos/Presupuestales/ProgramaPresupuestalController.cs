using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Common;
using EG.Common.Enums;
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
    public class ProgramaPresupuestalController : ControllerBase
    {
        private readonly IProgramaPresupuestalAppServices _appService;
        private readonly IUserContextService _userContext;
        private readonly Logger.Log4NetLogger _logger = new(typeof(ProgramaPresupuestalController));

        public ProgramaPresupuestalController(
            IProgramaPresupuestalAppServices appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(new PagedResult<ProgramaPresupuestalResponse>
            {
                Success = true,
                Message = "Programas Presupuestales obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = "Programa Presupuestal no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<ProgramaPresupuestalResponse>
            {
                Success = true,
                Message = "Programa Presupuestal encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ProgramaPresupuestalResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> Create([FromBody] ProgramaPresupuestalResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(response, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidPp },
                    new PagedResult<ProgramaPresupuestalResponse>
                    {
                        Success = true,
                        Message = "Programa Presupuestal creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                LogException("crear", ex);
                return BadRequest(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = UserFacingMessages.OperationFailed("crear programa presupuestal"),
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> Update(int id, [FromBody] ProgramaPresupuestalResponse response)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, response, usuarioActual);

                return Ok(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = true,
                    Message = "Programa Presupuestal actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = $"Programa Presupuestal con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                LogException("actualizar", ex);
                return BadRequest(new PagedResult<ProgramaPresupuestalResponse>
                {
                    Success = false,
                    Message = UserFacingMessages.OperationFailed("actualizar programa presupuestal"),
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
                    Message = "Programa Presupuestal eliminado correctamente",
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
                    Message = $"Programa Presupuestal con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                LogException("eliminar", ex);
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = UserFacingMessages.OperationFailed("eliminar programa presupuestal"),
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<ProgramaPresupuestalResponse>
            {
                Success = result.Success,
                Message = result.Message,
                Code = result.Code,
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<ProgramaPresupuestalResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<ProgramaPresupuestalResponse>
            {
                Success = result.Success,
                Message = result.Message,
                Code = result.Code,
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        private void LogException(string operation, Exception ex)
        {
            _logger.LogMessage(
                LogLevelGRP.Error,
                $"Error al {operation} Programa Presupuestal: {ex}",
                (byte)SystemLogTypes.Error,
                nameof(ProgramaPresupuestalController),
                string.Empty,
                string.Empty);
        }
    }
}
