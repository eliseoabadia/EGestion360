using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Services.Catalogos.ClavePrograma
{
    public class FnService : IFnService
    {
        private readonly GenericService<Fn, FnDto, FnResponse> _service;
        private readonly GenericService<VwFn, FnDto, FnResponse> _serviceView;

        public FnService(
            GenericService<Fn, FnDto, FnResponse> service,
            GenericService<VwFn, FnDto, FnResponse> serviceView)
        {
            _service = service;
            _serviceView = serviceView;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(f => f.FkidGfPresNavigation);
            _service.AddInclude(f => f.UsuarioCreacionNavigation);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                var fnDto = dto as FnDto;
                if (fnDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(e => e.Clave == fnDto.Clave && e.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                var fnDto = dto as FnDto;
                if (fnDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(e => e.Clave == fnDto.Clave && e.PkidFn != id.Value && e.Activo);
            });
        }

        public async Task<IEnumerable<FnResponse>> GetAllAsync()
        {
            return await _serviceView.GetAllAsync();
        }

        public async Task<FnResponse?> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id);
        }

        public async Task<FnResponse> AddAsync(FnDto dto, int usuarioId)
        {
            dto.UsuarioCreacion = usuarioId;
            dto.FechaCreacion = DateTime.UtcNow;
            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidFn) ?? dto.Adapt<FnResponse>();
        }

        public async Task UpdateAsync(int id, FnDto dto, int usuarioId)
        {
            var existing = await _serviceView.GetByIdAsync(id);
            dto.UsuarioCreacion = existing?.UsuarioCreacion ?? usuarioId;
            dto.FechaCreacion = existing?.FechaCreacion ?? DateTime.UtcNow;
            await _service.UpdateAsync(id, dto);
        }

        public async Task DeleteAsync(int id)
        {
            var existing = await _serviceView.GetByIdAsync(id);
            if (existing == null) throw new KeyNotFoundException($"Fn con ID {id} no encontrado");

            var dto = new FnDto
            {
                PkidFn = existing.PkidFn,
                Clave = existing.Clave,
                Descripcion = existing.Descripcion,
                Activo = false,
                FkidGfPres = existing.FkidGfPres,
                UsuarioCreacion = existing.UsuarioCreacion,
                FechaCreacion = existing.FechaCreacion
            };

            await _service.UpdateAsync(id, dto);
        }

        public async Task<PagedResult<FnResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _serviceView.GetQueryWithIncludes();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e =>
                    e.Clave.ToString().Contains(request.Filtro) ||
                    e.Descripcion.Contains(request.Filtro) ||
                    e.ClaveNombre.Contains(request.Filtro) ||
                    e.Gfclave.ToString().Contains(request.Filtro) ||
                    e.Gfdescripcion.Contains(request.Filtro) ||
                    e.GfclaveNombre.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = request.SortDirection?.ToString().ToLower() == "asc";
                query = request.SortLabel switch
                {
                    "PkidFn" => isAscending ? query.OrderBy(e => e.PkidFn) : query.OrderByDescending(e => e.PkidFn),
                    "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                    "GfClave" => isAscending ? query.OrderBy(e => e.Gfclave) : query.OrderByDescending(e => e.Gfclave),
                    "GfDescripcion" => isAscending ? query.OrderBy(e => e.Gfdescripcion) : query.OrderByDescending(e => e.Gfdescripcion),
                    _ => query.OrderBy(e => e.Clave)
                };
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return new PagedResult<FnResponse>
            {
                Items = items.Adapt<List<FnResponse>>(),
                TotalCount = totalItems,
                Success = true,
                Message = "OK",
                Code = "SUCCESS"
            };
        }

        public async Task<bool> CanAddAsync(FnDto dto)
        {
            return await _service.CanAddAsync(dto);
        }

        public async Task<bool> CanUpdateAsync(int id, FnDto dto)
        {
            return await _service.CanUpdateAsync(id, dto);
        }
    }
}
