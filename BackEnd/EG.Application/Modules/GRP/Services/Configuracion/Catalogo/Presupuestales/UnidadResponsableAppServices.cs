using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class UnidadResponsableAppServices : IUnidadResponsableAppServices
    {
        private readonly IRepository<Area> _repository;
        private readonly EGestionContext _context;

        public UnidadResponsableAppServices(
            IRepository<Area> repository,
            EGestionContext context)
        {
            _repository = repository;
            _context = context;
        }

        public async Task<IEnumerable<UnidadResponsableResponse>> GetAllAsync()
        {
            var items = await _context.VwAreas.ToListAsync();
            var mapped = items.Adapt<List<UnidadResponsableResponse>>();
            var dict = mapped.ToDictionary(m => m.PkidUnidadResponsable);

            foreach (var item in mapped)
            {
                if (item.FkidAreaSis.HasValue && dict.ContainsKey(item.FkidAreaSis.Value))
                {
                    dict[item.FkidAreaSis.Value].Children.Add(item);
                }
            }

            return mapped.Where(m => !m.FkidAreaSis.HasValue).ToList();
        }

        public async Task<UnidadResponsableResponse> GetByIdAsync(int id)
        {
            var entity = await _context.VwAreas.FirstOrDefaultAsync(e => e.PkidArea == id);
            return entity == null ? null : entity.Adapt<UnidadResponsableResponse>();
        }

        public async Task<PagedResult<UnidadResponsableResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            try
            {
                var query = _context.VwAreas.AsQueryable();

                if (!string.IsNullOrWhiteSpace(pageRequest.Filtro))
                {
                    var f = pageRequest.Filtro;
                    query = query.Where(e => e.Clave.Contains(f) || e.Nombre.Contains(f) || e.AreaPadreNombre.Contains(f));
                }

                if (!string.IsNullOrEmpty(pageRequest.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(pageRequest.SortDirection) || pageRequest.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = pageRequest.SortLabel switch
                    {
                        "PkidUnidadResponsable" or "PkidArea" => isAscending ? query.OrderBy(e => e.PkidArea) : query.OrderByDescending(e => e.PkidArea),
                        "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                        "Descripcion" => isAscending ? query.OrderBy(e => e.Nombre) : query.OrderByDescending(e => e.Nombre),
                        "AreaPadreNombre" => isAscending ? query.OrderBy(e => e.AreaPadreNombre) : query.OrderByDescending(e => e.AreaPadreNombre),
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
                    .Skip((pageRequest.Page - 1) * pageRequest.PageSize)
                    .Take(pageRequest.PageSize)
                    .ToListAsync();

                return new PagedResult<UnidadResponsableResponse>
                {
                    Items = items.Adapt<List<UnidadResponsableResponse>>(),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<UnidadResponsableResponse>
                {
                    Success = false,
                    Message = $"Error interno: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<UnidadResponsableResponse> CreateAsync(UnidadResponsableResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos de la Unidad Responsable son requeridos");

            var dto = response.Adapt<UnidadResponsableDto>();
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaCreacion = DateTime.UtcNow;
            dto.Activo = true;

            var exists = await _repository.GetAllWithIncludesAsync(e => e.Clave.ToLower() == dto.Clave.ToLower() && e.Activo);
            if (exists.Any())
                throw new InvalidOperationException("Ya existe una Unidad Responsable activa con esa clave");

            var entity = dto.Adapt<Area>();
            await _repository.AddAsync(entity);

            return entity.Adapt<UnidadResponsableResponse>();
        }

        public async Task<UnidadResponsableResponse> UpdateAsync(int id, UnidadResponsableResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos de la Unidad Responsable son requeridos");

            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                throw new KeyNotFoundException($"Unidad Responsable con ID {id} no encontrada");

            var dto = response.Adapt<UnidadResponsableDto>();
            dto.PkidUnidadResponsable = id;
            dto.UsuarioModificacion = usuarioModificacion;
            dto.FechaModificacion = DateTime.UtcNow;

            var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Clave.ToLower() == dto.Clave.ToLower() && e.PkidArea != id && e.Activo);
            if (duplicate.Any())
                throw new InvalidOperationException("Ya existe otra Unidad Responsable activa con esa clave");

            EG.Business.Services.EntityUpdateMapper.Apply(dto, entity);
            entity.FechaModificacion = dto.FechaModificacion;
            entity.UsuarioModificacion = dto.UsuarioModificacion;
            await _repository.UpdateAsync(entity);

            return entity.Adapt<UnidadResponsableResponse>();
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null)
                return false;

            var hasChildren = await _repository.GetAllWithIncludesAsync(e => e.FkidAreaSis == id && e.Activo);
            if (hasChildren.Any())
                throw new InvalidOperationException("No se puede eliminar un área que tiene hijos activos");

            await _repository.DeleteAsync(id);
            return true;
        }
    }
}
