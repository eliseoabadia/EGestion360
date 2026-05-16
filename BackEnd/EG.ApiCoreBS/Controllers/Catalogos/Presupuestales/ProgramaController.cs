using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ProgramaController : ControllerBase
    {
        private readonly IProgramaAppServices _appService;
        private readonly IUserContextService _userContext;

        public ProgramaController(
            IProgramaAppServices appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> GetAll()
        {
            try
            {
                var result = await _appService.GetAllAsync();
                var lista = result.ToList();
                return Ok(new PagedResult<ProgramaResponse>
                {
                    Success = true,
                    Message = "Programas obtenidos correctamente",
                    Code = ApiResponseCode.Success.ToCode(),
                    Items = lista,
                    TotalCount = lista.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> GetById(int id)
        {
            try
            {
                var programa = await _appService.GetByIdAsync(id);

                if (programa == null)
                {
                    return NotFound(Error("Programa no encontrado", ApiResponseCode.NotFound));
                }

                return Ok(Success("Programa encontrado", programa));
            }
            catch (Exception ex)
            {
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _appService.GetAllPaginadoAsync(pageRequest);
                return Ok(new PagedResult<ProgramaResponse>
                {
                    Success = true,
                    Message = "Programas obtenidos correctamente",
                    Code = ApiResponseCode.Success.ToCode(),
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> Create([FromBody] ProgramaResponse request)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(request, usuarioActual);

                return CreatedAtAction(nameof(GetById), new { id = result.PkidPrograma },
                    Success("Programa creado correctamente", result));
            }
            catch (ArgumentNullException ex)
            {
                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(Error(ex.Message, ApiResponseCode.MissingRequiredFields));
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(Error(ex.Message, ApiResponseCode.Duplicated));
            }
            catch (Exception ex)
            {
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> Update(int id, [FromBody] ProgramaResponse request)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, request, usuarioActual);

                return Ok(Success("Programa actualizado correctamente", result));
            }
            catch (ArgumentNullException ex)
            {
                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
            }
            catch (ArgumentException ex)
            {
                return BadRequest(Error(ex.Message, ApiResponseCode.MissingRequiredFields));
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(Error(ex.Message, ApiResponseCode.Duplicated));
            }
            catch (Exception ex)
            {
                return StatusCode(500, Error(ex.Message));
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<ProgramaResponse>>> Delete(int id)
        {
            try
            {
                int usuarioActual = _userContext.GetCurrentUserId();
                await _appService.DeleteAsync(id, usuarioActual);
                return Ok(new PagedResult<ProgramaResponse>
                {
                    Success = true,
                    Message = "Programa eliminado correctamente",
                    Code = ApiResponseCode.Success.ToCode(),
                    TotalCount = 0
                });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(Error(ex.Message, ApiResponseCode.InvalidData));
            }
            catch (InvalidOperationException ex)
            {
                return NotFound(Error(ex.Message, ApiResponseCode.NotFound));
            }
            catch (Exception ex)
            {
                return StatusCode(500, Error(ex.Message));
            }
        }

        private static PagedResult<ProgramaResponse> Success(string message, ProgramaResponse data) =>
            new()
            {
                Success = true,
                Message = message,
                Code = ApiResponseCode.Success.ToCode(),
                Data = data,
                Items = new List<ProgramaResponse> { data },
                TotalCount = 1
            };

        private static PagedResult<ProgramaResponse> Error(string message, ApiResponseCode code = ApiResponseCode.Error) =>
            new()
            {
                Success = false,
                Message = message,
                Code = code.ToCode(),
                TotalCount = 0
            };
    }
}
