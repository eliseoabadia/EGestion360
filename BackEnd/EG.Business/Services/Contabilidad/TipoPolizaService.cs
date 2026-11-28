using EG.Business.Services.Adquisicion;
using EG.Business.Services.PresupuestoModificado;
using Mapster;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services.Contabilidad
{
    public class TipoPolizaServiceOperations : global::EG.Business.Interfaces.Operations.ITipoPolizaService
    {
        private readonly GenericService<TipoPoliza, TipoPolizaDto, TipoPolizaResponse> _service;
        public TipoPolizaServiceOperations(GenericService<TipoPoliza, TipoPolizaDto, TipoPolizaResponse> service)
        {
            _service = service;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(tp => tp.UsuarioCreacionNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                var tpDto = dto as TipoPolizaDto;
                if (tpDto == null)
                    return true;
                return !_service.GetQueryWithIncludes().Any(e => e.Descripcion == tpDto.Descripcion && e.Activo);
            });
            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                var tpDto = dto as TipoPolizaDto;
                if (tpDto == null || !id.HasValue)
                    return true;
                return !_service.GetQueryWithIncludes().Any(e => e.Descripcion == tpDto.Descripcion && e.PkidTipoPoliza != id.Value && e.Activo);
            });
        }

        public async Task<IEnumerable<TipoPolizaResponse>> GetAllAsync()
        {
            return await _service.GetAllAsync();
        }

        public async Task<TipoPolizaResponse?> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id);
        }

        public async Task<TipoPolizaResponse> AddAsync(TipoPolizaDto dto, int usuarioId)
        {
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.UtcNow;
            await _service.AddAsync(dto);
            var entities = await _service.GetAllAsync();
            return entities.LastOrDefault();
        }

        public async Task UpdateAsync(int id, TipoPolizaDto dto, int usuarioId)
        {
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.UtcNow;
            await _service.UpdateAsync(id, dto);
        }

        public async Task DeleteAsync(int id)
        {
            var existing = await GetByIdAsync(id);
            if (existing == null)
                throw new KeyNotFoundException($"TipoPoliza no encontrado");
            var dto = new TipoPolizaDto
            {
                PkidTipoPoliza = existing.PkidTipoPoliza,
                Descripcion = existing.Descripcion,
                Activo = false
            };
            await _service.UpdateAsync(id, dto);
        }

        public async Task<PagedResult<TipoPolizaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _service.GetQueryWithIncludes();
            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e => e.Descripcion.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = request.SortDirection?.ToString().ToLower() == "asc";
                query = request.SortLabel switch
                {
                    "PkidTipoPoliza" => isAscending ? query.OrderBy(e => e.PkidTipoPoliza) : query.OrderByDescending(e => e.PkidTipoPoliza),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                    _ => query.OrderBy(e => e.Descripcion)};
            }

            var totalItems = await query.CountAsync();
            var items = await query.Skip((request.Page - 1) * request.PageSize).Take(request.PageSize).ToListAsync();
            return new PagedResult<TipoPolizaResponse>
            {
                Items = items.Adapt<List<TipoPolizaResponse>>(),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }

        public async Task<bool> CanAddAsync(TipoPolizaDto dto)
        {
            return await _service.CanAddAsync(dto);
        }

        public async Task<bool> CanUpdateAsync(int id, TipoPolizaDto dto)
        {
            return await _service.CanUpdateAsync(id, dto);
        }
    }
}