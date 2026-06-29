using System.Text.Json;
using EG.Application.Interfaces.Patrimonio;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Mapster;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio
{
    public class ResguardoAppService : IResguardoAppService
    {
        private readonly GenericService<Resguardo, ResguardoDto, ResguardoResponse> _service;
        private readonly GenericService<VwResguardo, ResguardoDto, ResguardoResponse> _serviceView;
        private readonly EGestionContext _context;
        private readonly IUserContextService _userContext;

        public ResguardoAppService(
            GenericService<Resguardo, ResguardoDto, ResguardoResponse> service,
            GenericService<VwResguardo, ResguardoDto, ResguardoResponse> serviceView,
            EGestionContext context,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
            _userContext = userContext;
        }

        public async Task<PagedResult<ResguardoResponse>> GetAllAsync()
        {
            var items = (await _serviceView.GetAllAsync()).ToList();
            return Success(items, "Resguardos obtenidos correctamente", items.Count);
        }

        public async Task<PagedResult<ResguardoResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidResguardo");
            if (item == null)
            {
                return Failure<ResguardoResponse>($"Resguardo con ID {id} no encontrado.", "NOT_FOUND");
            }

            return new PagedResult<ResguardoResponse>
            {
                Success = true,
                Message = "Resguardo encontrado",
                Code = "SUCCESS",
                Data = item,
                Items = new List<ResguardoResponse> { item },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<ResguardoResponse>> CreateAsync(ResguardoResponse response, int usuarioActual)
        {
            var validation = Validate(response);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                _service.ApplyCurrentEmpresaIfPresent(response);

                var resguardo = new Resguardo
                {
                    Folio = await GenerateFolioAsync(response),
                    FkidEmpresaSis = response.FkidEmpresaSis,
                    FkidAreaSis = response.FkidAreaSis,
                    Responsable = await ResolveResponsableAsync(response),
                    Fecha = DateOnly.FromDateTime(response.FechaResguardo.Date),
                    Observaciones = response.Observaciones,
                    Activo = true,
                    FechaCreacion = DateTime.Now,
                    UsuarioCreacion = usuarioActual
                };

                _context.Resguardos.Add(resguardo);
                await _context.SaveChangesAsync();

                var refreshed = await GetByIdAsync(resguardo.PkidResguardo);
                refreshed.Message = "Resguardo creado correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<ResguardoResponse>($"Error al crear resguardo: {ex.Message}");
            }
        }

        public async Task<PagedResult<ResguardoResponse>> UpdateAsync(int id, ResguardoResponse response, int usuarioActual)
        {
            if (!await _context.Resguardos.AsNoTracking().AnyAsync(x => x.PkidResguardo == id && x.Activo))
            {
                return Failure<ResguardoResponse>($"Resguardo con ID {id} no encontrado.", "NOT_FOUND");
            }

            var validation = Validate(response);
            if (validation != null)
            {
                return validation;
            }

            try
            {
                _service.ApplyCurrentEmpresaIfPresent(response);

                var resguardo = await _context.Resguardos.FirstAsync(x => x.PkidResguardo == id && x.Activo);
                resguardo.Folio = string.IsNullOrWhiteSpace(response.Folio) ? resguardo.Folio : response.Folio.Trim();
                resguardo.FkidEmpresaSis = response.FkidEmpresaSis;
                resguardo.FkidAreaSis = response.FkidAreaSis;
                resguardo.Responsable = await ResolveResponsableAsync(response);
                resguardo.Fecha = DateOnly.FromDateTime(response.FechaResguardo.Date);
                resguardo.Observaciones = response.Observaciones;
                resguardo.FechaModificacion = DateTime.Now;
                resguardo.UsuarioModificacion = usuarioActual;

                await _context.SaveChangesAsync();

                var refreshed = await GetByIdAsync(id);
                refreshed.Message = "Resguardo actualizado correctamente.";
                return refreshed;
            }
            catch (Exception ex)
            {
                return Failure<ResguardoResponse>($"Error al actualizar resguardo: {ex.Message}");
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var resguardo = await _context.Resguardos.FirstOrDefaultAsync(x => x.PkidResguardo == id && x.Activo);
                if (resguardo == null)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = $"Resguardo con ID {id} no encontrado.",
                        Code = "NOT_FOUND",
                        Data = false,
                        TotalCount = 0
                    };
                }

                var tieneBienesActivos = await _context.ResguardoDetalles
                    .AnyAsync(x => x.FkidResguardoAlma == id && x.Activo);
                if (tieneBienesActivos)
                {
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = "No se puede eliminar un resguardo con bienes activos. Libera los bienes primero.",
                        Code = "ERROR",
                        Data = false,
                        TotalCount = 0
                    };
                }

                resguardo.Activo = false;
                resguardo.FechaModificacion = DateTime.Now;
                resguardo.UsuarioModificacion = _userContext.GetCurrentUserId();
                await _context.SaveChangesAsync();

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Resguardo eliminado correctamente.",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar resguardo: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ResguardoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (TryGetIntFilter(request, "FkidEmpresaSis", out var empresaId))
                {
                    query = query.Where(x => x.FkidEmpresaSis == empresaId);
                }

                if (TryGetIntFilter(request, "FkidAreaSis", out var areaId))
                {
                    query = query.Where(x => x.FkidAreaSis == areaId);
                }

                if (TryGetIntFilter(request, "FkidPersonaNom", out var personaId))
                {
                    query = query.Where(x => x.FkidPersonaNom == personaId);
                }

                var filtro = request.Filtro?.Trim();
                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.Folio != null && x.Folio.Contains(filtro)) ||
                        (x.PersonaNombre != null && x.PersonaNombre.Contains(filtro)) ||
                        (x.PersonaClave != null && x.PersonaClave.Contains(filtro)) ||
                        (x.AreaNombre != null && x.AreaNombre.Contains(filtro)) ||
                        (x.Observaciones != null && x.Observaciones.Contains(filtro)));
                }

                query = ApplySort(query, request.SortLabel, request.SortDirection);

                var total = await query.CountAsync();
                var page = Math.Max(1, request.Page);
                var pageSize = request.PageSize <= 0 ? 10 : request.PageSize;
                var items = await query.Skip((page - 1) * pageSize).Take(pageSize).ToListAsync();

                return Success(items.Adapt<List<ResguardoResponse>>(), "Resguardos obtenidos correctamente", total);
            }
            catch (Exception ex)
            {
                return Failure<ResguardoResponse>($"Error al obtener resguardos: {ex.Message}");
            }
        }

        private async Task<string> GenerateFolioAsync(ResguardoResponse response)
        {
            if (!string.IsNullOrWhiteSpace(response.Folio))
            {
                return response.Folio.Trim();
            }

            var year = response.FechaResguardo == default ? DateTime.Today.Year : response.FechaResguardo.Year;
            var prefix = $"RES-{year}-";
            var folios = await _context.Resguardos
                .Where(x => x.FkidEmpresaSis == response.FkidEmpresaSis && x.Folio.StartsWith(prefix))
                .Select(x => x.Folio)
                .ToListAsync();
            var next = folios
                .Select(x => int.TryParse(x.Substring(prefix.Length), out var value) ? value : 0)
                .DefaultIfEmpty(0)
                .Max() + 1;

            return $"{prefix}{next:00000}";
        }

        private async Task<string> ResolveResponsableAsync(ResguardoResponse response)
        {
            var persona = await _context.Personas
                .AsNoTracking()
                .Where(x => x.PkidPersona == response.FkidPersonaNom && x.Activo)
                .Select(x => new { x.Clave, x.Nombre, x.Paterno, x.Materno })
                .FirstOrDefaultAsync();

            if (persona != null)
            {
                var nombre = string.Join(" ", new[] { persona.Nombre, persona.Paterno, persona.Materno }
                    .Where(x => !string.IsNullOrWhiteSpace(x)));
                return string.IsNullOrWhiteSpace(nombre) ? persona.Clave : nombre;
            }

            if (!string.IsNullOrWhiteSpace(response.PersonaNombre))
            {
                return response.PersonaNombre.Trim();
            }

            if (!string.IsNullOrWhiteSpace(response.PersonaClave))
            {
                return response.PersonaClave.Trim();
            }

            return response.FkidPersonaNom.ToString();
        }

        private static PagedResult<ResguardoResponse>? Validate(ResguardoResponse response)
        {
            if (response.FkidEmpresaSis <= 0)
            {
                return Failure<ResguardoResponse>("Debe existir una empresa seleccionada.");
            }

            if (response.FkidPersonaNom <= 0)
            {
                return Failure<ResguardoResponse>("Debe seleccionar la persona responsable.");
            }

            if (response.FechaResguardo == default)
            {
                response.FechaResguardo = DateTime.Today;
            }

            response.Folio ??= string.Empty;
            response.Observaciones ??= string.Empty;
            response.Activo = true;

            return null;
        }

        private static IQueryable<VwResguardo> ApplySort(IQueryable<VwResguardo> query, string? sortLabel, string? sortDirection)
        {
            var ascending = string.IsNullOrEmpty(sortDirection) || sortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
            return sortLabel switch
            {
                "Folio" => ascending ? query.OrderBy(x => x.Folio) : query.OrderByDescending(x => x.Folio),
                "PersonaNombre" => ascending ? query.OrderBy(x => x.PersonaNombre) : query.OrderByDescending(x => x.PersonaNombre),
                "AreaNombre" => ascending ? query.OrderBy(x => x.AreaNombre) : query.OrderByDescending(x => x.AreaNombre),
                "FechaResguardo" => ascending ? query.OrderBy(x => x.FechaResguardo) : query.OrderByDescending(x => x.FechaResguardo),
                "TotalBienes" => ascending ? query.OrderBy(x => x.TotalBienes) : query.OrderByDescending(x => x.TotalBienes),
                _ => ascending ? query.OrderByDescending(x => x.PkidResguardo) : query.OrderBy(x => x.PkidResguardo)
            };
        }

        private static PagedResult<ResguardoResponse> Success(List<ResguardoResponse> items, string message, int total)
        {
            return new PagedResult<ResguardoResponse>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Items = items,
                TotalCount = total
            };
        }

        private static PagedResult<T> Failure<T>(string message, string code = "ERROR")
            where T : class
        {
            return new PagedResult<T>
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };
        }

        private static bool TryGetIntFilter(PagedRequest request, string key, out int value)
        {
            value = 0;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
            {
                return false;
            }

            if (raw is JsonElement json)
            {
                if (json.ValueKind == JsonValueKind.Number && json.TryGetInt32(out value))
                {
                    return true;
                }

                if (json.ValueKind == JsonValueKind.String && int.TryParse(json.GetString(), out value))
                {
                    return true;
                }
            }

            return int.TryParse(raw.ToString(), out value);
        }
    }
}
