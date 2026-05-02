using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class TipoAdquisicionController : ControllerBase
    {
        private readonly GenericService<TipoAdquisicion, TipoAdquisicionDto, TipoAdquisicionResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public TipoAdquisicionController(
            GenericService<TipoAdquisicion, TipoAdquisicionDto, TipoAdquisicionResponse> service,
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
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.PkidTipoAdq != id.Value && x.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<TipoAdquisicionResponse>
            {
                Success = true,
                Message = "Tipos de adquisición obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<TipoAdquisicionResponse> { Success = false, Message = "Tipo de adquisición no encontrado", Code = "NOT_FOUND" });

            return Ok(new PagedResult<TipoAdquisicionResponse>
            {
                Success = true,
                Message = "Tipo de adquisición obtenido correctamente",
                Code = "SUCCESS",
                Items = new List<TipoAdquisicionResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> Create([FromBody] TipoAdquisicionResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoAdquisicionDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Clave == dto.Clave && x.Activo);

                return CreatedAtAction(nameof(GetById), new { id = created?.PkidTipoAdq }, 
                    new PagedResult<TipoAdquisicionResponse>
                    {
                        Success = true,
                        Message = "Tipo de adquisición creado correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<TipoAdquisicionResponse> { _mapper.Map<TipoAdquisicionResponse>(created) } : new List<TipoAdquisicionResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoAdquisicionResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> Update(int id, [FromBody] TipoAdquisicionResponse response)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<TipoAdquisicionResponse> { Success = false, Message = "Tipo de adquisición no encontrado", Code = "NOT_FOUND" });

                var dto = _mapper.Map<TipoAdquisicionDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<TipoAdquisicionResponse>
                {
                    Success = true,
                    Message = "Tipo de adquisición actualizado correctamente",
                    Code = "SUCCESS",
                    Items = new List<TipoAdquisicionResponse> { _mapper.Map<TipoAdquisicionResponse>(await _service.GetByIdAsync(id)) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoAdquisicionResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Tipo de adquisición no encontrado", Code = "NOT_FOUND" });

                await _service.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Tipo de adquisición eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }
    }
}
