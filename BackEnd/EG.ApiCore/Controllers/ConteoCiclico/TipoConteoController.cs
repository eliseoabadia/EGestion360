using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class TipoConteoController : ControllerBase
    {
        private readonly GenericService<TipoConteo, TipoConteoDto, TipoConteoResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext; // Opcional

        public TipoConteoController(
            GenericService<TipoConteo, TipoConteoDto, TipoConteoResponse> service,
            IMapper mapper,
            IUserContextService userContext = null) // Hacer opcional si no se usa
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureService();
        }

        private void ConfigureService()
        {
            // Si la entidad tiene relaciones, puedes agregar includes aquí
            // Ejemplo: _service.AddInclude(t => t.AlgunaPropiedad);
            // _service.AddRelationFilter("TipoConteo", new List<string> { "Nombre" });
        }

        // GET: api/TipoConteo
        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> GetAll()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return Ok(new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Tipos de conteo obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipos de conteo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // GET: api/TipoConteo/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> GetById(int id)
        {
            try
            {
                var result = await _service.GetByIdAsync(id);

                if (result == null)
                    return NotFound(new PagedResult<TipoConteoResponse>
                    {
                        Success = false,
                        Message = "Tipo de conteo no encontrado",
                        Code = "NOTFOUND_TIPOCONTEO",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Tipo de conteo encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoConteoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipo de conteo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/TipoConteo
        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> Add([FromBody] TipoConteoResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<TipoConteoDto>(viewDto);

                // Validar duplicados (ajusta la lógica según tu negocio)
                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<TipoConteoResponse>
                    {
                        Success = false,
                        Message = "Ya existe un tipo de conteo activo con ese nombre",
                        Code = "DUPLICATE_TIPOCONTEO",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                // Mapear de vuelta para obtener el ID generado (si es necesario)
                var createdDto = _mapper.Map<TipoConteoResponse>(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidTipoConteo },
                    new PagedResult<TipoConteoResponse>
                    {
                        Success = true,
                        Message = "Tipo de conteo creado correctamente",
                        Code = "SUCCESS",
                        Data = createdDto,
                        Items = new List<TipoConteoResponse> { createdDto },
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al crear tipo de conteo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // PUT: api/TipoConteo/{id}
        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> Update(int id, [FromBody] TipoConteoResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<TipoConteoDto>(viewDto);
                dto.PkidTipoConteo = id;

                // Validar duplicados en actualización
                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<TipoConteoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro tipo de conteo activo con ese nombre",
                        Code = "DUPLICATE_TIPOCONTEO",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Tipo de conteo actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Tipo de conteo con ID {id} no encontrado",
                    Code = "NOTFOUND_TIPOCONTEO",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar tipo de conteo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // DELETE: api/TipoConteo/{id}
        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Tipo de conteo eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar tipo de conteo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/TipoConteo/GetAllPaginado
        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            try
            {
                // Limpiar configuración previa si es necesario
                _service.ClearConfiguration();
                ConfigureService();

                // Asume que el servicio tiene un método GetAllPaginadoAsync que acepta PagedRequest
                var result = await _service.GetAllPaginadoAsync(_params);

                return Ok(new PagedResult<TipoConteoResponse>
                {
                    Success = true,
                    Message = "Tipos de conteo obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipos de conteo paginados: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/TipoConteo/GetAllTipoConteoPaginado (opcional, por compatibilidad)
        [HttpPost("GetAllTipoConteoPaginado")]
        public async Task<ActionResult<PagedResult<TipoConteoResponse>>> GetAllTipoConteoPaginado([FromBody] PagedRequest _params)
        {
            // Redirige al mismo método paginado
            return await GetAllPaginado(_params);
        }
    }
}