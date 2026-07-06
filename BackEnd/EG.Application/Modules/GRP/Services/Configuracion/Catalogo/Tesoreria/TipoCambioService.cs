using Mapster;
using Microsoft.Extensions.Logging;
using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria
{
    public class TipoCambioService : ITipoCambioService
    {
        private readonly ILogger<TipoCambioService> _logger;
        private readonly IRepository<TipoCambio> _repository;
        private readonly EGestionContext _context;

        public TipoCambioService(
            ILogger<TipoCambioService> logger,
            IRepository<TipoCambio> repository,
            EGestionContext context)
        {
            _logger = logger;
            _repository = repository;
            _context = context;
        }

        public async Task<TipoCambioResponse?> GetByIdAsync(int id)
        {
            var entity = await _context.VwTipoCambios.FirstOrDefaultAsync(e => e.PkidTipoCambio == id);
            return entity == null ? null : entity.Adapt<TipoCambioResponse>();
        }

        public async Task<TipoCambioResponse> CreateAsync(TipoCambioDto dto, int usuarioId)
        {
            var entity = dto.Adapt<TipoCambio>();
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = usuarioId;
            await _repository.AddAsync(entity);
            return entity.Adapt<TipoCambioResponse>();
        }

        public async Task<TipoCambioResponse?> UpdateAsync(int id, TipoCambioDto dto, int usuarioId)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;

            EG.Business.Services.EntityUpdateMapper.Apply(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = usuarioId;
            await _repository.UpdateAsync(entity);
            return entity.Adapt<TipoCambioResponse>();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) throw new KeyNotFoundException($"Registro con ID {id} no encontrado");
            await _repository.DeleteAsync(id);
        }

        public async Task<PagedResult<TipoCambioResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _context.VwTipoCambios.AsQueryable();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro;
                query = query.Where(e => e.MonedaDescripcion.Contains(f) || e.MonedaCodigo.Contains(f));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidTipoCambio" => isAscending ? query.OrderBy(e => e.PkidTipoCambio) : query.OrderByDescending(e => e.PkidTipoCambio),
                    "Cantidad" => isAscending ? query.OrderBy(e => e.Cantidad) : query.OrderByDescending(e => e.Cantidad),
                    "Fecha" => isAscending ? query.OrderBy(e => e.Fecha) : query.OrderByDescending(e => e.Fecha),
                    "MonedaDescripcion" => isAscending ? query.OrderBy(e => e.MonedaDescripcion) : query.OrderByDescending(e => e.MonedaDescripcion),
                    "MonedaCodigo" => isAscending ? query.OrderBy(e => e.MonedaCodigo) : query.OrderByDescending(e => e.MonedaCodigo),
                    "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                    _ => query.OrderBy(e => e.Fecha)
                };
            }
            else
            {
                query = query.OrderByDescending(e => e.Fecha);
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return new PagedResult<TipoCambioResponse>
            {
                Items = items.Adapt<List<TipoCambioResponse>>(),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }
    }
}
