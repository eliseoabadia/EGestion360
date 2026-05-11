using AutoMapper;
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
    public class MotivoEsService : IMotivoEsService
    {
        private readonly ILogger<MotivoEsService> _logger;
        private readonly IRepository<Motivo> _repository;
        private readonly IMapper _mapper;

        public MotivoEsService(
            ILogger<MotivoEsService> logger,
            IRepository<Motivo> repository,
            IMapper mapper)
        {
            _logger = logger;
            _repository = repository;
            _mapper = mapper;
        }

        public async Task<MotivoEsResponse?> GetByIdAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            return entity == null ? null : _mapper.Map<MotivoEsResponse>(entity);
        }

        public async Task<MotivoEsResponse> CreateAsync(MotivoEsDto dto, int usuarioId)
        {
            var entity = _mapper.Map<Motivo>(dto);
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = usuarioId;
            await _repository.AddAsync(entity);
            return _mapper.Map<MotivoEsResponse>(entity);
        }

        public async Task<MotivoEsResponse?> UpdateAsync(int id, MotivoEsDto dto, int usuarioId)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;

            _mapper.Map(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = usuarioId;
            await _repository.UpdateAsync(entity);
            return _mapper.Map<MotivoEsResponse>(entity);
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) throw new KeyNotFoundException($"Registro con ID {id} no encontrado");
            await _repository.DeleteAsync(id);
        }

        public async Task<PagedResult<MotivoEsResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _repository.QueryWithIncludes(x => true);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e => e.Descripcion.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                query = request.SortLabel switch
                {
                    "PkidMotivoEs" => isAscending ? query.OrderBy(e => e.PkidMotivoEs) : query.OrderByDescending(e => e.PkidMotivoEs),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                    "AplicaEntrada" => isAscending ? query.OrderBy(e => e.AplicaEntrada) : query.OrderByDescending(e => e.AplicaEntrada),
                    "AplicaSalida" => isAscending ? query.OrderBy(e => e.AplicaSalida) : query.OrderByDescending(e => e.AplicaSalida),
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

            return new PagedResult<MotivoEsResponse>
            {
                Items = _mapper.Map<List<MotivoEsResponse>>(items),
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
                    "PkidMotivoEs" => isAscending ? all.OrderBy(e => e.PkidMotivoEs) : all.OrderByDescending(e => e.PkidMotivoEs),
                    "Descripcion" => isAscending ? all.OrderBy(e => e.Descripcion) : all.OrderByDescending(e => e.Descripcion),
                    "AplicaEntrada" => isAscending ? all.OrderBy(e => e.AplicaEntrada) : all.OrderByDescending(e => e.AplicaEntrada),
                    "AplicaSalida" => isAscending ? all.OrderBy(e => e.AplicaSalida) : all.OrderByDescending(e => e.AplicaSalida),
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
