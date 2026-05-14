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
    public class TipoDoctoClcService : ITipoDoctoClcService
    {
        private readonly IRepository<TipoDoctoClc> _repository;

        public TipoDoctoClcService(
            IRepository<TipoDoctoClc> repository)
        {
            _repository = repository;
        }

        public async Task<TipoDoctoClcResponse?> GetByIdAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            return entity == null ? null : entity.Adapt<TipoDoctoClcResponse>();
        }

        public async Task<TipoDoctoClcResponse> CreateAsync(TipoDoctoClcDto dto, int usuarioId)
        {
            var entity = dto.Adapt<TipoDoctoClc>();
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = usuarioId;
            await _repository.AddAsync(entity);
            return entity.Adapt<TipoDoctoClcResponse>();
        }

        public async Task<TipoDoctoClcResponse?> UpdateAsync(int id, TipoDoctoClcDto dto, int usuarioId)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;

            dto.Adapt(entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = usuarioId;
            await _repository.UpdateAsync(entity);
            return entity.Adapt<TipoDoctoClcResponse>();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) throw new KeyNotFoundException($"Registro con ID {id} no encontrado");
            await _repository.DeleteAsync(id);
        }

        public async Task<PagedResult<TipoDoctoClcResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _repository.QueryWithIncludes(x => true);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var f = request.Filtro;
                query = query.Where(e => e.Clave.Contains(f) || e.Nombre.Contains(f));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidTipoDoctoClc" => isAscending ? query.OrderBy(e => e.PkidTipoDoctoClc) : query.OrderByDescending(e => e.PkidTipoDoctoClc),
                    "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                    "Nombre" => isAscending ? query.OrderBy(e => e.Nombre) : query.OrderByDescending(e => e.Nombre),
                    "TipoRecurso" => isAscending ? query.OrderBy(e => e.TipoRecurso) : query.OrderByDescending(e => e.TipoRecurso),
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

            return new PagedResult<TipoDoctoClcResponse>
            {
                Items = items.Adapt<List<TipoDoctoClcResponse>>(),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }
    }
}
