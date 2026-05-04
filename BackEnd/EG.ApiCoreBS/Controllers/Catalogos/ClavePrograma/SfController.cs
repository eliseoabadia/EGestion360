using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.ClavePrograma
{
    [Authorize]
    [ApiController]
    [Route("api/[controller]")]
    public class SfController : ControllerBase
    {
        private readonly ISfService _sfService;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public SfController(ISfService sfService, IMapper mapper, IUserContextService userContext)
        {
            _sfService = sfService;
            _mapper = mapper;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> GetAll()
        {
            var items = await _sfService.GetAllAsync();
            return Ok(new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> GetById(int id)
        {
            var result = await _sfService.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<SubFuncionResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> Create([FromBody] SubFuncionResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = "Datos inválidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<SubFuncionDto>(request);
            if (!await _sfService.CanAddAsync(dto))
            {
                return Conflict(new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = "Ya existe un registro activo con la misma Clave o Descripción",
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }

            int currentUserId = _userContext.GetCurrentUserId();
            var created = await _sfService.AddAsync(dto, currentUserId);

            return CreatedAtAction(nameof(GetById), new { id = created.PkidSf },
                new PagedResult<SubFuncionResponse>
                {
                    Success = true,
                    Message = "Registro creado exitosamente",
                    Code = "SUCCESS",
                    Data = created,
                    TotalCount = 1
                });
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> Update(int id, [FromBody] SubFuncionResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = "Datos inválidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<SubFuncionDto>(request);
            dto.PkidSf = id;

            if (!await _sfService.CanUpdateAsync(id, dto))
            {
                return Conflict(new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = "Ya existe otro registro activo con la misma Clave o Descripción",
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }

            int currentUserId = _userContext.GetCurrentUserId();
            await _sfService.UpdateAsync(id, dto, currentUserId);

            var updated = await _sfService.GetByIdAsync(id);

            return Ok(new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Registro actualizado correctamente",
                Code = "SUCCESS",
                Data = updated,
                TotalCount = 1
            });
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> Delete(int id)
        {
            try
            {
                await _sfService.DeleteAsync(id);
                return Ok(new PagedResult<SubFuncionResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _sfService.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount,
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<SubFuncionResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };
            var result = await _sfService.GetAllPaginadoAsync(pagedRequest);
            return Ok(new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Búsqueda realizada correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}
