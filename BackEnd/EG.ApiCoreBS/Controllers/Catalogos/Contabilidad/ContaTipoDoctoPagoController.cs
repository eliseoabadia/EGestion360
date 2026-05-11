using AutoMapper;
using EG.Application.Interfaces.Contabilidad;
using EG.Common.GenericModel;
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
        private readonly IContaTipoDoctoPagoService _service;
        private readonly IMapper _mapper;

        public ContaTipoDoctoPagoController(
            IContaTipoDoctoPagoService service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
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
                var created = await _service.CreateAsync(response, GetCurrentUserId());

                return CreatedAtAction(nameof(GetById), new { id = created?.PkidTipoDoctoPago }, 
                    new PagedResult<ContaTipoDoctoPagoResponse>
                    {
                        Success = true,
                        Message = "Forma de pago creada correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<ContaTipoDoctoPagoResponse> { created } : new List<ContaTipoDoctoPagoResponse>(),
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
                var updated = await _service.UpdateAsync(id, response, GetCurrentUserId());
                if (updated == null)
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
                    Message = "Forma de pago actualizada correctamente",
                    Code = "SUCCESS",
                    Items = new List<ContaTipoDoctoPagoResponse> { updated },
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
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<bool>
                {
                    Success = false,
                    Message = "Forma de pago no encontrada",
                    Code = "NOT_FOUND"
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

        private int GetCurrentUserId()
        {
            var claim = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier);
            return claim != null ? int.Parse(claim.Value) : 0;
        }
    }
}
