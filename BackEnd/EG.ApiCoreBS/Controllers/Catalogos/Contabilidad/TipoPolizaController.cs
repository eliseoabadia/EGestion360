using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Domain.Interfaces;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Contabilidad
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class TipoPolizaController : ControllerBase
    {
        private readonly ITipoPolizaService _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public TipoPolizaController(ITipoPolizaService service, IMapper mapper, IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> GetAll()
        {
            var items = await _service.GetAllAsync();
            return Ok(new PagedResult<TipoPolizaResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<TipoPolizaResponse>
                {
                    Success = false,
                    Message = $"No se encontrÃ³ el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<TipoPolizaResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<TipoPolizaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> Create([FromBody] TipoPolizaResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<TipoPolizaResponse>
                {
                    Success = false,
                    Message = "Datos invÃ¡lidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<TipoPolizaDto>(request);
            if (!await _service.CanAddAsync(dto))
            {
                return Conflict(new PagedResult<TipoPolizaResponse>
                {
                    Success = false,
                    Message = "Ya existe un registro activo con la misma Clave o DescripciÃ³n",
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }

            int currentUserId = _userContext.GetCurrentUserId();
            var created = await _service.AddAsync(dto, currentUserId);

            return CreatedAtAction(nameof(GetById), new { id = created.PkidTipoPoliza },
                new PagedResult<TipoPolizaResponse>
                {
                    Success = true,
                    Message = "Registro creado exitosamente",
                    Code = "SUCCESS",
                    Data = created,
                    TotalCount = 1
                });
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> Update(int id, [FromBody] TipoPolizaResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<TipoPolizaResponse>
                {
                    Success = false,
                    Message = "Datos invÃ¡lidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<TipoPolizaDto>(request);
            dto.PkidTipoPoliza = id;

            if (!await _service.CanUpdateAsync(id, dto))
            {
                return Conflict(new PagedResult<TipoPolizaResponse>
                {
                    Success = false,
                    Message = "Ya existe otro registro activo con la misma Clave o DescripciÃ³n",
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }

            int currentUserId = _userContext.GetCurrentUserId();
            await _service.UpdateAsync(id, dto, currentUserId);

            var updated = await _service.GetByIdAsync(id);

            return Ok(new PagedResult<TipoPolizaResponse>
            {
                Success = true,
                Message = "Registro actualizado correctamente",
                Code = "SUCCESS",
                Data = updated,
                TotalCount = 1
            });
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<TipoPolizaResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<TipoPolizaResponse>
                {
                    Success = false,
                    Message = $"No se encontrÃ³ el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<TipoPolizaResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount,
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<TipoPolizaResponse>>> Buscar([FromBody] BusquedaRequest request)
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
            return Ok(new PagedResult<TipoPolizaResponse>
            {
                Success = true,
                Message = "BÃºsqueda realizada correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
