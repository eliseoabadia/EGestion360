using Mapster;
using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio
{
    public class GrupoBienService : IGrupoBienService
    {
        private readonly IRepository<GrupoBien> _repository;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;
        private readonly ILogger<GrupoBienService> _logger;

        public GrupoBienService(
            IRepository<GrupoBien> repository,
            EGestionContext context,
            IUserContextService userContext,
            ILogger<GrupoBienService> logger)
        {
            _repository = repository;
            _context = context;
            _userContext = userContext;
            _logger = logger;
        }

        public async Task<PagedResult<GrupoBienResponse>> GetAllAsync()
        {
            try
            {
                var items = await _context.VwGrupoBiens.ToListAsync();
                return new PagedResult<GrupoBienResponse>
                {
                    Items = items.Adapt<List<GrupoBienResponse>>(),
                    TotalCount = items.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAll de GrupoBien");
                return new PagedResult<GrupoBienResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<GrupoBienResponse>> GetByIdAsync(int id)
        {
            try
            {
                var entity = await _context.VwGrupoBiens.FirstOrDefaultAsync(e => e.PkidGrupoBien == id);
                if (entity == null)
                    return new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" };

                var response = entity.Adapt<GrupoBienResponse>();
                return new PagedResult<GrupoBienResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<GrupoBienResponse> { response },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetById de GrupoBien para ID {Id}", id);
                return new PagedResult<GrupoBienResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<GrupoBienResponse>> CreateAsync(GrupoBienResponse request)
        {
            try
            {
                var dto = request.Adapt<GrupoBienDto>();
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                var exists = await _repository.GetAllWithIncludesAsync(e => e.Descripcion.ToLower() == dto.Descripcion.ToLower() && e.Activo);
                if (exists.Any())
                {
                    return new PagedResult<GrupoBienResponse>
                    {
                        Success = false,
                        Message = "Ya existe un grupo de bien con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                var entity = dto.Adapt<GrupoBien>();
                await _repository.AddAsync(entity);

                return new PagedResult<GrupoBienResponse>
                {
                    Success = true,
                    Message = "Grupo de bien creado correctamente",
                    Code = "SUCCESS",
                    Data = entity.Adapt<GrupoBienResponse>(),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<GrupoBienResponse>> UpdateAsync(int id, GrupoBienResponse request)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" };

                var dto = request.Adapt<GrupoBienDto>();
                dto.PkidGrupoBien = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Descripcion.ToLower() == dto.Descripcion.ToLower() && e.PkidGrupoBien != id && e.Activo);
                if (duplicate.Any())
                {
                    return new PagedResult<GrupoBienResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro grupo de bien con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                dto.Adapt(entity);
                entity.FechaModificacion = dto.FechaModificacion;
                entity.UsuarioModificacion = dto.UsuarioModificacion;
                await _repository.UpdateAsync(entity);

                return new PagedResult<GrupoBienResponse>
                {
                    Success = true,
                    Message = "Grupo de bien actualizado correctamente",
                    Code = "SUCCESS",
                    Data = entity.Adapt<GrupoBienResponse>(),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var entity = await _repository.GetByIdAsync(id);
                if (entity == null)
                    return new PagedResult<bool> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" };

                await _repository.DeleteAsync(id);
                return new PagedResult<bool> { Success = true, Message = "Grupo de bien eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<GrupoBienResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _context.VwGrupoBiens.AsQueryable();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e =>
                        e.Descripcion.Contains(f) ||
                        e.FamiliaDescripcion.Contains(f) ||
                        e.FamiliaClave.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidGrupoBien" => isAscending ? query.OrderBy(e => e.PkidGrupoBien) : query.OrderByDescending(e => e.PkidGrupoBien),
                        "GrupoBienDescripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "FamiliaDescripcion" => isAscending ? query.OrderBy(e => e.FamiliaDescripcion) : query.OrderByDescending(e => e.FamiliaDescripcion),
                        "FamiliaClave" => isAscending ? query.OrderBy(e => e.FamiliaClave) : query.OrderByDescending(e => e.FamiliaClave),
                        _ => query.OrderBy(e => e.Descripcion)
                    };
                }
                else
                {
                    query = query.OrderBy(e => e.Descripcion);
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return new PagedResult<GrupoBienResponse>
                {
                    Items = items.Adapt<List<GrupoBienResponse>>(),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAllPaginado de GrupoBien");
                return new PagedResult<GrupoBienResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<GrupoBienResponse>> GetGrupoBienAsync()
        {
            try
            {
                var items = await _context.GrupoBiens
                    .Where(g => (g.Clave ?? 0) > 2000 && g.Activo)
                    .OrderBy(g => g.ClaveCucop)
                    .Select(g => new GrupoBienResponse
                    {
                        PkidGrupoBien = g.PkidGrupoBien,
                        GrupoBienDescripcion = g.Descripcion,
                        GrupoBienClave = g.Clave,
                        ClaveAn = g.ClaveAn,
                        CabmAct = g.CabmAct,
                        ClaveCucop = g.ClaveCucop,
                        Activo = g.Activo
                    })
                    .ToListAsync();

                return new PagedResult<GrupoBienResponse>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = items.Count
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetGrupoBien");
                return new PagedResult<GrupoBienResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<List<LookupItem>> GetLookupAsync()
        {
            try
            {
                return await _context.GrupoBiens
                    .Where(g => (g.Clave ?? 0) > 2000 && g.Activo)
                    .OrderBy(g => g.ClaveAn)
                    .Select(g => new LookupItem
                    {
                        Id = g.PkidGrupoBien,
                        Text = (g.ClaveAn ?? "") + " / " + (g.CabmAct ?? "") + " / " + (g.Descripcion ?? "")
                    })
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetLookup de GrupoBien");
                return new List<LookupItem>();
            }
        }

        public async Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page = 1, int pageSize = 25, string? filter = null)
        {
            try
            {
                page = Math.Max(page, 1);
                pageSize = Math.Clamp(pageSize, 1, 100);

                var query = _context.GrupoBiens
                    .Where(g => (g.Clave ?? 0) > 2000 && g.Activo)
                    .OrderBy(g => g.ClaveAn)
                    .Select(g => new LookupItem
                    {
                        Id = g.PkidGrupoBien,
                        Text = (g.ClaveAn ?? "") + " / " + (g.CabmAct ?? "") + " / " + (g.Descripcion ?? "")
                    });

                if (!string.IsNullOrWhiteSpace(filter))
                {
                    var term = filter.Trim();
                    query = (IOrderedQueryable<LookupItem>)query.Where(x => x.Text.Contains(term));
                }

                var totalCount = await query.CountAsync();
                var items = await query
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                return new PagedResult<LookupItem>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = totalCount
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetLookupPaginado de GrupoBien");
                return new PagedResult<LookupItem>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }
    }
}
