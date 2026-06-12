using Mapster;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General
{
    public class AreaAppService : IAreaAppService
    {
        private readonly EGestionContext _context;

        public AreaAppService(EGestionContext context)
        {
            _context = context;
        }

        public async Task<PagedResult<AreaResponse>> GetAllAsync()
        {
            var items = await _context.Areas
                .AsNoTracking()
                .Where(x => x.Activo)
                .OrderBy(x => x.Nombre)
                .Select(x => new AreaResponse
                {
                    PkidArea = x.PkidArea,
                    Clave = x.Clave ?? string.Empty,
                    Descripcion = x.Nombre ?? string.Empty,
                    Activo = x.Activo,
                    FechaCreacion = x.FechaCreacion,
                    UsuarioCreacion = x.UsuarioCreacion
                })
                .ToListAsync();

            return new PagedResult<AreaResponse>
            {
                Items = items,
                TotalCount = items.Count,
                Success = true,
                Message = "Areas obtenidas correctamente",
                Code = "SUCCESS"
            };
        }

        public async Task<PagedResult<AreaResponse>> GetByIdAsync(int id)
        {
            var item = await _context.Areas
                .AsNoTracking()
                .Where(x => x.PkidArea == id && x.Activo)
                .Select(x => new AreaResponse
                {
                    PkidArea = x.PkidArea,
                    Clave = x.Clave ?? string.Empty,
                    Descripcion = x.Nombre ?? string.Empty,
                    Activo = x.Activo,
                    FechaCreacion = x.FechaCreacion,
                    UsuarioCreacion = x.UsuarioCreacion
                })
                .FirstOrDefaultAsync();

            if (item == null)
            {
                return new PagedResult<AreaResponse>
                {
                    Success = false,
                    Message = "Area no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }

            return new PagedResult<AreaResponse>
            {
                Data = item,
                Items = new List<AreaResponse> { item },
                TotalCount = 1,
                Success = true,
                Message = "Area obtenida correctamente",
                Code = "SUCCESS"
            };
        }

        public async Task<PagedResult<AreaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var query = _context.Areas.AsNoTracking().Where(x => x.Activo);

            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var filtro = request.Filtro.Trim();
                query = query.Where(x =>
                    (x.Clave != null && x.Clave.Contains(filtro)) ||
                    (x.Nombre != null && x.Nombre.Contains(filtro)));
            }

            var ascending = string.IsNullOrEmpty(request.SortDirection) ||
                request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);

            query = request.SortLabel switch
            {
                "Clave" => ascending ? query.OrderBy(x => x.Clave) : query.OrderByDescending(x => x.Clave),
                "Descripcion" => ascending ? query.OrderBy(x => x.Nombre) : query.OrderByDescending(x => x.Nombre),
                _ => ascending ? query.OrderBy(x => x.Nombre) : query.OrderByDescending(x => x.Nombre)
            };

            var total = await query.CountAsync();
            var page = Math.Max(1, request.Page);
            var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
            var items = await query
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(x => new AreaResponse
                {
                    PkidArea = x.PkidArea,
                    Clave = x.Clave ?? string.Empty,
                    Descripcion = x.Nombre ?? string.Empty,
                    Activo = x.Activo,
                    FechaCreacion = x.FechaCreacion,
                    UsuarioCreacion = x.UsuarioCreacion
                })
                .ToListAsync();

            return new PagedResult<AreaResponse>
            {
                Items = items,
                TotalCount = total,
                Success = true,
                Message = "Areas obtenidas correctamente",
                Code = "SUCCESS"
            };
        }

        public async Task<PagedResult<AreaResponse>> GetAreasByPersona(int personaId)
        {
            try
            {
                var areas = await _context.PersonaAreas
                    .Where(pa => pa.FkidPersonaNom == personaId && pa.Activo)
                    .Include(pa => pa.FkidAreaSisNavigation)
                    .Select(pa => new AreaResponse
                    {
                        PkidArea = pa.FkidAreaSis,
                        Clave = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.Clave : string.Empty,
                        Descripcion = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.Nombre : string.Empty,
                        Activo = pa.FkidAreaSisNavigation != null && pa.FkidAreaSisNavigation.Activo,
                        FechaCreacion = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.FechaCreacion : null,
                        UsuarioCreacion = pa.FkidAreaSisNavigation != null ? pa.FkidAreaSisNavigation.UsuarioCreacion : 0
                    })
                    .Distinct()
                    .ToListAsync();

                return new PagedResult<AreaResponse>
                {
                    Items = areas,
                    TotalCount = areas.Count,
                    Success = true,
                    Message = "Áreas obtenidas correctamente",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<AreaResponse>
                {
                    Success = false,
                    Message = $"Error interno: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
