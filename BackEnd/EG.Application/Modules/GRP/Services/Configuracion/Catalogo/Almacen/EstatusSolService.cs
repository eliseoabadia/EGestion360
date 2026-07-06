using Mapster;
using Microsoft.Extensions.Logging;
using EG.Application.Interfaces.Configuracion.Catalogo.Almacen;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Almacen
{
    public class EstatusSolService : IEstatusSolService
    {
        private readonly ILogger<EstatusSolService> _logger;
        private readonly IRepository<EstatusSolicitud> _repository;

        public EstatusSolService(
            ILogger<EstatusSolService> logger,
            IRepository<EstatusSolicitud> repository)
        {
            _logger = logger;
            _repository = repository;
        }

        public async Task<EstatusSolicitudResponse?> GetByIdAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            return entity == null ? null : entity.Adapt<EstatusSolicitudResponse>();
        }

        public async Task<EstatusSolicitudResponse> CreateAsync(EstatusSolicitudDto dto, int usuarioId)
        {
            var entity = dto.Adapt<EstatusSolicitud>();
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = usuarioId;
            await _repository.AddAsync(entity);
            return entity.Adapt<EstatusSolicitudResponse>();
        }

        public async Task<EstatusSolicitudResponse?> UpdateAsync(int id, EstatusSolicitudDto dto, int usuarioId)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;

            EG.Business.Services.EntityUpdateMapper.Apply(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = usuarioId;
            await _repository.UpdateAsync(entity);
            return entity.Adapt<EstatusSolicitudResponse>();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) throw new KeyNotFoundException($"Registro con ID {id} no encontrado");
            await _repository.DeleteAsync(id);
        }

        public async Task<PagedResult<EstatusSolicitudResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _repository.QueryWithIncludes(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e => e.Descripcion.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidEstatusSolicitud" => isAscending ? query.OrderBy(e => e.PkidEstatusSolicitud) : query.OrderByDescending(e => e.PkidEstatusSolicitud),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                    "Color" => isAscending ? query.OrderBy(e => e.Color) : query.OrderByDescending(e => e.Color),
                    "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                    "FechaCreacion" => isAscending ? query.OrderBy(e => e.FechaCreacion) : query.OrderByDescending(e => e.FechaCreacion),
                    "UsuarioCreacion" => isAscending ? query.OrderBy(e => e.UsuarioCreacion) : query.OrderByDescending(e => e.UsuarioCreacion),
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

            return new PagedResult<EstatusSolicitudResponse>
            {
                Items = items.Adapt<List<EstatusSolicitudResponse>>(),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }

        public async Task<object> GetAllPaginadoAsync(int page, int pageSize, string? sortBy, string? sortDirection, string? filter)
        {
            var all = await _repository.GetAllAsync();

            if (!string.IsNullOrEmpty(sortBy))
            {
                var isAscending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                all = sortBy switch
                {
                    "PkidEstatusSolicitud" => isAscending ? all.OrderBy(e => e.PkidEstatusSolicitud) : all.OrderByDescending(e => e.PkidEstatusSolicitud),
                    "Descripcion" => isAscending ? all.OrderBy(e => e.Descripcion) : all.OrderByDescending(e => e.Descripcion),
                    "Color" => isAscending ? all.OrderBy(e => e.Color) : all.OrderByDescending(e => e.Color),
                    "Activo" => isAscending ? all.OrderBy(e => e.Activo) : all.OrderByDescending(e => e.Activo),
                    "FechaCreacion" => isAscending ? all.OrderBy(e => e.FechaCreacion) : all.OrderByDescending(e => e.FechaCreacion),
                    "UsuarioCreacion" => isAscending ? all.OrderBy(e => e.UsuarioCreacion) : all.OrderByDescending(e => e.UsuarioCreacion),
                    _ => all.OrderBy(e => e.Descripcion)
                };
            }
            else
            {
                all = all.OrderBy(e => e.Descripcion);
            }

            return new { Items = all.Skip((page - 1) * pageSize).Take(pageSize).ToList(), TotalCount = all.Count(), Page = page, PageSize = pageSize };
        }
    }
}
