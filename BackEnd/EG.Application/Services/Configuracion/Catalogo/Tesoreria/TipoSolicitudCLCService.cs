using AutoMapper;
using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria
{
    public class TipoSolicitudCLCService : ITipoSolicitudCLCService
    {
        private readonly IRepository<TipoSolicitudClc> _repository;
        private readonly IMapper _mapper;

        public TipoSolicitudCLCService(
            IRepository<TipoSolicitudClc> repository,
            IMapper mapper)
        {
            _repository = repository;
            _mapper = mapper;
        }

        public async Task<TipoSolicitudCLCResponse?> GetByIdAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            return entity == null ? null : _mapper.Map<TipoSolicitudCLCResponse>(entity);
        }

        public async Task<TipoSolicitudCLCResponse> CreateAsync(TipoSolicitudCLCDto dto, int usuarioId)
        {
            var entity = _mapper.Map<TipoSolicitudClc>(dto);
            entity.FechaCreacion = DateTime.UtcNow;
            entity.UsuarioCreacion = usuarioId;
            await _repository.AddAsync(entity);
            return _mapper.Map<TipoSolicitudCLCResponse>(entity);
        }

        public async Task<TipoSolicitudCLCResponse?> UpdateAsync(int id, TipoSolicitudCLCDto dto, int usuarioId)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) return null;

            _mapper.Map(dto, entity);
            entity.FechaModificacion = DateTime.UtcNow;
            entity.UsuarioModificacion = usuarioId;
            await _repository.UpdateAsync(entity);
            return _mapper.Map<TipoSolicitudCLCResponse>(entity);
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await _repository.GetByIdAsync(id);
            if (entity == null) throw new KeyNotFoundException($"Registro con ID {id} no encontrado");
            await _repository.DeleteAsync(id);
        }

        public async Task<PagedResult<TipoSolicitudCLCResponse>> GetAllPaginadoAsync(PagedRequest request)
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
                    "PkidTipoSolicitudClc" => isAscending ? query.OrderBy(e => e.PkidTipoSolicitudClc) : query.OrderByDescending(e => e.PkidTipoSolicitudClc),
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

            return new PagedResult<TipoSolicitudCLCResponse>
            {
                Items = _mapper.Map<List<TipoSolicitudCLCResponse>>(items),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }
    }
}
