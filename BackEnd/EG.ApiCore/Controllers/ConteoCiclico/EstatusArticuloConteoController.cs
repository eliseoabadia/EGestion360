using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;          // Ajusta según namespace real de EstatusArticuloConteoDto
using EG.Domain.DTOs.Responses.ConteoCiclico;         // Ajusta según namespace real de EstatusArticuloConteoResponse
using EG.Infraestructure.Models;                       // Contiene la entidad EstatusArticuloConteo
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EstatusArticuloConteoController : ControllerBase
    {
        private readonly GenericService<EstatusArticuloConteo, EstatusArticuloConteoDto, EstatusArticuloConteoResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext; // Opcional

        public EstatusArticuloConteoController(
            GenericService<EstatusArticuloConteo, EstatusArticuloConteoDto, EstatusArticuloConteoResponse> service,
            IMapper mapper,
            IUserContextService userContext = null) // Opcional
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            ConfigureService();
        }

        private void ConfigureService()
        {
            // Agrega includes si la entidad tiene relaciones necesarias para las consultas
            // Ejemplo: _service.AddInclude(e => e.ArticuloConteos);
            // _service.AddRelationFilter("EstatusArticuloConteo", new List<string> { "Nombre", "Orden" });
        }

        // GET: api/EstatusArticuloConteo
        [HttpGet]
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> GetAll()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return Ok(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Estatus de artículo obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener estatus de artículo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // GET: api/EstatusArticuloConteo/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> GetById(int id)
        {
            try
            {
                var result = await _service.GetByIdAsync(id);

                if (result == null)
                    return NotFound(new PagedResult<EstatusArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Estatus de artículo no encontrado",
                        Code = "NOTFOUND_ESTATUSARTICULO",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Estatus de artículo encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<EstatusArticuloConteoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener estatus de artículo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/EstatusArticuloConteo
        [HttpPost]
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> Add([FromBody] EstatusArticuloConteoResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<EstatusArticuloConteoDto>(viewDto);

                // Validar duplicados (personaliza según tu lógica, ej: por Nombre y Activo)
                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<EstatusArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Ya existe un estatus de artículo activo con ese nombre",
                        Code = "DUPLICATE_ESTATUSARTICULO",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                // Mapear de vuelta para obtener el ID generado (si es necesario)
                var createdDto = _mapper.Map<EstatusArticuloConteoResponse>(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidEstatusArticulo },
                    new PagedResult<EstatusArticuloConteoResponse>
                    {
                        Success = true,
                        Message = "Estatus de artículo creado correctamente",
                        Code = "SUCCESS",
                        Data = createdDto,
                        Items = new List<EstatusArticuloConteoResponse> { createdDto },
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al crear estatus de artículo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // PUT: api/EstatusArticuloConteo/{id}
        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> Update(int id, [FromBody] EstatusArticuloConteoResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<EstatusArticuloConteoDto>(viewDto);
                dto.PkidEstatusArticulo = id;

                // Validar duplicados en actualización
                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<EstatusArticuloConteoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro estatus de artículo activo con ese nombre",
                        Code = "DUPLICATE_ESTATUSARTICULO",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Estatus de artículo actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Estatus de artículo con ID {id} no encontrado",
                    Code = "NOTFOUND_ESTATUSARTICULO",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar estatus de artículo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // DELETE: api/EstatusArticuloConteo/{id}
        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Estatus de artículo eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar estatus de artículo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/EstatusArticuloConteo/GetAllPaginado
        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            try
            {
                _service.ClearConfiguration();
                ConfigureService();

                var result = await _service.GetAllPaginadoAsync(_params);

                return Ok(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = true,
                    Message = "Estatus de artículo obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusArticuloConteoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener estatus de artículo paginados: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/EstatusArticuloConteo/GetAllEstatusArticuloConteoPaginado (opcional, por compatibilidad)
        [HttpPost("GetAllEstatusArticuloConteoPaginado")]
        public async Task<ActionResult<PagedResult<EstatusArticuloConteoResponse>>> GetAllEstatusArticuloConteoPaginado([FromBody] PagedRequest _params)
        {
            return await GetAllPaginado(_params);
        }
    }
}