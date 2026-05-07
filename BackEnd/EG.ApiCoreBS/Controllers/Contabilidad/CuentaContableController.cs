using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Contabilidad
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class CuentaContableController : ControllerBase
    {
        private readonly GenericService<CuentaContable, CuentaContableDto, CuentaContableResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public CuentaContableController(
            GenericService<CuentaContable, CuentaContableDto, CuentaContableResponse> service,
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
            _service.AddInclude(c => c.FkidEmpresaSisNavigation);
            _service.AddInclude(c => c.FkidTipoCuentaContaNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueCuentaContable", async (dto) =>
            {
                var itemDto = dto as CuentaContableDto;
                if (itemDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(c => c.Cuenta.ToLower() == itemDto.Cuenta.ToLower() && c.Activo);
            });

            _service.AddValidationRuleWithId("UniqueCuentaContableUpdate", async (dto, id) =>
            {
                var itemDto = dto as CuentaContableDto;
                if (itemDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(c => c.Cuenta.ToLower() == itemDto.Cuenta.ToLower() && c.PkidCuentaContable != id.Value && c.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<CuentaContableResponse>
            {
                Success = true,
                Message = "Cuentas contables obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<CuentaContableResponse>
                {
                    Success = false,
                    Message = "Cuenta contable no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<CuentaContableResponse>
            {
                Success = true,
                Message = "Cuenta contable encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<CuentaContableResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> Create([FromBody] CuentaContableResponse response)
        {
            try
            {
                var dto = _mapper.Map<CuentaContableDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<CuentaContableResponse>
                    {
                        Success = false,
                        Message = "Ya existe una cuenta contable con esa cuenta",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidCuentaContable },
                    new PagedResult<CuentaContableResponse>
                    {
                        Success = true,
                        Message = "Cuenta contable creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<CuentaContableResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> Update(int id, [FromBody] CuentaContableResponse response)
        {
            try
            {
                var dto = _mapper.Map<CuentaContableDto>(response);
                dto.PkidCuentaContable = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<CuentaContableResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra cuenta contable con esa cuenta",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<CuentaContableResponse>
                {
                    Success = true,
                    Message = "Cuenta contable actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<CuentaContableResponse>
                {
                    Success = false,
                    Message = $"Cuenta contable con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<CuentaContableResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
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
                    Message = "Cuenta contable eliminada correctamente",
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
                    Message = $"Cuenta contable con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<CuentaContableResponse>
            {
                Success = true,
                Message = "Cuentas contables obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<CuentaContableResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _service.GetAllPaginadoAsync(pagedRequest);

            return Ok(new PagedResult<CuentaContableResponse>
            {
                Success = true,
                Message = "Cuentas contables filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpGet("GetLookup")]
        public async Task<ActionResult<List<LookupItem>>> GetLookup()
        {
            var items = await _service.GetQueryWithIncludes()
                .Where(c => c.Activo)
                .OrderBy(c => c.Cuenta)
                .Select(c => new LookupItem { Id = c.PkidCuentaContable, Text = (c.Cuenta ?? "") + " - " + (c.Descripcion ?? "") })
                .ToListAsync();
            return Ok(items);
        }
    }
}
