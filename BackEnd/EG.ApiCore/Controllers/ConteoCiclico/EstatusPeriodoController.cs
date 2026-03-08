using AutoMapper;
using EG.ApiCore.Services;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Requests.General;        // Ajusta según donde esté EstatusPeriodoDto
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.DTOs.Responses.General;       // Ajusta según donde esté EstatusPeriodoResponse
using EG.Infraestructure.Models;               // Contiene la entidad EstatusPeriodo
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EstatusPeriodoController : ControllerBase
    {
        private readonly GenericService<EstatusPeriodo, EstatusPeriodoDto, EstatusPeriodoResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext; // Opcional

        public EstatusPeriodoController(
            GenericService<EstatusPeriodo, EstatusPeriodoDto, EstatusPeriodoResponse> service,
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
            // Si la entidad tiene relaciones, agrega includes aquí
            // Ejemplo: _service.AddInclude(e => e.PeriodoConteos); // si se necesita
            // _service.AddRelationFilter("EstatusPeriodo", new List<string> { "Nombre" });
        }

        // GET: api/EstatusPeriodo
        [HttpGet]
        public async Task<ActionResult<PagedResult<EstatusPeriodoResponse>>> GetAll()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return Ok(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = true,
                    Message = "Estatus de período obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener estatus de período: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // GET: api/EstatusPeriodo/{id}
        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EstatusPeriodoResponse>>> GetById(int id)
        {
            try
            {
                var result = await _service.GetByIdAsync(id);

                if (result == null)
                    return NotFound(new PagedResult<EstatusPeriodoResponse>
                    {
                        Success = false,
                        Message = "Estatus de período no encontrado",
                        Code = "NOTFOUND_ESTATUSPERIODO",
                        TotalCount = 0
                    });

                return Ok(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = true,
                    Message = "Estatus de período encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<EstatusPeriodoResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener estatus de período: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/EstatusPeriodo
        [HttpPost]
        public async Task<ActionResult<PagedResult<EstatusPeriodoResponse>>> Add([FromBody] EstatusPeriodoResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<EstatusPeriodoDto>(viewDto);

                // Validar duplicados (ajusta según tu lógica de negocio)
                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<EstatusPeriodoResponse>
                    {
                        Success = false,
                        Message = "Ya existe un estatus de período activo con ese nombre",
                        Code = "DUPLICATE_ESTATUSPERIODO",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                // Mapear de vuelta para obtener el ID generado (si es necesario)
                var createdDto = _mapper.Map<EstatusPeriodoResponse>(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidEstatusPeriodo },
                    new PagedResult<EstatusPeriodoResponse>
                    {
                        Success = true,
                        Message = "Estatus de período creado correctamente",
                        Code = "SUCCESS",
                        Data = createdDto,
                        Items = new List<EstatusPeriodoResponse> { createdDto },
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = false,
                    Message = $"Error al crear estatus de período: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // PUT: api/EstatusPeriodo/{id}
        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EstatusPeriodoResponse>>> Update(int id, [FromBody] EstatusPeriodoResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<EstatusPeriodoDto>(viewDto);
                dto.PkidEstatusPeriodo = id;

                // Validar duplicados en actualización
                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<EstatusPeriodoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro estatus de período activo con ese nombre",
                        Code = "DUPLICATE_ESTATUSPERIODO",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = true,
                    Message = "Estatus de período actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = false,
                    Message = $"Estatus de período con ID {id} no encontrado",
                    Code = "NOTFOUND_ESTATUSPERIODO",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar estatus de período: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // DELETE: api/EstatusPeriodo/{id}
        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<EstatusPeriodoResponse>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = true,
                    Message = "Estatus de período eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar estatus de período: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/EstatusPeriodo/GetAllPaginado
        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<EstatusPeriodoResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            try
            {
                _service.ClearConfiguration();
                ConfigureService();

                var result = await _service.GetAllPaginadoAsync(_params);

                return Ok(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = true,
                    Message = "Estatus de período obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EstatusPeriodoResponse>
                {
                    Success = false,
                    Message = $"Error al obtener estatus de período paginados: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        // POST: api/EstatusPeriodo/GetAllEstatusPeriodoPaginado (opcional, por compatibilidad)
        [HttpPost("GetAllEstatusPeriodoPaginado")]
        public async Task<ActionResult<PagedResult<EstatusPeriodoResponse>>> GetAllEstatusPeriodoPaginado([FromBody] PagedRequest _params)
        {
            return await GetAllPaginado(_params);
        }
    }
}