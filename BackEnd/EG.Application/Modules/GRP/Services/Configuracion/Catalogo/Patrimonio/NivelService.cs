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
    public class NivelService : INivelService
    {
        private readonly GenericService<Nivel, NivelDto, NivelResponse> _service;
        private readonly IUserContextService _userContext;

        public NivelService(
            GenericService<Nivel, NivelDto, NivelResponse> service,
            IUserContextService userContext)
        {
            _service = service;
            _userContext = userContext;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueNivel", async (dto) =>
            {
                var nDto = dto as NivelDto;
                if (nDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(n => n.Nivel1 == nDto.Nivel1 && n.Activo);
            });

            _service.AddValidationRuleWithId("UniqueNivelUpdate", async (dto, id) =>
            {
                var nDto = dto as NivelDto;
                if (nDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(n => n.Nivel1 == nDto.Nivel1 && n.PkidNivel != id.Value && n.Activo);
            });
        }

        public async Task<PagedResult<NivelResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return new PagedResult<NivelResponse>
                {
                    Success = true,
                    Message = "Niveles obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<NivelResponse>
                {
                    Success = false,
                    Message = $"Error al obtener niveles: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<NivelResponse>> GetByIdAsync(int id)
        {
            try
            {
                var result = await _service.GetByIdAsync(id, idPropertyName: "PkidNivel");
                if (result == null)
                    return new PagedResult<NivelResponse>
                    {
                        Success = false,
                        Message = "Nivel no encontrado",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                return new PagedResult<NivelResponse>
                {
                    Success = true,
                    Message = "Nivel encontrado",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<NivelResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<NivelResponse>
                {
                    Success = false,
                    Message = $"Error al obtener nivel: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<NivelResponse>> CreateAsync(NivelResponse request)
        {
            try
            {
                var dto = request.Adapt<NivelDto>();
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return new PagedResult<NivelResponse>
                    {
                        Success = false,
                        Message = "Ya existe un Nivel activo con ese número",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };

                await _service.AddAsync(dto);

                return new PagedResult<NivelResponse>
                {
                    Success = true,
                    Message = "Nivel creado correctamente",
                    Code = "SUCCESS",
                    Data = dto.Adapt<NivelResponse>(),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<NivelResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<NivelResponse>> UpdateAsync(int id, NivelResponse request)
        {
            try
            {
                var dto = request.Adapt<NivelDto>();
                dto.PkidNivel = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return new PagedResult<NivelResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro Nivel activo con ese número",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };

                await _service.UpdateAsync(id, dto);

                var updated = await _service.GetByIdAsync(id, idPropertyName: "PkidNivel");
                return new PagedResult<NivelResponse>
                {
                    Success = true,
                    Message = "Nivel actualizado correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<NivelResponse>
                {
                    Success = false,
                    Message = $"Nivel con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<NivelResponse>
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
                    Message = "Nivel eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Nivel con ID {id} no encontrado",
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

        public async Task<PagedResult<NivelResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(request);
                return new PagedResult<NivelResponse>
                {
                    Success = result.Success,
                    Message = "Niveles obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<NivelResponse>
                {
                    Success = false,
                    Message = $"Error al obtener niveles: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<List<LookupItem>> GetLookupAsync()
        {
            try
            {
                return await _service.GetQueryWithIncludes()
                    .Where(n => n.Activo)
                    .OrderBy(n => n.Descripcion)
                    .Select(n => new LookupItem { Id = n.PkidNivel, Text = n.Descripcion ?? "" })
                    .ToListAsync();
            }
            catch (Exception ex)
            {
                return new List<LookupItem>();
            }
        }

        public async Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page = 1, int pageSize = 25, string? filter = null)
        {
            try
            {
                page = Math.Max(page, 1);
                pageSize = Math.Clamp(pageSize, 1, 100);

                var query = _service.GetQueryWithIncludes()
                    .Where(n => n.Activo)
                    .OrderBy(n => n.Descripcion)
                    .Select(n => new LookupItem { Id = n.PkidNivel, Text = n.Descripcion ?? "" });

                if (!string.IsNullOrWhiteSpace(filter))
                {
                    var term = filter.Trim();
                    query = query.Where(x => x.Text.Contains(term));
                }

                var totalCount = await query.CountAsync();
                var items = await query
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .ToListAsync();

                return new PagedResult<LookupItem>
                {
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS",
                    Items = items,
                    TotalCount = totalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<LookupItem>
                {
                    Success = false,
                    Message = $"Error al obtener lookup: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
