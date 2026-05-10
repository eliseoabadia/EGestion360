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

namespace EG.ApiCoreBS.Controllers.Catalogos.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PersonaController : ControllerBase
    {
        private readonly GenericService<Persona, PersonaDto, PersonaResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public PersonaController(
            GenericService<Persona, PersonaDto, PersonaResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // Incluir relaciones si es necesario
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.PkidPersona != id.Value && x.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<PersonaResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<PersonaResponse>
            {
                Success = true,
                Message = "Personas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<PersonaResponse>>> GetById(int id)
        {
            var entity = await _service.GetQueryWithIncludes().FirstOrDefaultAsync(e => e.PkidPersona == id);
            if (entity == null)
                return NotFound(new PagedResult<PersonaResponse> { Success = false, Message = "Persona no encontrada", Code = "NOT_FOUND" });

            var result = _mapper.Map<PersonaResponse>(entity);
            return Ok(new PagedResult<PersonaResponse>
            {
                Success = true,
                Message = "Persona obtenida correctamente",
                Code = "SUCCESS",
                Data = result,
                Items = new List<PersonaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<PersonaResponse>>> Create([FromBody] PersonaResponse response)
        {
            try
            {
                var dto = _mapper.Map<PersonaDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Clave == dto.Clave && x.Activo);

                return CreatedAtAction(nameof(GetById), new { id = created?.PkidPersona },
                    new PagedResult<PersonaResponse>
                    {
                        Success = true,
                        Message = "Persona creada correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<PersonaResponse> { _mapper.Map<PersonaResponse>(created) } : new List<PersonaResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<PersonaResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<PersonaResponse>>> Update(int id, [FromBody] PersonaResponse response)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<PersonaResponse> { Success = false, Message = "Persona no encontrada", Code = "NOT_FOUND" });

                var dto = _mapper.Map<PersonaDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<PersonaResponse>
                {
                    Success = true,
                    Message = "Persona actualizada correctamente",
                    Code = "SUCCESS",
                    Items = new List<PersonaResponse> { _mapper.Map<PersonaResponse>(await _service.GetByIdAsync(id)) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<PersonaResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Persona no encontrada", Code = "NOT_FOUND" });

                await _service.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Persona eliminada correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<PersonaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var query = _service.GetQueryWithIncludes();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro;
                query = query.Where(e =>
                    e.Clave.Contains(f) ||
                    e.Nombre.Contains(f) ||
                    e.Paterno.Contains(f) ||
                    e.Materno.Contains(f) ||
                    e.Rfc.Contains(f) ||
                    e.Curp.Contains(f));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidPersona" => isAscending ? query.OrderBy(e => e.PkidPersona) : query.OrderByDescending(e => e.PkidPersona),
                    "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                    "Nombre" => isAscending ? query.OrderBy(e => e.Nombre) : query.OrderByDescending(e => e.Nombre),
                    "Paterno" => isAscending ? query.OrderBy(e => e.Paterno) : query.OrderByDescending(e => e.Paterno),
                    "Materno" => isAscending ? query.OrderBy(e => e.Materno) : query.OrderByDescending(e => e.Materno),
                    "Rfc" => isAscending ? query.OrderBy(e => e.Rfc) : query.OrderByDescending(e => e.Rfc),
                    "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                    _ => query.OrderBy(e => e.Nombre)
                };
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return Ok(new PagedResult<PersonaResponse>
            {
                Items = _mapper.Map<List<PersonaResponse>>(items),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }
    }
}
