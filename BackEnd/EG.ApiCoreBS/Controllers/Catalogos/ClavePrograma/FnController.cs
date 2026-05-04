using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Business.Services;
using EG.Common.GenericModel;
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
    public class FnController : ControllerBase
    {
        private readonly IFnService _fnService;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public FnController(IFnService fnService, IMapper mapper, IUserContextService userContext)
        {
            _fnService = fnService;
            _mapper = mapper;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<FnResponse>>> GetAll()
        {
            var items = await _fnService.GetAllAsync();
            return Ok(new PagedResult<FnResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<FnResponse>>> GetById(int id)
        {
            var result = await _fnService.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<FnResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<FnResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<FnResponse>>> Create([FromBody] FnResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = "Datos inválidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<FnDto>(request);
            if (!await _fnService.CanAddAsync(dto))
            {
                return Conflict(new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = "Ya existe un registro activo con la misma Clave o Descripción",
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }

            int currentUserId = _userContext.GetCurrentUserId();
            var created = await _fnService.AddAsync(dto, currentUserId);

            return CreatedAtAction(nameof(GetById), new { id = created.PkidFn },
                new PagedResult<FnResponse>
                {
                    Success = true,
                    Message = "Registro creado exitosamente",
                    Code = "SUCCESS",
                    Data = created,
                    TotalCount = 1
                });
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<FnResponse>>> Update(int id, [FromBody] FnResponse request)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = "Datos inválidos",
                    Code = "INVALID_MODEL",
                    TotalCount = 0
                });
            }

            var dto = _mapper.Map<FnDto>(request);
            dto.PkidFn = id;

            if (!await _fnService.CanUpdateAsync(id, dto))
            {
                return Conflict(new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = "Ya existe otro registro activo con la misma Clave o Descripción",
                    Code = "DUPLICATE",
                    TotalCount = 0
                });
            }

            int currentUserId = _userContext.GetCurrentUserId();
            await _fnService.UpdateAsync(id, dto, currentUserId);

            var updated = await _fnService.GetByIdAsync(id);

            return Ok(new PagedResult<FnResponse>
            {
                Success = true,
                Message = "Registro actualizado correctamente",
                Code = "SUCCESS",
                Data = updated,
                TotalCount = 1
            });
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<FnResponse>>> Delete(int id)
        {
            try
            {
                await _fnService.DeleteAsync(id);
                return Ok(new PagedResult<FnResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<FnResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _fnService.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<FnResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount,
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<FnResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };
            var result = await _fnService.GetAllPaginadoAsync(pagedRequest);
            return Ok(new PagedResult<FnResponse>
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
