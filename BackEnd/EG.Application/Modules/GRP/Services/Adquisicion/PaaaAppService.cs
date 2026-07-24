using Mapster;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using System.Text.Json;

namespace EG.Application.Services.Adquisicion
{
    public class PaaaAppService : IPaaaAppService
    {
        private readonly GenericService<Paaa, PaaaDto, PaaaResponse> _service;
        private readonly GenericService<VwPaaa, PaaaDto, PaaaResponse> _serviceView;
        private readonly IRepository<Paaaspartidum> _partidaRepository;
        private readonly EGestionContext _context;

        public PaaaAppService(
            GenericService<Paaa, PaaaDto, PaaaResponse> service,
            GenericService<VwPaaa, PaaaDto, PaaaResponse> serviceView,
            IRepository<Paaaspartidum> partidaRepository,
            EGestionContext context)
        {
            _service = service;
            _serviceView = serviceView;
            _partidaRepository = partidaRepository;
            _context = context;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            _service.AddInclude(e => e.FkidAnioSisNavigation);
            _service.AddInclude(e => e.FkidAreaSisNavigation);
            _service.AddInclude(e => e.FkidPersonaNomNavigation);
            _service.AddInclude(e => e.FkidProyectoOrcoNavigation);
            _service.AddInclude(e => e.FkidProgramaPresNavigation);
            _service.AddInclude(e => e.FkidFuenteFinanciamientoPresNavigation);
            _service.AddInclude(e => e.Paaaspartida);
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRuleWithId("UniqueAreaAnio", async (dto, id) =>
            {
                var pDto = dto as PaaaDto;
                if (pDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.FkidAreaSis == pDto.FkidAreaSis
                        && x.FkidAnioSis == pDto.FkidAnioSis
                        && x.Activo
                        && (!id.HasValue || x.PkidPaaas != id.Value));
            });
        }

        public async Task<PagedResult<PaaaResponse>> GetAllAsync()
        {
            try
            {
                var items = await _serviceView.GetAllAsync();
                return new PagedResult<PaaaResponse>
                {
                    Items = items.ToList(),
                    TotalCount = items.Count(),
                    Success = true,
                    Message = "Programas anuales obtenidos correctamente",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaaResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PaaaResponse>> GetByIdAsync(int id)
        {
            try
            {
                var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidPaaas");
                if (result == null)
                    return new PagedResult<PaaaResponse>
                    {
                        Success = false, Message = "Programa anual no encontrado", Code = "NOT_FOUND", TotalCount = 0
                    };

                return new PagedResult<PaaaResponse>
                {
                    Success = true,
                    Message = "Programa anual encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<PaaaResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaaResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PaaaResponse>> CreateAsync(PaaaResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<PaaaDto>();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return new PagedResult<PaaaResponse>
                    {
                        Success = false,
                        Message = "Ya existe un programa anual activo para el mismo año y área",
                        Code = "DUPLICATE_AREA_ANIO",
                        TotalCount = 0
                    };
                }

                await _service.AddAsync(dto);

                return new PagedResult<PaaaResponse>
                {
                    Success = true,
                    Message = "Programa anual creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaaResponse>
                {
                    Success = false,
                    Message = $"Error al crear programa anual: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PaaaResponse>> UpdateAsync(int id, PaaaResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<PaaaDto>();
                dto.PkidPaaas = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return new PagedResult<PaaaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro programa anual activo para el mismo año y área",
                        Code = "DUPLICATE_AREA_ANIO",
                        TotalCount = 0
                    };
                }

                await _service.UpdateAsync(id, dto);

                return new PagedResult<PaaaResponse>
                {
                    Success = true,
                    Message = "Programa anual actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<PaaaResponse>
                {
                    Success = false,
                    Message = $"Programa anual con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaaResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Programa anual eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Programa anual con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PaaaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _serviceView.GetQueryWithIncludes();

                if (TryGetIntFilter(request, "FkidAnioSis", out var anioId))
                    query = query.Where(e => e.FkidAnioSis == anioId);

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var filtro = request.Filtro.Trim();
                    query = query.Where(e =>
                        (e.Descripcion != null && e.Descripcion.Contains(filtro)) ||
                        (e.AreaNombre != null && e.AreaNombre.Contains(filtro)) ||
                        (e.ResponsableCompleto != null && e.ResponsableCompleto.Contains(filtro)));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAsc = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidPaaas" => isAsc ? query.OrderBy(e => e.PkidPaaas) : query.OrderByDescending(e => e.PkidPaaas),
                        "Descripcion" => isAsc ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "AreaNombre" => isAsc ? query.OrderBy(e => e.AreaNombre) : query.OrderByDescending(e => e.AreaNombre),
                        "ResponsableCompleto" => isAsc ? query.OrderBy(e => e.ResponsableCompleto) : query.OrderByDescending(e => e.ResponsableCompleto),
                        "Fecha" => isAsc ? query.OrderBy(e => e.Fecha) : query.OrderByDescending(e => e.Fecha),
                        "Activo" => isAsc ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                        _ => query.OrderByDescending(e => e.PkidPaaas)
                    };
                }
                else
                {
                    query = query.OrderByDescending(e => e.PkidPaaas);
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return new PagedResult<PaaaResponse>
                {
                    Items = items.Adapt<List<PaaaResponse>>(),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaaResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PaaaspartidumResponse>> GetPartidasByPaaaAsync(int id)
        {
            try
            {
                var paaa = await _context.Paaas.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidPaaas == id && x.Activo);

                if (paaa == null)
                    return new PagedResult<PaaaspartidumResponse>
                    {
                        Success = false, Message = "PAAA no encontrado", Code = "NOT_FOUND", TotalCount = 0
                    };

                var partidas = await _context.VwPaaaspartida.AsNoTracking()
                    .Where(x => x.FkidPaaasOrco == id && x.Activo)
                    .OrderBy(x => x.PartidaClave)
                    .ToListAsync();

                var response = partidas.Adapt<List<PaaaspartidumResponse>>();

                return new PagedResult<PaaaspartidumResponse>
                {
                    Items = response,
                    TotalCount = response.Count,
                    Success = true,
                    Message = "Partidas obtenidas correctamente",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaaspartidumResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PaaasdetalleResponse>> GetDetallesByPartidaAsync(int partidaId)
        {
            try
            {
                var detalles = await _context.VwPaaasdetalles.AsNoTracking()
                    .Where(x => x.FkidPaaaspartidaOrco == partidaId && x.Activo)
                    .OrderBy(x => x.TipoBienCodigoClave)
                    .ThenBy(x => x.TipoBienDescripcion)
                    .ToListAsync();

                var response = detalles.Adapt<List<PaaasdetalleResponse>>();

                return new PagedResult<PaaasdetalleResponse>
                {
                    Items = response,
                    TotalCount = response.Count,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaasdetalleResponse>
                {
                    Success = false, Message = $"Error interno: {ex.Message}", Code = "ERROR", TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<LookupItem>> GetTiposBienByPartidaAsync(int partidaId, PagedRequest request)
        {
            try
            {
                var partida = await _context.Paaaspartida.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidPaaaspartida == partidaId && x.Activo);

                if (partida == null)
                    return new PagedResult<LookupItem>
                    {
                        Success = false,
                        Message = "Partida no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                var page = request.Page < 1 ? 1 : request.Page;
                var pageSize = request.PageSize <= 0 ? 25 : request.PageSize;
                var filtro = request.Filtro?.Trim() ?? string.Empty;

                var query = _context.TipoBiens.AsNoTracking()
                    .Where(x => x.Activo && x.FkidPartidaConta == partida.FkidPartidaConta);

                if (!string.IsNullOrWhiteSpace(filtro))
                {
                    query = query.Where(x =>
                        (x.CodigoClave != null && x.CodigoClave.Contains(filtro)) ||
                        (x.Descripcion != null && x.Descripcion.Contains(filtro)));
                }

                query = query.OrderBy(x => x.CodigoClave).ThenBy(x => x.Descripcion);

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(x => new LookupItem
                    {
                        Id = x.PkidTipoBien,
                        Text = (x.CodigoClave ?? string.Empty) + " - " + (x.Descripcion ?? string.Empty)
                    })
                    .ToListAsync();

                return new PagedResult<LookupItem>
                {
                    Items = items,
                    TotalCount = totalItems,
                    Success = true,
                    Message = "Tipos de bien obtenidos correctamente",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<LookupItem>
                {
                    Success = false,
                    Message = $"Error interno: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PaaaspartidumResponse>> CreatePartidaAsync(PaaaspartidaDto dto, int usuarioActual)
        {
            try
            {
                var entity = dto.Adapt<Paaaspartidum>();
                entity.FechaCreacion = DateTime.Now;
                entity.UsuarioCreacion = usuarioActual;

                await _partidaRepository.AddAsync(entity);

                var response = entity.Adapt<PaaaspartidumResponse>();

                return new PagedResult<PaaaspartidumResponse>
                {
                    Items = new List<PaaaspartidumResponse> { response },
                    TotalCount = 1,
                    Success = true,
                    Message = "Partida creada correctamente",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaaspartidumResponse>
                {
                    Success = false,
                    Message = $"Error al crear partida: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PaaasdetalleResponse>> CreateDetalleAsync(PaaasdetalleDto dto, int usuarioActual)
        {
            try
            {
                if (dto.FkidPaaaspartidaOrco <= 0 || dto.FkidTipoBienAlma <= 0 || dto.Cantidad <= 0)
                    return new PagedResult<PaaasdetalleResponse>
                    {
                        Success = false, Message = "Datos inválidos", Code = "INVALID_DATA", TotalCount = 0
                    };

                var partida = await _context.Paaaspartida.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidPaaaspartida == dto.FkidPaaaspartidaOrco && x.Activo);

                if (partida == null)
                    return new PagedResult<PaaasdetalleResponse>
                    {
                        Success = false, Message = "Partida no encontrada", Code = "NOT_FOUND", TotalCount = 0
                    };

                var tipoBien = await _context.TipoBiens.AsNoTracking()
                    .FirstOrDefaultAsync(x => x.PkidTipoBien == dto.FkidTipoBienAlma && x.Activo);

                if (tipoBien == null || tipoBien.FkidPartidaConta != partida.FkidPartidaConta)
                    return new PagedResult<PaaasdetalleResponse>
                    {
                        Success = false, Message = "Tipo de bien inválido para esta partida", Code = "INVALID_TIPO_BIEN", TotalCount = 0
                    };

                var entity = dto.Adapt<Paaasdetalle>();
                entity.FkidEmpresaSis = dto.FkidEmpresaSis > 0 ? dto.FkidEmpresaSis : partida.FkidEmpresaSis;
                entity.FkidUnidadesAlma = dto.FkidUnidadesAlma is > 0
                    ? dto.FkidUnidadesAlma
                    : tipoBien.FkidUnidadesAlma;
                entity.Activo = true;
                entity.FechaCreacion = DateTime.Now;
                entity.UsuarioCreacion = usuarioActual;

                await _context.Paaasdetalles.AddAsync(entity);
                await _context.SaveChangesAsync();

                var response = await GetDetalleResponseAsync(entity.PkidPaaasdetalle)
                    ?? entity.Adapt<PaaasdetalleResponse>();

                return new PagedResult<PaaasdetalleResponse>
                {
                    Data = response,
                    Items = new List<PaaasdetalleResponse> { response },
                    TotalCount = 1,
                    Success = true,
                    Message = "Tipo de bien agregado correctamente",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaasdetalleResponse>
                {
                    Success = false,
                    Message = $"Error al agregar tipo de bien: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PaaasdetalleResponse>> UpdateDetalleAsync(int detalleId, PaaasdetalleDto dto, int usuarioActual)
        {
            try
            {
                var entity = await _context.Paaasdetalles
                    .FirstOrDefaultAsync(x => x.PkidPaaasdetalle == detalleId && x.Activo);

                if (entity == null)
                    return new PagedResult<PaaasdetalleResponse>
                    {
                        Success = false, Message = "Detalle no encontrado", Code = "NOT_FOUND", TotalCount = 0
                    };

                if (dto.FkidTipoBienAlma > 0)
                {
                    var tipoBien = await _context.TipoBiens.AsNoTracking()
                        .FirstOrDefaultAsync(x => x.PkidTipoBien == dto.FkidTipoBienAlma && x.Activo);

                    entity.FkidUnidadesAlma = dto.FkidUnidadesAlma is > 0
                        ? dto.FkidUnidadesAlma
                        : tipoBien?.FkidUnidadesAlma;
                    entity.FkidTipoBienAlma = dto.FkidTipoBienAlma;
                }

                entity.FkidPaaaspartidaOrco = dto.FkidPaaaspartidaOrco;
                entity.Cantidad = dto.Cantidad;
                entity.Observaciones = dto.Observaciones ?? string.Empty;
                entity.LugarEntrega = dto.LugarEntrega ?? string.Empty;
                entity.FechaModificacion = DateTime.Now;
                entity.UsuarioModificacion = usuarioActual;

                await _context.SaveChangesAsync();

                var response = await GetDetalleResponseAsync(detalleId)
                    ?? entity.Adapt<PaaasdetalleResponse>();

                return new PagedResult<PaaasdetalleResponse>
                {
                    Data = response,
                    Items = new List<PaaasdetalleResponse> { response },
                    TotalCount = 1,
                    Success = true,
                    Message = "Tipo de bien actualizado correctamente",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PaaasdetalleResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar tipo de bien: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<bool>> DeleteDetalleAsync(int detalleId, int usuarioActual)
        {
            try
            {
                var entity = await _context.Paaasdetalles
                    .FirstOrDefaultAsync(x => x.PkidPaaasdetalle == detalleId && x.Activo);

                if (entity == null)
                    return new PagedResult<bool>
                    {
                        Success = false,
                        Message = "Detalle no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                entity.Activo = false;
                entity.FechaModificacion = DateTime.Now;
                entity.UsuarioModificacion = usuarioActual;
                await _context.SaveChangesAsync();

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Tipo de bien eliminado correctamente",
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
                    Message = $"Error al eliminar tipo de bien: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<bool>> DeletePartidaAsync(int partidaId, int usuarioActual)
        {
            try
            {
                var detalles = await _context.Paaasdetalles
                    .Where(d => d.FkidPaaaspartidaOrco == partidaId)
                    .ToListAsync();
                foreach (var detalle in detalles)
                {
                    detalle.Activo = false;
                    detalle.FechaModificacion = DateTime.Now;
                    detalle.UsuarioModificacion = usuarioActual;
                }

                await _partidaRepository.DeleteAsync(partidaId);

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Partida eliminada correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "Partida no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar partida: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        private async Task<PaaasdetalleResponse?> GetDetalleResponseAsync(int detalleId)
        {
            var view = await _context.VwPaaasdetalles.AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkidPaaasdetalle == detalleId && x.Activo);

            return view == null ? null : view.Adapt<PaaasdetalleResponse>();
        }

        private static bool TryGetIntFilter(PagedRequest request, string key, out int value)
        {
            value = 0;
            if (request.AdditionalFilters == null || !request.AdditionalFilters.TryGetValue(key, out var raw) || raw == null)
                return false;

            if (raw is JsonElement json)
            {
                if (json.ValueKind == JsonValueKind.Number && json.TryGetInt32(out value))
                    return true;

                if (json.ValueKind == JsonValueKind.String && int.TryParse(json.GetString(), out value))
                    return true;
            }

            return int.TryParse(raw.ToString(), out value);
        }
    }
}
