using Mapster;
using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.Adquisicion
{
    public class ProveedorAppService : IProveedorAppService
    {
        private readonly ILogger<ProveedorAppService> _logger;
        private readonly IRepository<Proveedor> _repository;
        private readonly EGestionContext _context;

        public ProveedorAppService(
            ILogger<ProveedorAppService> logger,
            IRepository<Proveedor> repository,
            EGestionContext context)
        {
            _logger = logger;
            _repository = repository;
            _context = context;
        }

        public async Task<PagedResult<ProveedorResponse>> GetAllAsync()
        {
            try
            {
                var items = await _context.VwProveedors.ToListAsync();
                return new PagedResult<ProveedorResponse>
                {
                    Items = items.Adapt<List<ProveedorResponse>>(),
                    TotalCount = items.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAll de Proveedor");
                return new PagedResult<ProveedorResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ProveedorResponse>> GetByIdAsync(int id)
        {
            try
            {
                var entity = await _context.VwProveedors.FirstOrDefaultAsync(e => e.PkidProveedor == id);
                if (entity == null)
                    return new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Proveedor no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                var response = entity.Adapt<ProveedorResponse>();
                return new PagedResult<ProveedorResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<ProveedorResponse> { response },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetById de Proveedor para ID {Id}", id);
                return new PagedResult<ProveedorResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ProveedorResponse>> CreateAsync(ProveedorResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<ProveedorDto>();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.UtcNow;
                dto.FechaAlta = DateTime.UtcNow;
                dto.Activo = true;

                var exists = await _repository.GetAllWithIncludesAsync(e => e.Rfc.ToLower() == dto.Rfc.ToLower() && e.Activo);
                if (exists.Any())
                {
                    return new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Ya existe un proveedor activo con ese RFC",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                var entity = dto.Adapt<Proveedor>();
                await _repository.AddAsync(entity);

                return new PagedResult<ProveedorResponse>
                {
                    Success = true,
                    Message = "Proveedor creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = $"Error al crear proveedor: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ProveedorResponse>> UpdateAsync(int id, ProveedorResponse response, int usuarioActual)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = $"Proveedor con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                var dto = response.Adapt<ProveedorDto>();
                dto.PkidProveedor = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.UtcNow;

                var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Rfc.ToLower() == dto.Rfc.ToLower() && e.PkidProveedor != id && e.Activo);
                if (duplicate.Any())
                {
                    return new PagedResult<ProveedorResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro proveedor activo con ese RFC",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                dto.Adapt(entity);
                entity.FechaModificacion = dto.FechaModificacion;
                entity.UsuarioModificacion = dto.UsuarioModificacion;
                await _repository.UpdateAsync(entity);

                return new PagedResult<ProveedorResponse>
                {
                    Success = true,
                    Message = "Proveedor actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ProveedorResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Proveedor con ID {id} no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                await _repository.DeleteAsync(id);
                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Proveedor eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ProveedorResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
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

                return new PagedResult<ProveedorResponse>
                {
                    Items = items.Adapt<List<ProveedorResponse>>(),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAllPaginado de Proveedor");
                return new PagedResult<ProveedorResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }
    }
}
