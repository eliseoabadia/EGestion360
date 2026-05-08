using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Catalogos.Adquisicion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class ProveedorController : ControllerBase
    {
        private readonly ILogger<ProveedorController> _logger;
        private readonly IRepository<Proveedor> _repository;
        private readonly EGestionContext _context;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public ProveedorController(
            ILogger<ProveedorController> logger,
            IRepository<Proveedor> repository,
            EGestionContext context,
            IMapper mapper,
            IUserContextService userContext)
        {
            _logger = logger;
            _repository = repository;
            _context = context;
            _mapper = mapper;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> GetAll()
        {
            var items = await _context.VwProveedors.ToListAsync();
            return Ok(new PagedResult<ProveedorResponse>
            {
                Items = _mapper.Map<List<ProveedorResponse>>(items),
                TotalCount = items.Count,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<ProveedorResponse>>> GetById(int id)
        {
            var entity = await _context.VwProveedors.FirstOrDefaultAsync(e => e.PkidProveedor == id);
            if (entity == null)
                return NotFound(new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = "Proveedor no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });

            var response = _mapper.Map<ProveedorResponse>(entity);
            return Ok(new PagedResult<ProveedorResponse>
            {
                Success = true,
                Message = "OK",
                Code = "SUCCESS",
                Data = response,
                Items = new List<ProveedorResponse> { response },
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
                dto.FechaCreacion = DateTime.UtcNow;
                dto.FechaAlta = DateTime.UtcNow;
                dto.Activo = true;

                var exists = await _repository.GetAllWithIncludesAsync(e => e.Rfc.ToLower() == dto.Rfc.ToLower() && e.Activo);
                if (exists.Any())
                {
                    return Conflict(new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Ya existe un proveedor activo con ese RFC",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                var entity = _mapper.Map<Proveedor>(dto);
                await _repository.AddAsync(entity);

                return CreatedAtAction(nameof(GetById), new { id = entity.PkidProveedor },
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
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return NotFound(new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = $"Proveedor con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                var dto = _mapper.Map<ProveedorDto>(response);
                dto.PkidProveedor = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Rfc.ToLower() == dto.Rfc.ToLower() && e.PkidProveedor != id && e.Activo);
                if (duplicate.Any())
                {
                    return Conflict(new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro proveedor activo con ese RFC",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    });
                }

                _mapper.Map(dto, entity);
                entity.FechaModificacion = dto.FechaModificacion;
                entity.UsuarioModificacion = dto.UsuarioModificacion;
                await _repository.UpdateAsync(entity);

                return Ok(new PagedResult<ProveedorResponse>
                {
                    Success = true,
                    Message = "Proveedor actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
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
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return NotFound(new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Proveedor con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });

                await _repository.DeleteAsync(id);
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
            var query = _context.VwProveedors.AsQueryable();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro;
                query = query.Where(e => e.Nombre.Contains(f) || e.Rfc.Contains(f) || e.Clave.Contains(f));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidProveedor" => isAscending ? query.OrderBy(e => e.PkidProveedor) : query.OrderByDescending(e => e.PkidProveedor),
                    "Nombre" => isAscending ? query.OrderBy(e => e.Nombre) : query.OrderByDescending(e => e.Nombre),
                    "Rfc" => isAscending ? query.OrderBy(e => e.Rfc) : query.OrderByDescending(e => e.Rfc),
                    "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                    "TipoProveedorNombre" => isAscending ? query.OrderBy(e => e.TipoProveedorDesc) : query.OrderByDescending(e => e.TipoProveedorDesc),
                    "EstatusProveedorNombre" => isAscending ? query.OrderBy(e => e.EstatusProveedorDesc) : query.OrderByDescending(e => e.EstatusProveedorDesc),
                    "MunicipioNombre" => isAscending ? query.OrderBy(e => e.MunicipioNombre) : query.OrderByDescending(e => e.MunicipioNombre),
                    "EstadoNombre" => isAscending ? query.OrderBy(e => e.EstadoNombre) : query.OrderByDescending(e => e.EstadoNombre),
                    "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                    _ => query.OrderBy(e => e.Nombre)
                };
            }
            else
            {
                query = query.OrderBy(e => e.Nombre);
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return Ok(new PagedResult<ProveedorResponse>
            {
                Items = _mapper.Map<List<ProveedorResponse>>(items),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
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

            return await GetAllPaginado(pagedRequest);
        }
    }
}