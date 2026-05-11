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
    public class PartidaService : IPartidaService
    {
        private readonly GenericService<Partidum, PartidaDto, PartidaResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public PartidaService(
            GenericService<Partidum, PartidaDto, PartidaResponse> service,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _mapper = mapper;
            _userContext = userContext;
            _service.AddInclude(e => e.FkidConceptoSisNavigation);
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                var pDto = dto as PartidaDto;
                if (pDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(p => p.Clave == pDto.Clave && p.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                var pDto = dto as PartidaDto;
                if (pDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(p => p.Clave == pDto.Clave && p.PkidPartida != id.Value && p.Activo);
            });
        }

        public async Task<PagedResult<PartidaResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return new PagedResult<PartidaResponse>
                {
                    Success = true,
                    Message = "Partidas obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PartidaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener partidas: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PartidaResponse>> GetByIdAsync(int id)
        {
            try
            {
                var result = await _service.GetByIdAsync(id, idPropertyName: "PkidPartida");
                if (result == null)
                    return new PagedResult<PartidaResponse>
                    {
                        Success = false,
                        Message = "Partida no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                return new PagedResult<PartidaResponse>
                {
                    Success = true,
                    Message = "Partida encontrada",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<PartidaResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PartidaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener partida: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PartidaResponse>> CreateAsync(PartidaResponse request)
        {
            try
            {
                var dto = _mapper.Map<PartidaDto>(request);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return new PagedResult<PartidaResponse>
                    {
                        Success = false,
                        Message = "Ya existe una Partida activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };

                await _service.AddAsync(dto);

                return new PagedResult<PartidaResponse>
                {
                    Success = true,
                    Message = "Partida creada correctamente",
                    Code = "SUCCESS",
                    Data = _mapper.Map<PartidaResponse>(dto),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PartidaResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<PartidaResponse>> UpdateAsync(int id, PartidaResponse request)
        {
            try
            {
                var dto = _mapper.Map<PartidaDto>(request);
                dto.PkidPartida = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return new PagedResult<PartidaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra Partida activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };

                await _service.UpdateAsync(id, dto);

                var updated = await _service.GetByIdAsync(id, idPropertyName: "PkidPartida");
                return new PagedResult<PartidaResponse>
                {
                    Success = true,
                    Message = "Partida actualizada correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<PartidaResponse>
                {
                    Success = false,
                    Message = $"Partida con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PartidaResponse>
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
                    Message = "Partida eliminada correctamente",
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
                    Message = $"Partida con ID {id} no encontrada",
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

        public async Task<PagedResult<PartidaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(request);
                return new PagedResult<PartidaResponse>
                {
                    Success = result.Success,
                    Message = "Partidas obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<PartidaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener partidas: {ex.Message}",
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
                    .Where(p => p.Activo)
                    .OrderBy(p => p.Clave)
                    .Select(p => new LookupItem { Id = p.PkidPartida, Text = (p.Clave ?? "") + " - " + (p.Descripcion ?? "") })
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
                    .Where(p => p.Activo)
                    .OrderBy(p => p.Clave)
                    .Select(p => new LookupItem { Id = p.PkidPartida, Text = (p.Clave ?? "") + " - " + (p.Descripcion ?? "") });

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
