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
    public class FraccionAppService : IFraccionAppService
    {
        private readonly ILogger<FraccionAppService> _logger;
        private readonly IRepository<Fraccion> _repository;
        private readonly EGestionContext _context;

        public FraccionAppService(
            ILogger<FraccionAppService> logger,
            IRepository<Fraccion> repository,
            EGestionContext context)
        {
            _logger = logger;
            _repository = repository;
            _context = context;
        }

        public async Task<PagedResult<FraccionResponse>> GetAllAsync()
        {
            try
            {
                var items = await _context.VwFraccions.ToListAsync();
                return new PagedResult<FraccionResponse>
                {
                    Items = items.Adapt<List<FraccionResponse>>(),
                    TotalCount = items.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAll de Fraccion");
                return new PagedResult<FraccionResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<FraccionResponse>> GetByIdAsync(int id)
        {
            try
            {
                var entity = await _context.VwFraccions.FirstOrDefaultAsync(e => e.PkidFraccion == id);
                if (entity == null)
                    return new PagedResult<FraccionResponse>
                    {
                        Success = false,
                        Message = "Fracción no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                var response = entity.Adapt<FraccionResponse>();
                return new PagedResult<FraccionResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<FraccionResponse> { response },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetById de Fraccion para ID {Id}", id);
                return new PagedResult<FraccionResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<FraccionResponse>> CreateAsync(FraccionResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<FraccionDto>();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.UtcNow;
                dto.Activo = true;

                var exists = await _repository.GetAllWithIncludesAsync(e => e.Clave.ToLower() == dto.Clave.ToLower() && e.Activo);
                if (exists.Any())
                {
                    return new PagedResult<FraccionResponse>
                    {
                        Success = false,
                        Message = "Ya existe una fracción activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                var entity = dto.Adapt<Fraccion>();
                await _repository.AddAsync(entity);

                return new PagedResult<FraccionResponse>
                {
                    Success = true,
                    Message = "Fracción creada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FraccionResponse>
                {
                    Success = false,
                    Message = $"Error al crear fracción: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<FraccionResponse>> UpdateAsync(int id, FraccionResponse response, int usuarioActual)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return new PagedResult<FraccionResponse>
                    {
                        Success = false,
                        Message = $"Fracción con ID {id} no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                var dto = response.Adapt<FraccionDto>();
                dto.PkidFraccion = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.UtcNow;

                // Algunos registros historicos no exponen la clave en la vista. Al editar
                // otro campo se debe conservar la clave almacenada en vez de intentar
                // guardar una cadena vacia.
                dto.Clave = string.IsNullOrWhiteSpace(dto.Clave)
                    ? entity.Clave
                    : dto.Clave.Trim();
                dto.Descripcion = (dto.Descripcion ?? string.Empty).Trim();

                var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Clave.ToLower() == dto.Clave.ToLower() && e.PkidFraccion != id && e.Activo);
                if (duplicate.Any())
                {
                    return new PagedResult<FraccionResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra fracción activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                EG.Business.Services.EntityUpdateMapper.Apply(dto, entity);
                entity.FechaModificacion = dto.FechaModificacion;
                entity.UsuarioModificacion = dto.UsuarioModificacion;
                await _repository.UpdateAsync(entity);

                return new PagedResult<FraccionResponse>
                {
                    Success = true,
                    Message = "Fracción actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FraccionResponse>
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
                        Message = $"Fracción con ID {id} no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                await _repository.DeleteAsync(id);
                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Fracción eliminada correctamente",
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

        public async Task<PagedResult<FraccionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _context.VwFraccions.AsQueryable();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e => e.Clave.Contains(f) || e.Descripcion.Contains(f) || e.ArticuloDescripcion.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidFraccion" => isAscending ? query.OrderBy(e => e.PkidFraccion) : query.OrderByDescending(e => e.PkidFraccion),
                        "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                        "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "NombreArticulo" or "ArticuloDescripcion" => isAscending ? query.OrderBy(e => e.ArticuloDescripcion) : query.OrderByDescending(e => e.ArticuloDescripcion),
                        "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                        _ => query.OrderBy(e => e.Clave)
                    };
                }
                else
                {
                    query = query.OrderBy(e => e.Clave);
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return new PagedResult<FraccionResponse>
                {
                    Items = items.Adapt<List<FraccionResponse>>(),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAllPaginado de Fraccion");
                return new PagedResult<FraccionResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }
    }
}
