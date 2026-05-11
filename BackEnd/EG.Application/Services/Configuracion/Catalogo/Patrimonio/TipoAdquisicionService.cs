using AutoMapper;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio
{
    public class TipoAdquisicionService : ITipoAdquisicionService
    {
        private readonly GenericService<TipoAdquisicion, TipoAdquisicionDto, TipoAdquisicionResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public TipoAdquisicionService(
            GenericService<TipoAdquisicion, TipoAdquisicionDto, TipoAdquisicionResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
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
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.PkidTipoAdq != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<TipoAdquisicionResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return new PagedResult<TipoAdquisicionResponse>
                {
                    Success = true,
                    Message = "Tipos de adquisiciÃ³n obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoAdquisicionResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipos de adquisiciÃ³n: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoAdquisicionResponse>> GetByIdAsync(int id)
        {
            try
            {
                var entity = await _service.GetQueryWithIncludes().FirstOrDefaultAsync(e => e.PkidTipoAdq == id);
                if (entity == null)
                    return new PagedResult<TipoAdquisicionResponse> { Success = false, Message = "Tipo de adquisiciÃ³n no encontrado", Code = "NOT_FOUND" };

                var result = _mapper.Map<TipoAdquisicionResponse>(entity);
                return new PagedResult<TipoAdquisicionResponse>
                {
                    Success = true,
                    Message = "Tipo de adquisiciÃ³n obtenido correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoAdquisicionResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoAdquisicionResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipo de adquisiciÃ³n: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoAdquisicionResponse>> CreateAsync(TipoAdquisicionResponse request)
        {
            try
            {
                var dto = _mapper.Map<TipoAdquisicionDto>(request);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Clave == dto.Clave && x.Activo);

                return new PagedResult<TipoAdquisicionResponse>
                {
                    Success = true,
                    Message = "Tipo de adquisiciÃ³n creado correctamente",
                    Code = "SUCCESS",
                    Data = created != null ? _mapper.Map<TipoAdquisicionResponse>(created) : null,
                    Items = created != null ? new List<TipoAdquisicionResponse> { _mapper.Map<TipoAdquisicionResponse>(created) } : new List<TipoAdquisicionResponse>(),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoAdquisicionResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<TipoAdquisicionResponse>> UpdateAsync(int id, TipoAdquisicionResponse request)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return new PagedResult<TipoAdquisicionResponse> { Success = false, Message = "Tipo de adquisiciÃ³n no encontrado", Code = "NOT_FOUND" };

                var dto = _mapper.Map<TipoAdquisicionDto>(request);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                var updated = _mapper.Map<TipoAdquisicionResponse>(await _service.GetByIdAsync(id));
                return new PagedResult<TipoAdquisicionResponse>
                {
                    Success = true,
                    Message = "Tipo de adquisiciÃ³n actualizado correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    Items = new List<TipoAdquisicionResponse> { updated },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoAdquisicionResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return new PagedResult<bool> { Success = false, Message = "Tipo de adquisiciÃ³n no encontrado", Code = "NOT_FOUND" };

                await _service.DeleteAsync(id);
                return new PagedResult<bool> { Success = true, Message = "Tipo de adquisiciÃ³n eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<TipoAdquisicionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _service.GetQueryWithIncludes();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    var f = request.Filtro;
                    query = query.Where(e => e.Clave.Contains(f) || e.Descripcion.Contains(f));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidTipoAdq" => isAscending ? query.OrderBy(e => e.PkidTipoAdq) : query.OrderByDescending(e => e.PkidTipoAdq),
                        "Clave" => isAscending ? query.OrderBy(e => e.Clave) : query.OrderByDescending(e => e.Clave),
                        "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "Descripmovto" => isAscending ? query.OrderBy(e => e.Descripmovto) : query.OrderByDescending(e => e.Descripmovto),
                        "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                        _ => query.OrderBy(e => e.Descripcion)
                    };
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return new PagedResult<TipoAdquisicionResponse>
                {
                    Items = _mapper.Map<List<TipoAdquisicionResponse>>(items),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoAdquisicionResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipos de adquisiciÃ³n: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
