using Mapster;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio
{
    public class PersonaService : IPersonaService
    {
        private readonly GenericService<Persona, PersonaDto, PersonaResponse> _service;
        private readonly IUserContextService _userContext;

        public PersonaService(
            GenericService<Persona, PersonaDto, PersonaResponse> service,
            IUserContextService userContext)
        {
            _service = service;
            _userContext = userContext;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.PkidPersona != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<PersonaResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return new PagedResult<PersonaResponse>
                {
                    Success = true,
                    Message = "Personas obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PersonaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener personas: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PersonaResponse>> GetByIdAsync(int id)
        {
            try
            {
                var entity = await _service.GetQueryWithIncludes().FirstOrDefaultAsync(e => e.PkidPersona == id);
                if (entity == null)
                    return new PagedResult<PersonaResponse> { Success = false, Message = "Persona no encontrada", Code = "NOT_FOUND" };

                var result = entity.Adapt<PersonaResponse>();
                return new PagedResult<PersonaResponse>
                {
                    Success = true,
                    Message = "Persona obtenida correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<PersonaResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PersonaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener persona: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PersonaResponse>> CreateAsync(PersonaResponse request)
        {
            try
            {
                var dto = request.Adapt<PersonaDto>();
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;
                NormalizeForPersistence(dto);

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Clave == dto.Clave && x.Activo);

                return new PagedResult<PersonaResponse>
                {
                    Success = true,
                    Message = "Persona creada correctamente",
                    Code = "SUCCESS",
                    Data = created != null ? created.Adapt<PersonaResponse>() : null,
                    Items = created != null ? new List<PersonaResponse> { created.Adapt<PersonaResponse>() } : new List<PersonaResponse>(),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PersonaResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<PersonaResponse>> UpdateAsync(int id, PersonaResponse request)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return new PagedResult<PersonaResponse> { Success = false, Message = "Persona no encontrada", Code = "NOT_FOUND" };

                var dto = request.Adapt<PersonaDto>();
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;
                NormalizeForPersistence(dto);

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                var updated = (await _service.GetByIdAsync(id)).Adapt<PersonaResponse>();
                return new PagedResult<PersonaResponse>
                {
                    Success = true,
                    Message = "Persona actualizada correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    Items = new List<PersonaResponse> { updated },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PersonaResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return new PagedResult<bool> { Success = false, Message = "Persona no encontrada", Code = "NOT_FOUND" };

                await _service.DeleteAsync(id);
                return new PagedResult<bool> { Success = true, Message = "Persona eliminada correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        private static void NormalizeForPersistence(PersonaDto dto)
        {
            foreach (var property in typeof(PersonaDto).GetProperties()
                .Where(property => property.PropertyType == typeof(string) && property.CanWrite))
            {
                var value = property.GetValue(dto) as string;
                property.SetValue(dto, (value ?? string.Empty).Trim());
            }

            dto.FechaDeInicio ??= DateTime.Today;
            dto.FechaNacimiento ??= new DateTime(1900, 1, 1);

            if (string.IsNullOrWhiteSpace(dto.Iniciales))
            {
                dto.Iniciales = string.Concat(
                    FirstLetter(dto.Nombre),
                    FirstLetter(dto.Paterno),
                    FirstLetter(dto.Materno));
            }
        }

        private static string FirstLetter(string? value) =>
            string.IsNullOrWhiteSpace(value) ? string.Empty : value.Trim()[0].ToString().ToUpperInvariant();

        public async Task<PagedResult<PersonaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _service.GetQueryWithIncludes();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e =>
                        e.Clave.Contains(f) ||
                        e.Nombre.Contains(f) ||
                        e.Paterno.Contains(f) ||
                        e.Materno.Contains(f) ||
                        e.Rfc.Contains(f) ||
                        e.Curp.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidPersona" => isAscending ? query.OrderBy(e => e.PkidPersona) : query.OrderByDescending(e => e.PkidPersona),
                        "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                        "Nombre" => isAscending ? query.OrderBy(e => e.Nombre) : query.OrderByDescending(e => e.Nombre),
                        "Paterno" => isAscending ? query.OrderBy(e => e.Paterno) : query.OrderByDescending(e => e.Paterno),
                        "Materno" => isAscending ? query.OrderBy(e => e.Materno) : query.OrderByDescending(e => e.Materno),
                        "Rfc" => isAscending ? query.OrderBy(e => e.Rfc) : query.OrderByDescending(e => e.Rfc),
                        "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                        _ => query.OrderBy(e => e.Nombre)
                    };
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return new PagedResult<PersonaResponse>
                {
                    Items = items.Adapt<List<PersonaResponse>>(),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PersonaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener personas: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PersonaResponse>> BuscarAsync(BusquedaRequest request)
        {
            try
            {
                var pagedRequest = new PagedRequest
                {
                    Page = request.Page,
                    PageSize = request.PageSize,
                    Filtro = request.TerminoBusqueda,
                    SortLabel = request.SortLabel,
                    SortDirection = request.SortDirection
                };

                return await GetAllPaginadoAsync(pagedRequest);
            }
            catch (Exception ex)
            {
                return new PagedResult<PersonaResponse>
                {
                    Success = false,
                    Message = $"Error al buscar personas: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
