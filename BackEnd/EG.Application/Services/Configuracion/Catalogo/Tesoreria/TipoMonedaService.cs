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
    public class TipoMonedaService : ITipoMonedaService
    {
        private readonly IRepository<TipoMonedum> _repository;

        public TipoMonedaService(
            IRepository<TipoMonedum> repository)
        {
            _repository = repository;
        }

        public async Task<TipoMonedaResponse?> GetByIdAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            return entity == null ? null : entity.Adapt<TipoMonedaResponse>();
        }

        public async Task<TipoMonedaResponse> CreateAsync(TipoMonedaDto dto, int usuarioId)
        {
            var entity = dto.Adapt<TipoMonedum>();
            entity.FkidPaisSis = 1;
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = usuarioId;
            await _repository.AddAsync(entity);
            return entity.Adapt<TipoMonedaResponse>();
        }

        public async Task<TipoMonedaResponse?> UpdateAsync(int id, TipoMonedaDto dto, int usuarioId)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;

            dto.Adapt(entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = usuarioId;
            await _repository.UpdateAsync(entity);
            return entity.Adapt<TipoMonedaResponse>();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) throw new KeyNotFoundException($"Registro con ID {id} no encontrado");
            await _repository.DeleteAsync(id);
        }

        public async Task<PagedResult<TipoMonedaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _repository.QueryWithIncludes(x => true);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro;
                query = query.Where(e => e.CodigoIso4217.Contains(f) || e.Descripcion.Contains(f));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidTipoMoneda" => isAscending ? query.OrderBy(e => e.PkidTipoMoneda) : query.OrderByDescending(e => e.PkidTipoMoneda),
                    "CodigoIso4217" => isAscending ? query.OrderBy(e => e.CodigoIso4217) : query.OrderByDescending(e => e.CodigoIso4217),
                    "Simbolo" => isAscending ? query.OrderBy(e => e.Simbolo) : query.OrderByDescending(e => e.Simbolo),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                    "Decimales" => isAscending ? query.OrderBy(e => e.Decimales) : query.OrderByDescending(e => e.Decimales),
                    "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                    _ => query.OrderBy(e => e.CodigoIso4217)
                };
            }
            else
            {
                query = query.OrderBy(e => e.CodigoIso4217);
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return new PagedResult<TipoMonedaResponse>
            {
                Items = items.Adapt<List<TipoMonedaResponse>>(),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }
    }
}
