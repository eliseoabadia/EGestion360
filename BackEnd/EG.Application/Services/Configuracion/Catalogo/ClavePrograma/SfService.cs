using AutoMapper;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Catalogos.ClavePrograma
{
    public class SfService : ISfService
    {
        private readonly GenericService<Sf, SubFuncionDto, SubFuncionResponse> _service;
        private readonly IMapper _mapper;

        public SfService(
            GenericService<Sf, SubFuncionDto, SubFuncionResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(s => s.FkidFnPresNavigation);
            _service.AddInclude(s => s.UsuarioCreacionNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                var sfDto = dto as SubFuncionDto;
                if (sfDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(e => e.Clave == sfDto.Clave && e.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                var sfDto = dto as SubFuncionDto;
                if (sfDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(e => e.Clave == sfDto.Clave && e.PkidSf != id.Value && e.Activo);
            });
        }

        public async Task<IEnumerable<SubFuncionResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<SubFuncionResponse?> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        public async Task<SubFuncionResponse> AddAsync(SubFuncionDto dto, int usuarioId)
        {
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.UtcNow;
            await _service.AddAsync(dto);
            var entities = await _service.GetAllAsync();
            return entities.LastOrDefault();
        }

        public async Task UpdateAsync(int id, SubFuncionDto dto, int usuarioId)
        {
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.UtcNow;
            await _service.UpdateAsync(id, dto);
        }

        public async Task DeleteAsync(int id)
        {
            var existing = await GetByIdAsync(id);
            if (existing == null) throw new KeyNotFoundException($"Sf con ID {id} no encontrado");

            var dto = new SubFuncionDto
            {
                PkidSf = existing.PkidSf,
                Clave = existing.Clave,
                Descripcion = existing.Descripcion,
                Activo = false,
                FkidFnPres = existing.FkidFnPres
            };

            await _service.UpdateAsync(id, dto);
        }

        public async Task<PagedResult<SubFuncionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _service.GetQueryWithIncludes();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e =>
                    e.Clave.ToString().Contains(request.Filtro) ||
                    e.Descripcion.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = request.SortDirection?.ToString().ToLower() == "asc";
                query = request.SortLabel switch
                {
                    "PkidSf" => isAscending ? query.OrderBy(e => e.PkidSf) : query.OrderByDescending(e => e.PkidSf),
                    "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                    _ => query.OrderBy(e => e.Clave)
                };
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return new PagedResult<SubFuncionResponse>
            {
                Items = _mapper.Map<List<SubFuncionResponse>>(items),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }

        public async Task<bool> CanAddAsync(SubFuncionDto dto)
        {
            return await _service.CanAddAsync(dto);
        }

        public async Task<bool> CanUpdateAsync(int id, SubFuncionDto dto)
        {
            return await _service.CanUpdateAsync(id, dto);
        }
    }
}
