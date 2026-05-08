using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class TipoPatrimonioController : ControllerBase
    {
        private readonly GenericService<TipoPatrimonio, TipoPatrimonioDto, TipoPatrimonioResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public TipoPatrimonioController(
            GenericService<TipoPatrimonio, TipoPatrimonioDto, TipoPatrimonioResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidTipoPatrimonio != id.Value && x.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<TipoPatrimonioResponse>
            {
                Success = true,
                Message = "Tipos de patrimonio obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> GetById(int id)
        {
            var entity = await _service.GetQueryWithIncludes().FirstOrDefaultAsync(e => e.PkidTipoPatrimonio == id);
            if (entity == null)
                return NotFound(new PagedResult<TipoPatrimonioResponse> { Success = false, Message = "Tipo de patrimonio no encontrado", Code = "NOT_FOUND" });

            var result = _mapper.Map<TipoPatrimonioResponse>(entity);
            return Ok(new PagedResult<TipoPatrimonioResponse>
            {
                Success = true,
                Message = "Tipo de patrimonio obtenido correctamente",
                Code = "SUCCESS",
                Data = result,
                Items = new List<TipoPatrimonioResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> Create([FromBody] TipoPatrimonioResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoPatrimonioDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

                return CreatedAtAction(nameof(GetById), new { id = created?.PkidTipoPatrimonio }, 
                    new PagedResult<TipoPatrimonioResponse>
                    {
                        Success = true,
                        Message = "Tipo de patrimonio creado correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<TipoPatrimonioResponse> { _mapper.Map<TipoPatrimonioResponse>(created) } : new List<TipoPatrimonioResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoPatrimonioResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> Update(int id, [FromBody] TipoPatrimonioResponse response)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<TipoPatrimonioResponse> { Success = false, Message = "Tipo de patrimonio no encontrado", Code = "NOT_FOUND" });

                var dto = _mapper.Map<TipoPatrimonioDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<TipoPatrimonioResponse>
                {
                    Success = true,
                    Message = "Tipo de patrimonio actualizado correctamente",
                    Code = "SUCCESS",
                    Items = new List<TipoPatrimonioResponse> { _mapper.Map<TipoPatrimonioResponse>(await _service.GetByIdAsync(id)) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoPatrimonioResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Tipo de patrimonio no encontrado", Code = "NOT_FOUND" });

                await _service.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Tipo de patrimonio eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var query = _service.GetQueryWithIncludes();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e => e.Descripcion.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidTipoPatrimonio" => isAscending ? query.OrderBy(e => e.PkidTipoPatrimonio) : query.OrderByDescending(e => e.PkidTipoPatrimonio),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                    "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                    _ => query.OrderBy(e => e.Descripcion)
                };
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return Ok(new PagedResult<TipoPatrimonioResponse>
            {
                Items = _mapper.Map<List<TipoPatrimonioResponse>>(items),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }
    }
}
