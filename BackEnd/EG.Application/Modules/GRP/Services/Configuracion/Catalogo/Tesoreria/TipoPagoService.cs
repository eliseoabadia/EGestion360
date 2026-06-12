using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria
{
    public class TipoPagoService : ITipoPagoService
    {
        private readonly IRepository<TipoPago> _repository;

        public TipoPagoService(
            IRepository<TipoPago> repository)
        {
            _repository = repository;
        }

        public async Task<TipoPagoResponse?> GetByIdAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            return entity == null ? null : entity.Adapt<TipoPagoResponse>();
        }

        public async Task<TipoPagoResponse> CreateAsync(TipoPagoDto dto, int usuarioId)
        {
            var entity = dto.Adapt<TipoPago>();
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = usuarioId;
            await _repository.AddAsync(entity);
            return entity.Adapt<TipoPagoResponse>();
        }

        public async Task<TipoPagoResponse?> UpdateAsync(int id, TipoPagoDto dto, int usuarioId)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;

            dto.Adapt(entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = usuarioId;
            await _repository.UpdateAsync(entity);
            return entity.Adapt<TipoPagoResponse>();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) throw new KeyNotFoundException($"Registro con ID {id} no encontrado");
            await _repository.DeleteAsync(id);
        }

        public async Task<PagedResult<TipoPagoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _repository.QueryWithIncludes(x => true);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro;
                query = query.Where(e => e.Descripcion.Contains(f));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidTipoPago" => isAscending ? query.OrderBy(e => e.PkidTipoPago) : query.OrderByDescending(e => e.PkidTipoPago),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
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

            return new PagedResult<TipoPagoResponse>
            {
                Items = items.Adapt<List<TipoPagoResponse>>(),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }
    }
}
