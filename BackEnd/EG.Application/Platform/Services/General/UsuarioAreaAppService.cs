using Mapster;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General
{
    public class UsuarioAreaAppService : IUsuarioAreaAppService
    {
        private readonly IRepository<VwUsuarioPersonaArea> _repository;
        private readonly EGestionContext _context;

        public UsuarioAreaAppService(IRepository<VwUsuarioPersonaArea> repository, EGestionContext context)
        {
            _repository = repository;
            _context = context;
        }

        public async Task<PagedResult<UsuarioAreaResponse>> GetAllAsync(int usuarioId)
        {
            try
            {
                var entities = await _repository.GetAllWithIncludesAsync(x => x.PkIdUsuario == usuarioId);
                var result = entities
                    .Where(e => e.PkidArea.HasValue && e.AreaActivo != false)
                    .Adapt<List<UsuarioAreaResponse>>();

                if (result.Count == 0)
                {
                    var personaId = await _context.Usuarios
                        .AsNoTracking()
                        .Where(x => x.PkIdUsuario == usuarioId && x.Activo)
                        .Select(x => x.FkidPersonaNom)
                        .FirstOrDefaultAsync();

                    if (personaId.HasValue)
                    {
                        result = await GetAreasPersonaViewAsync(personaId.Value);
                    }
                }

                return new PagedResult<UsuarioAreaResponse>
                {
                    Success = true,
                    Message = "Áreas del usuario obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result,
                    TotalCount = result.Count
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<UsuarioAreaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener áreas: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<UsuarioAreaResponse>> GetByPersonaAsync(int personaId)
        {
            try
            {
                var result = await GetAreasPersonaAsync(personaId);
                return Success(result, "Areas de la persona obtenidas correctamente");
            }
            catch (Exception ex)
            {
                return Error($"Error al obtener areas de la persona: {ex.Message}");
            }
        }

        public async Task<PagedResult<UsuarioAreaResponse>> AsignarAreaAsync(UsuarioAreaAsignacionRequest request, int usuarioActual)
        {
            try
            {
                if (request.PersonaId <= 0 || request.AreaId <= 0)
                {
                    return Error("Debe seleccionar una persona y un area validas", "VALIDATION");
                }

                var personaExiste = await _context.Personas
                    .AnyAsync(x => x.PkidPersona == request.PersonaId && x.Activo);
                if (!personaExiste)
                {
                    return Error("La persona seleccionada no existe o no esta activa", "NOT_FOUND");
                }

                var areaExiste = await _context.Areas
                    .AnyAsync(x => x.PkidArea == request.AreaId && x.Activo);
                if (!areaExiste)
                {
                    return Error("El area seleccionada no existe o no esta activa", "NOT_FOUND");
                }

                var asignacion = await _context.PersonaAreas
                    .FirstOrDefaultAsync(x =>
                        x.FkidPersonaNom == request.PersonaId &&
                        x.FkidAreaSis == request.AreaId);

                if (asignacion == null)
                {
                    asignacion = new PersonaArea
                    {
                        FkidPersonaNom = request.PersonaId,
                        FkidAreaSis = request.AreaId,
                        FechaCreacion = DateTime.Now,
                        UsuarioCreacion = usuarioActual
                    };
                    _context.PersonaAreas.Add(asignacion);
                }

                asignacion.IsAdscrito = request.IsAdscrito;
                asignacion.EsSolicitante = request.EsSolicitante;
                asignacion.EsAutorizador = request.EsAutorizador;
                asignacion.Activo = true;
                asignacion.FechaModificacion = DateTime.Now;
                asignacion.UsuarioModificacion = usuarioActual;

                await _context.SaveChangesAsync();

                var result = await GetAreasPersonaAsync(request.PersonaId);
                return Success(result, "Area asignada correctamente");
            }
            catch (Exception ex)
            {
                return Error($"Error al asignar area: {ex.Message}");
            }
        }

        public async Task<PagedResult<UsuarioAreaResponse>> EliminarAsignacionAsync(int personaAreaId, int usuarioActual)
        {
            try
            {
                var asignacion = await _context.PersonaAreas
                    .FirstOrDefaultAsync(x => x.PkidPersonaArea == personaAreaId);

                if (asignacion == null)
                {
                    return Error("La asignacion no existe", "NOT_FOUND");
                }

                asignacion.Activo = false;
                asignacion.FechaModificacion = DateTime.Now;
                asignacion.UsuarioModificacion = usuarioActual;

                await _context.SaveChangesAsync();

                var result = await GetAreasPersonaAsync(asignacion.FkidPersonaNom);
                return Success(result, "Area retirada correctamente");
            }
            catch (Exception ex)
            {
                return Error($"Error al retirar area: {ex.Message}");
            }
        }

        private async Task<List<UsuarioAreaResponse>> GetAreasPersonaAsync(int personaId)
        {
            var entities = await _context.PersonaAreas
                .AsNoTracking()
                .Include(x => x.FkidAreaSisNavigation)
                .Include(x => x.FkidPersonaNomNavigation)
                .Where(x =>
                    x.FkidPersonaNom == personaId &&
                    x.Activo &&
                    x.FkidAreaSisNavigation.Activo)
                .OrderBy(x => x.FkidAreaSisNavigation.Nombre)
                .ToListAsync();

            return entities.Select(ToResponse).ToList();
        }

        private async Task<List<UsuarioAreaResponse>> GetAreasPersonaViewAsync(int? personaId)
        {
            var query = _context.VwPersonaAreas
                .AsNoTracking()
                .Where(x => x.Activo && x.AreaId > 0);

            if (personaId.HasValue)
            {
                query = query.Where(x => x.PersonaId == personaId.Value);
            }

            var rows = await query
                .OrderBy(x => x.AreaClaveNombre)
                .ToListAsync();

            return rows
                .GroupBy(x => x.AreaId)
                .Select(x => ToResponse(x.First()))
                .OrderBy(x => x.UsuarioAreaDescripcion)
                .ToList();
        }

        private static UsuarioAreaResponse ToResponse(PersonaArea entity)
        {
            var persona = entity.FkidPersonaNomNavigation;
            var area = entity.FkidAreaSisNavigation;
            var areaClave = area?.Clave ?? string.Empty;
            var areaNombre = area?.Nombre ?? string.Empty;
            var areaDescripcion = string.IsNullOrWhiteSpace(areaClave)
                ? areaNombre
                : $"{areaClave} - {areaNombre}".Trim();

            return new UsuarioAreaResponse
            {
                PkidPersonaArea = entity.PkidPersonaArea,
                PkidPersona = entity.FkidPersonaNom,
                PersonaClave = persona?.Clave ?? string.Empty,
                PersonaNombre = persona?.Nombre ?? string.Empty,
                PersonaPaterno = persona?.Paterno ?? string.Empty,
                PersonaMaterno = persona?.Materno ?? string.Empty,
                IsAdscrito = entity.IsAdscrito,
                EsSolicitante = entity.EsSolicitante ?? false,
                EsAutorizador = entity.EsAutorizador ?? false,
                PkidArea = entity.FkidAreaSis,
                AreaClave = areaClave,
                AreaNombre = areaNombre,
                Activo = entity.Activo,
                UsuarioAreaDescripcion = areaDescripcion
            };
        }

        private static UsuarioAreaResponse ToResponse(VwPersonaArea entity)
        {
            return new UsuarioAreaResponse
            {
                PkidPersonaArea = entity.PkidPersonaArea,
                PkidPersona = entity.PersonaId,
                PersonaClave = entity.PersonaClaveNombre ?? string.Empty,
                PersonaNombre = entity.PersonaClaveNombre ?? string.Empty,
                IsAdscrito = entity.IsAdscrito,
                EsSolicitante = entity.EsSolicitante ?? false,
                EsAutorizador = entity.EsAutorizador ?? false,
                PkidArea = entity.AreaId,
                AreaClave = entity.AreaClave ?? string.Empty,
                AreaNombre = entity.AreaNombre ?? string.Empty,
                Activo = entity.Activo,
                UsuarioAreaDescripcion = string.IsNullOrWhiteSpace(entity.AreaClaveNombre)
                    ? $"{entity.AreaClave} - {entity.AreaNombre}".Trim(' ', '-')
                    : entity.AreaClaveNombre
            };
        }

        private static PagedResult<UsuarioAreaResponse> Success(
            List<UsuarioAreaResponse> items,
            string message)
        {
            return new PagedResult<UsuarioAreaResponse>
            {
                Success = true,
                Message = message,
                Code = "SUCCESS",
                Items = items,
                TotalCount = items.Count
            };
        }

        private static PagedResult<UsuarioAreaResponse> Error(string message, string code = "ERROR")
        {
            return new PagedResult<UsuarioAreaResponse>
            {
                Success = false,
                Message = message,
                Code = code,
                TotalCount = 0
            };
        }
    }
}
