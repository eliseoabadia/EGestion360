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
    public class SfService : ISfService
    {
        private readonly GenericService<Sf, SubFuncionDto, SubFuncionResponse> _service;
        private readonly GenericService<VwSubFuncion, SubFuncionDto, SubFuncionResponse> _serviceView;
        private readonly EGestionContext _context;

        public SfService(
            GenericService<Sf, SubFuncionDto, SubFuncionResponse> service,
            GenericService<VwSubFuncion, SubFuncionDto, SubFuncionResponse> serviceView,
            EGestionContext context)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
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
            return await _serviceView.GetAllAsync();
        }

        public async Task<SubFuncionResponse?> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id);
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
            var blockReason = await GetDeleteBlockReasonAsync(id);
            if (!string.IsNullOrWhiteSpace(blockReason))
            {
                throw new InvalidOperationException(blockReason);
            }

            var affectedRows = await _context.Sfs
                .Where(e => e.PkidSf == id && e.Activo)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(e => e.Activo, false)
                    .SetProperty(e => e.FechaModificacion, DateTime.UtcNow));

            if (affectedRows <= 0)
            {
                var exists = await _context.Sfs
                    .AsNoTracking()
                    .AnyAsync(e => e.PkidSf == id);

                if (!exists)
                {
                    throw new KeyNotFoundException($"Sf con ID {id} no encontrado");
                }
            }

            var stillActive = await _context.Sfs
                .AsNoTracking()
                .AnyAsync(e => e.PkidSf == id && e.Activo);

            if (stillActive)
            {
                throw new InvalidOperationException($"No fue posible eliminar la subfuncion con ID {id}; el registro sigue activo en la base de datos.");
            }
        }

        public async Task<string?> GetDeleteBlockReasonAsync(int id)
        {
            var usage = await _service.GetQueryWithIncludes(e => e.PkidSf == id)
                .Select(e => new
                {
                    HasProgramas = e.Programas.Any(programa => programa.Activo)
                })
                .FirstOrDefaultAsync();

            if (usage == null)
            {
                throw new KeyNotFoundException($"Sf con ID {id} no encontrado");
            }

            return usage.HasProgramas
                ? "No se puede eliminar la subfuncion porque tiene programas activos asociados."
                : null;
        }

        public async Task<PagedResult<SubFuncionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _serviceView.GetQueryWithIncludes();

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                query = query.Where(e =>
                    e.SubFuncionClave.ToString().Contains(request.Filtro) ||
                    e.SubFuncionDescripcion.Contains(request.Filtro) ||
                    e.FuncionClave.ToString().Contains(request.Filtro) ||
                    e.FuncionDescripcion.Contains(request.Filtro));
            }

            if (!string.IsNullOrEmpty(request.SortLabel))
            {
                var isAscending = request.SortDirection?.ToString().ToLower() == "asc";
                query = request.SortLabel switch
                {
                    "PkidSf" => isAscending ? query.OrderBy(e => e.PkidSf) : query.OrderByDescending(e => e.PkidSf),
                    "Clave" => isAscending ? query.OrderBy(e => e.SubFuncionClave) : query.OrderByDescending(e => e.SubFuncionClave),
                    "Descripcion" => isAscending ? query.OrderBy(e => e.SubFuncionDescripcion) : query.OrderByDescending(e => e.SubFuncionDescripcion),
                    _ => query.OrderBy(e => e.SubFuncionClave)
                };
            }

            var totalItems = await query.CountAsync();
            var items = await query
                .Skip((request.Page - 1) * request.PageSize)
                .Take(request.PageSize)
                .ToListAsync();

            return new PagedResult<SubFuncionResponse>
            {
                Items = items.Adapt<List<SubFuncionResponse>>(),
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
