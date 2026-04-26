using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Adquisicion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ProveedorController : ControllerBase
    {
        private readonly GenericService<Proveedor, ProveedorDto, ProveedorResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public ProveedorController(
            GenericService<Proveedor, ProveedorDto, ProveedorResponse> service,
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
            _service.AddInclude(p => p.FkIdTipoProveedorSisNavigation);
            _service.AddInclude(p => p.FkidEstatusProveedorSisNavigation);
            _service.AddInclude(p => p.FkidCuentaContableSisNavigation);
            _service.AddInclude(p => p.FkidMunicipioSisNavigation);
            _service.AddInclude(p => p.FkidEstadoSisNavigation);
            _service.AddInclude(p => p.FkidPaisSisNavigation);
            _service.AddRelationFilter("FkIdTipoProveedorSisNavigation", new List<string> { "Descripcion" });
            _service.AddRelationFilter("FkidEstatusProveedorSisNavigation", new List<string> { "Descripcion" });
            _service.AddRelationFilter("FkidEstadoSisNavigation", new List<string> { "Nombre" });
            _service.AddRelationFilter("FkidPaisSisNavigation", new List<string> { "Descripcion" });
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueRfc", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Rfc.ToLower() == dto.Rfc.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueRfcUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Rfc.ToLower() == dto.Rfc.ToLower() && x.PkidProveedor != id.Value && x.Activo);
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<ProveedorResponse>
            {
                Success = true,
                Message = "Proveedores obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidProveedor");

            if (result == null)
                return NotFound(new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = "Proveedor no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            return Ok(new PagedResult<ProveedorResponse>
            {
                Success = true,
                Message = "Proveedor encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ProveedorResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> Create([FromBody] ProveedorResponse response)
        {
            try
            {
                var dto = _mapper.Map<ProveedorDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.FechaAlta = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Ya existe un proveedor activo con ese RFC",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidProveedor },
                    new PagedResult<ProveedorResponse>
                    {
                        Success = true,
                        Message = "Proveedor creado correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = $"Error al crear proveedor: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> Update(int id, [FromBody] ProveedorResponse response)
        {
            try
            {
                var dto = _mapper.Map<ProveedorDto>(response);
                dto.PkidProveedor = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro proveedor activo con ese RFC",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<ProveedorResponse>
                {
                    Success = true,
                    Message = "Proveedor actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = $"Proveedor con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<ProveedorResponse>
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
                    Message = "Proveedor eliminado correctamente",
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
                    Message = $"Proveedor con ID {id} no encontrado",
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
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(new PagedResult<ProveedorResponse>
            {
                Success = true,
                Message = "Proveedores obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> Buscar([FromBody] BusquedaRequest request)
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

            return Ok(new PagedResult<ProveedorResponse>
            {
                Success = true,
                Message = "Proveedores filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}