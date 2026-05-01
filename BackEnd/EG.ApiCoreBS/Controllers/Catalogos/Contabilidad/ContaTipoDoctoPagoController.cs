using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Contabilidad
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ContaTipoDoctoPagoController : ControllerBase
    {
        private readonly GenericService<TipoDoctoPago, ContaTipoDoctoPagoDto, ContaTipoDoctoPagoResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public ContaTipoDoctoPagoController(
            GenericService<TipoDoctoPago, ContaTipoDoctoPagoDto, ContaTipoDoctoPagoResponse> service,
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
            // Agregar includes para propiedades de navegación si existen
            // _service.AddInclude(e => e.NavegacionEjemplo);
            
            // Configurar búsqueda en relaciones si aplica
            // _service.AddRelationFilter("NavegacionEjemplo", new List<string> { "CampoBusqueda" });
        }

        private void ConfigureValidations()
        {
            // Validación: Descripción única
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            // Validación: Descripción única en actualización
            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidTipoDoctoPago != id.Value && x.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ContaTipoDoctoPagoResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<ContaTipoDoctoPagoResponse>
            {
                Success = true,
                Message = "Formas de pago obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ContaTipoDoctoPagoResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
            {
                return NotFound(new PagedResult<ContaTipoDoctoPagoResponse>
                {
                    Success = false,
                    Message = "Forma de pago no encontrada",
                    Code = "NOT_FOUND"
                });
            }

            return Ok(new PagedResult<ContaTipoDoctoPagoResponse>
            {
                Success = true,
                Message = "Forma de pago obtenida correctamente",
                Code = "SUCCESS",
                Items = new List<ContaTipoDoctoPagoResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ContaTipoDoctoPagoResponse>>> Create([FromBody] ContaTipoDoctoPagoResponse response)
        {
            try
            {
                var dto = _mapper.Map<ContaTipoDoctoPagoDto>(response);
                
                // Asignar usuario de creación (convertir int a string)
                dto.UsuarioCreacion = _userContext.GetCurrentUserId().ToString();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

                return CreatedAtAction(nameof(GetById), new { id = created?.PkidTipoDoctoPago }, 
                    new PagedResult<ContaTipoDoctoPagoResponse>
                    {
                        Success = true,
                        Message = "Forma de pago creada correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<ContaTipoDoctoPagoResponse> { _mapper.Map<ContaTipoDoctoPagoResponse>(created) } : new List<ContaTipoDoctoPagoResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ContaTipoDoctoPagoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ContaTipoDoctoPagoResponse>>> Update(int id, [FromBody] ContaTipoDoctoPagoResponse response)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                {
                    return NotFound(new PagedResult<ContaTipoDoctoPagoResponse>
                    {
                        Success = false,
                        Message = "Forma de pago no encontrada",
                        Code = "NOT_FOUND"
                    });
                }

                var dto = _mapper.Map<ContaTipoDoctoPagoDto>(response);
                
                // Mantener campos de creación originales
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                
                // Asignar usuario de modificación (convertir int a string)
                dto.UsuarioModificacion = _userContext.GetCurrentUserId().ToString();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                var updated = await _service.GetByIdAsync(id);

                return Ok(new PagedResult<ContaTipoDoctoPagoResponse>
                {
                    Success = true,
                    Message = "Forma de pago actualizada correctamente",
                    Code = "SUCCESS",
                    Items = updated != null ? new List<ContaTipoDoctoPagoResponse> { updated } : new List<ContaTipoDoctoPagoResponse>(),
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ContaTipoDoctoPagoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                {
                    return NotFound(new PagedResult<bool>
                    {
                        Success = false,
                        Message = "Forma de pago no encontrada",
                        Code = "NOT_FOUND"
                    });
                }

                await _service.DeleteAsync(id);

                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Forma de pago eliminada correctamente",
                    Code = "SUCCESS",
                    Items = new List<bool> { true },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<ContaTipoDoctoPagoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }
    }
}
