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
    public class GrupoBienController : ControllerBase
    {
        private readonly GenericService<GrupoBien, GrupoBienDto, GrupoBienResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public GrupoBienController(
            GenericService<GrupoBien, GrupoBienDto, GrupoBienResponse> service,
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
            _service.AddInclude(e => e.FkidFamiliaAlmaNavigation);
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
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidGrupoBien != id.Value && x.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "Grupos de bien obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

            return Ok(new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "Grupo de bien obtenido correctamente",
                Code = "SUCCESS",
                Items = new List<GrupoBienResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> Create([FromBody] GrupoBienResponse response)
        {
            try
            {
                var dto = _mapper.Map<GrupoBienDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

                return CreatedAtAction(nameof(GetById), new { id = created?.PkidGrupoBien }, 
                    new PagedResult<GrupoBienResponse>
                    {
                        Success = true,
                        Message = "Grupo de bien creado correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<GrupoBienResponse> { _mapper.Map<GrupoBienResponse>(created) } : new List<GrupoBienResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> Update(int id, [FromBody] GrupoBienResponse response)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

                var dto = _mapper.Map<GrupoBienDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Success = true,
                    Message = "Grupo de bien actualizado correctamente",
                    Code = "SUCCESS",
                    Items = new List<GrupoBienResponse> { _mapper.Map<GrupoBienResponse>(await _service.GetByIdAsync(id)) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

                await _service.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Grupo de bien eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }
    }
}
