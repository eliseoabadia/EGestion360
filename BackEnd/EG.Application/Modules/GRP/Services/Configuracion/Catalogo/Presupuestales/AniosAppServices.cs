using Mapster;
using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class AniosAppServices : IAniosAppServices
    {
        private readonly GenericService<Anio, AniosDto, AniosResponse> _service;
        private readonly EGestionContext _context;

        public AniosAppServices(
            GenericService<Anio, AniosDto, AniosResponse> service,
            EGestionContext context)
        {
            _service = service;
            _context = context;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueAnio", async (dto) =>
            {
                var itemDto = dto as AniosDto;
                if (itemDto == null) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.Clave == itemDto.Clave && a.Activo);
            });

            _service.AddValidationRuleWithId("UniqueAnioUpdate", async (dto, id) =>
            {
                var itemDto = dto as AniosDto;
                if (itemDto == null || !id.HasValue) return true;
                return !await _service.GetQueryWithIncludes()
                    .AnyAsync(a => a.Clave == itemDto.Clave && a.PkidAnio != id.Value && a.Activo);
            });
        }

        public async Task<IEnumerable<AniosResponse>> GetAllAsync()
        {
            return await _context.Anios
                .AsNoTracking()
                .OrderByDescending(x => x.Clave)
                .Select(x => new AniosResponse
                {
                    PkidAnio = x.PkidAnio,
                    Clave = x.Clave,
                    Descripcion = string.Empty,
                    Activo = x.Activo,
                    FechaCreacion = x.FechaCreacion
                })
                .ToListAsync();
        }

        public async Task<AniosResponse> GetByIdAsync(int id)
        {
            return await _service.GetByIdAsync(id, idPropertyName: "PkidAnio");
        }

        public async Task<PagedResult<AniosResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<AniosResponse, bool>? predicate = null)
        {
            try
            {
                pageRequest.Page = pageRequest.Page < 1 ? 1 : pageRequest.Page;
                pageRequest.PageSize = pageRequest.PageSize < 1 ? 100 : pageRequest.PageSize;

                var query = _context.Anios.AsNoTracking();

                if (!string.IsNullOrWhiteSpace(pageRequest.Filtro))
                {
                    var filtro = pageRequest.Filtro.Trim();
                    if (int.TryParse(filtro, out var clave))
                    {
                        query = query.Where(x => x.Clave == clave);
                    }
                }

                var descending = string.Equals(pageRequest.SortDirection, "Descending", StringComparison.OrdinalIgnoreCase);
                query = pageRequest.SortLabel?.ToLowerInvariant() switch
                {
                    "pkidanio" => descending ? query.OrderByDescending(x => x.PkidAnio) : query.OrderBy(x => x.PkidAnio),
                    "activo" => descending ? query.OrderByDescending(x => x.Activo) : query.OrderBy(x => x.Activo),
                    "fechacreacion" => descending ? query.OrderByDescending(x => x.FechaCreacion) : query.OrderBy(x => x.FechaCreacion),
                    _ => descending ? query.OrderByDescending(x => x.Clave) : query.OrderBy(x => x.Clave)
                };

                var totalCount = await query.CountAsync();
                var items = await query
                    .Skip((pageRequest.Page - 1) * pageRequest.PageSize)
                    .Take(pageRequest.PageSize)
                    .Select(x => new AniosResponse
                    {
                        PkidAnio = x.PkidAnio,
                        Clave = x.Clave,
                        Descripcion = string.Empty,
                        Activo = x.Activo,
                        FechaCreacion = x.FechaCreacion
                    })
                    .ToListAsync();

                if (predicate != null)
                    items = items.Where(predicate).ToList();

                return new PagedResult<AniosResponse>
                {
                    Success = true,
                    Message = "Años obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = totalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<AniosResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    Items = new List<AniosResponse>(),
                    TotalCount = 0
                };
            }
        }

        public async Task<AniosResponse> CreateAsync(AniosResponse response, int usuarioCreacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del año son requeridos");

            var dto = response.Adapt<AniosDto>();
            dto.Activo = true;
            dto.FechaCreacion = DateTime.Now;
            dto.UsuarioCreacion = usuarioCreacion;
            dto.FechaModificacion = null;
            dto.UsuarioModificacion = null;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un Año activo con esa clave");

            await _service.AddAsync(dto);
            return await _service.GetByIdAsync(dto.PkidAnio, idPropertyName: "PkidAnio");
        }

        public async Task<AniosResponse> UpdateAsync(int id, AniosResponse response, int usuarioModificacion)
        {
            if (response == null)
                throw new ArgumentNullException(nameof(response), "Los datos del año son requeridos");

            if (id <= 0)
                throw new ArgumentException("ID de año inválido", nameof(id));

            var dto = response.Adapt<AniosDto>();
            dto.PkidAnio = id;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioModificacion;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro Año activo con esa clave");

            await _service.UpdateAsync(id, dto);
            return await _service.GetByIdAsync(id, idPropertyName: "PkidAnio");
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de año inválido", nameof(id));

            var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidAnio");
            if (entity == null)
                return false;

            var dto = entity.Adapt<AniosDto>();
            dto.Activo = false;
            dto.FechaModificacion = DateTime.Now;
            dto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, dto);
            return true;
        }

        public async Task<bool> ExistsAsync(int id)
        {
            try
            {
                var entity = await _service.GetByIdAsync(id, idPropertyName: "PkidAnio");
                return entity != null;
            }
            catch
            {
                return false;
            }
        }
    }
}
