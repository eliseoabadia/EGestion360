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
    public class MarcaController : ControllerBase
    {
        private readonly GenericService<Marca, MarcaDto, MarcaResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public MarcaController(
            GenericService<Marca, MarcaDto, MarcaResponse> service,
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
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidMarca != id.Value && x.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<MarcaResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<MarcaResponse>
            {
                Success = true,
                Message = "Marcas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<MarcaResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<MarcaResponse> { Success = false, Message = "Marca no encontrada", Code = "NOT_FOUND" });

            return Ok(new PagedResult<MarcaResponse>
            {
                Success = true,
                Message = "Marca obtenida correctamente",
                Code = "SUCCESS",
                Items = new List<MarcaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<MarcaResponse>>> Create([FromBody] MarcaResponse response)
        {
            try
            {
                var dto = _mapper.Map<MarcaDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

                return CreatedAtAction(nameof(GetById), new { id = created?.PkidMarca }, 
                    new PagedResult<MarcaResponse>
                    {
                        Success = true,
                        Message = "Marca creada correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<MarcaResponse> { _mapper.Map<MarcaResponse>(created) } : new List<MarcaResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MarcaResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<MarcaResponse>>> Update(int id, [FromBody] MarcaResponse response)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<MarcaResponse> { Success = false, Message = "Marca no encontrada", Code = "NOT_FOUND" });

                var dto = _mapper.Map<MarcaDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<MarcaResponse>
                {
                    Success = true,
                    Message = "Marca actualizada correctamente",
                    Code = "SUCCESS",
                    Items = new List<MarcaResponse> { _mapper.Map<MarcaResponse>(await _service.GetByIdAsync(id)) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MarcaResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Marca no encontrada", Code = "NOT_FOUND" });

                await _service.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Marca eliminada correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<MarcaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }
    }
}
