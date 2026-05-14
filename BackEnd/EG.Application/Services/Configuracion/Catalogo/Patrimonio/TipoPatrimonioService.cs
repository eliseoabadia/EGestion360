using Mapster;
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
    public class TipoPatrimonioService : ITipoPatrimonioService
    {
        private readonly GenericService<TipoPatrimonio, TipoPatrimonioDto, TipoPatrimonioResponse> _service;
        private readonly IUserContextService _userContext;

        public TipoPatrimonioService(
            GenericService<TipoPatrimonio, TipoPatrimonioDto, TipoPatrimonioResponse> service,
            IUserContextService userContext)
        {
            _service = service;
            _userContext = userContext;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidTipoPatrimonio != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<TipoPatrimonioResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return new PagedResult<TipoPatrimonioResponse>
                {
                    Success = true,
                    Message = "Tipos de patrimonio obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoPatrimonioResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipos de patrimonio: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoPatrimonioResponse>> GetByIdAsync(int id)
        {
            try
            {
                var entity = await _service.GetQueryWithIncludes().FirstOrDefaultAsync(e => e.PkidTipoPatrimonio == id);
                if (entity == null)
                    return new PagedResult<TipoPatrimonioResponse> { Success = false, Message = "Tipo de patrimonio no encontrado", Code = "NOT_FOUND" };

                var result = entity.Adapt<TipoPatrimonioResponse>();
                return new PagedResult<TipoPatrimonioResponse>
                {
                    Success = true,
                    Message = "Tipo de patrimonio obtenido correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<TipoPatrimonioResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoPatrimonioResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipo de patrimonio: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoPatrimonioResponse>> CreateAsync(TipoPatrimonioResponse request)
        {
            try
            {
                var dto = request.Adapt<TipoPatrimonioDto>();
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

                return new PagedResult<TipoPatrimonioResponse>
                {
                    Success = true,
                    Message = "Tipo de patrimonio creado correctamente",
                    Code = "SUCCESS",
                    Data = created != null ? created.Adapt<TipoPatrimonioResponse>() : null,
                    Items = created != null ? new List<TipoPatrimonioResponse> { created.Adapt<TipoPatrimonioResponse>() } : new List<TipoPatrimonioResponse>(),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoPatrimonioResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<TipoPatrimonioResponse>> UpdateAsync(int id, TipoPatrimonioResponse request)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return new PagedResult<TipoPatrimonioResponse> { Success = false, Message = "Tipo de patrimonio no encontrado", Code = "NOT_FOUND" };

                var dto = request.Adapt<TipoPatrimonioDto>();
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                var updated = (await _service.GetByIdAsync(id)).Adapt<TipoPatrimonioResponse>();
                return new PagedResult<TipoPatrimonioResponse>
                {
                    Success = true,
                    Message = "Tipo de patrimonio actualizado correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    Items = new List<TipoPatrimonioResponse> { updated },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoPatrimonioResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return new PagedResult<bool> { Success = false, Message = "Tipo de patrimonio no encontrado", Code = "NOT_FOUND" };

                await _service.DeleteAsync(id);
                return new PagedResult<bool> { Success = true, Message = "Tipo de patrimonio eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<TipoPatrimonioResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var query = _service.GetQueryWithIncludes();

                if (!string.IsNullOrWhiteSpace(request.Filtro))
                {
                    query = query.Where(e => e.Descripcion.Contains(request.Filtro));
                }

                if (!string.IsNullOrEmpty(request.SortLabel))
                {
                    var isAscending = string.IsNullOrEmpty(request.SortDirection) || request.SortDirection.StartsWith("asc", StringComparison.OrdinalIgnoreCase);
                    query = request.SortLabel switch
                    {
                        "PkidTipoPatrimonio" => isAscending ? query.OrderBy(e => e.PkidTipoPatrimonio) : query.OrderByDescending(e => e.PkidTipoPatrimonio),
                        "Descripcion" => isAscending ? query.OrderBy(e => e.Descripcion) : query.OrderByDescending(e => e.Descripcion),
                        "Activo" => isAscending ? query.OrderBy(e => e.Activo) : query.OrderByDescending(e => e.Activo),
                        _ => query.OrderBy(e => e.Descripcion)
                    };
                }

                var totalItems = await query.CountAsync();
                var items = await query
                    .Skip((request.Page - 1) * request.PageSize)
                    .Take(request.PageSize)
                    .ToListAsync();

                return new PagedResult<TipoPatrimonioResponse>
                {
                    Items = items.Adapt<List<TipoPatrimonioResponse>>(),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoPatrimonioResponse>
                {
                    Success = false,
                    Message = $"Error al obtener tipos de patrimonio: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
