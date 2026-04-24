using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Almacen
{
    [ApiController]
    [Route("api/[controller]")]
    public class TipoBienController : ControllerBase
    {
        private readonly GenericService<TipoBien, TipoBienDto, TipoBienResponse> _service;
        private readonly GenericService<VwTipoBienConteo, TipoBienDto, TipoBienResponse> _serviceView;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public TipoBienController(
            GenericService<TipoBien, TipoBienDto, TipoBienResponse> service,
            GenericService<VwTipoBienConteo, TipoBienDto, TipoBienResponse> serviceView,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(new PagedResult<TipoBienResponse>
            {
                Success = true,
                Message = "Tipos de bien obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetById(int id)
        {
            Console.WriteLine($"🔍 Backend GetById: Buscando id={id}");
            try
            {
                var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidTipoBien");
                Console.WriteLine($"🔍 Backend GetById: Resultado es null={result == null}");
                
                if (result == null)
                {
                    return NotFound(new PagedResult<TipoBienResponse>
                    {
                        Success = false,
                        Message = "Tipo de bien no encontrado",
                        Code = "NOT_FOUND"
                    });
                }

                Console.WriteLine($"🔍 Backend GetById: Encontrado - PkidTipoBien={result.PkidTipoBien}, CodigoArticulo={result.CodigoArticulo}");

                return Ok(new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoBienResponse> { result },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Backend GetById: Error={ex.Message}");
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> GetAllPaginado([FromBody] PagedRequest pageRequest)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
                return Ok(new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipos de bien obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR"
                });
            }
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> Create([FromBody] TipoBienResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoBienDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidTipoBien }, new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TipoBienResponse>>> Update(int id, [FromBody] TipoBienResponse response)
        {
            Console.WriteLine($"🔍 Backend Update: Recibido id={id}, PkidTipoBien={response?.PkidTipoBien}, CodigoArticulo={response?.CodigoArticulo}");
            try
            {
                var dto = _mapper.Map<TipoBienDto>(response);
                Console.WriteLine($"🔍 Backend Update: DTO mapeado - PkidTipoBien={dto.PkidTipoBien}, CodigoClave={dto.CodigoClave}");
                
                dto.PkidTipoBien = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<TipoBienResponse>
                {
                    Success = true,
                    Message = "Tipo de bien actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                Console.WriteLine($"⚠️ Backend Update: Entidad con ID {id} no encontrada");
                return NotFound(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = $"Tipo de bien con ID {id} no encontrado",
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Backend Update: Error={ex.Message}");
                return BadRequest(new PagedResult<TipoBienResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<bool>
                {
                    Success = true,
                    Message = "Tipo de bien eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Tipo de bien con ID {id} no encontrado",
                    Code = "NOT_FOUND"
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR"
                });
            }
        }
    }
}
