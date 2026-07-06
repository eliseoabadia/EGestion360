using Mapster;
using Microsoft.Extensions.Logging;
using EG.Application.Interfaces.Contabilidad;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Contabilidad
{
    public class ConceptoService : IConceptoService
    {
        private readonly ILogger<ConceptoService> _logger;
        private readonly IRepository<Concepto> _repository;
        private readonly EGestionContext _context;

        public ConceptoService(
            ILogger<ConceptoService> logger,
            IRepository<Concepto> repository,
            EGestionContext context)
        {
            _logger = logger;
            _repository = repository;
            _context = context;
        }

        public async Task<PagedResult<ConceptoResponse>> GetAllAsync()
        {
            try
            {
                var items = await _context.VwConceptos.ToListAsync();
                return new PagedResult<ConceptoResponse>
                {
                    Items = items.Adapt<List<ConceptoResponse>>(),
                    TotalCount = items.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAll de Concepto");
                return new PagedResult<ConceptoResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<ConceptoResponse?> GetByIdAsync(int id)
        {
            try
            {
                var entity = await _context.VwConceptos.FirstOrDefaultAsync(e => e.PkidConcepto == id);
                if (entity == null) return null;
                return entity.Adapt<ConceptoResponse>();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetById de Concepto para ID {Id}", id);
                throw;
            }
        }

        public async Task<ConceptoResponse> CreateAsync(ConceptoResponse response, int usuarioId)
        {
            var dto = response.Adapt<ConceptoDto>();
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.UtcNow;
            dto.Activo = true;

            var exists = await _repository.GetAllWithIncludesAsync(e => e.Descripcion.ToLower() == dto.Descripcion.ToLower() && e.Activo);
            if (exists.Any())
                throw new InvalidOperationException("Ya existe un concepto con esa descripción");

            var entity = dto.Adapt<Concepto>();
            await _repository.AddAsync(entity);

            return entity.Adapt<ConceptoResponse>();
        }

        public async Task<ConceptoResponse?> UpdateAsync(int id, ConceptoResponse response, int usuarioId)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;

            var dto = response.Adapt<ConceptoDto>();
            dto.PkidConcepto = id;
            dto.UsuarioModificacion = usuarioId;
            dto.FechaModificacion = DateTime.UtcNow;

            var duplicate = await _repository.GetAllWithIncludesAsync(e => e.Descripcion.ToLower() == dto.Descripcion.ToLower() && e.PkidConcepto != id && e.Activo);
            if (duplicate.Any())
                throw new InvalidOperationException("Ya existe otro concepto con esa descripción");

            EG.Business.Services.EntityUpdateMapper.Apply(dto, entity);
            entity.FechaModificacion = dto.FechaModificacion;
            entity.UsuarioModificacion = dto.UsuarioModificacion;
            await _repository.UpdateAsync(entity);

            return entity.Adapt<ConceptoResponse>();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) throw new KeyNotFoundException($"Concepto con ID {id} no encontrado");
            await _repository.DeleteAsync(id);
        }

        public async Task<PagedResult<ConceptoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _context.VwConceptos.AsQueryable();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e => e.Descripcion.Contains(f) || e.Clave.Contains(f) || e.CapituloDescripcion.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidConcepto" => isAscending ? query.OrderBy(e => e.PkidConcepto) : query.OrderByDescending(e => e.PkidConcepto),
                        "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                        "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "CapituloDescripcion" => isAscending ? query.OrderBy(e => e.CapituloDescripcion) : query.OrderByDescending(e => e.CapituloDescripcion),
                        "CapituloClave" => isAscending ? query.OrderBy(e => e.CapituloClave) : query.OrderByDescending(e => e.CapituloClave),
                        "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
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

                return new PagedResult<ConceptoResponse>
                {
                    Items = items.Adapt<List<ConceptoResponse>>(),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error en GetAllPaginado de Concepto");
                return new PagedResult<ConceptoResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }
    }
}
