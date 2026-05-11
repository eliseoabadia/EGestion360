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
    public class MarcaService : IMarcaService
    {
        private readonly GenericService<Marca, MarcaDto, MarcaResponse> _service;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public MarcaService(
            GenericService<Marca, MarcaDto, MarcaResponse> service,
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
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidMarca != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<MarcaResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return new PagedResult<MarcaResponse>
                {
                    Success = true,
                    Message = "Marcas obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<MarcaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener marcas: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<MarcaResponse>> GetByIdAsync(int id)
        {
            try
            {
                var entity = await _service.GetQueryWithIncludes().FirstOrDefaultAsync(e => e.PkidMarca == id);
                if (entity == null)
                    return new PagedResult<MarcaResponse> { Success = false, Message = "Marca no encontrada", Code = "NOT_FOUND" };

                var result = _mapper.Map<MarcaResponse>(entity);
                return new PagedResult<MarcaResponse>
                {
                    Success = true,
                    Message = "Marca obtenida correctamente",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<MarcaResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<MarcaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener marca: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<MarcaResponse>> CreateAsync(MarcaResponse request)
        {
            try
            {
                var dto = _mapper.Map<MarcaDto>(request);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _service.CanAddAsync(dto);
                await _service.AddAsync(dto);

                var created = _service.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

                return new PagedResult<MarcaResponse>
                {
                    Success = true,
                    Message = "Marca creada correctamente",
                    Code = "SUCCESS",
                    Data = created != null ? _mapper.Map<MarcaResponse>(created) : null,
                    Items = created != null ? new List<MarcaResponse> { _mapper.Map<MarcaResponse>(created) } : new List<MarcaResponse>(),
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<MarcaResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<MarcaResponse>> UpdateAsync(int id, MarcaResponse request)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return new PagedResult<MarcaResponse> { Success = false, Message = "Marca no encontrada", Code = "NOT_FOUND" };

                var dto = _mapper.Map<MarcaDto>(request);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _service.CanUpdateAsync(id, dto);
                await _service.UpdateAsync(id, dto);

                var updated = _mapper.Map<MarcaResponse>(await _service.GetByIdAsync(id));
                return new PagedResult<MarcaResponse>
                {
                    Success = true,
                    Message = "Marca actualizada correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    Items = new List<MarcaResponse> { updated },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<MarcaResponse> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                var existing = await _service.GetByIdAsync(id);
                if (existing == null)
                    return new PagedResult<bool> { Success = false, Message = "Marca no encontrada", Code = "NOT_FOUND" };

                await _service.DeleteAsync(id);
                return new PagedResult<bool> { Success = true, Message = "Marca eliminada correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" };
            }
        }

        public async Task<PagedResult<MarcaResponse>> GetAllPaginadoAsync(PagedRequest request)
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
                        "PkidMarca" => isAscending ? query.OrderBy(e => e.PkidMarca) : query.OrderByDescending(e => e.PkidMarca),
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

                return new PagedResult<MarcaResponse>
                {
                    Items = _mapper.Map<List<MarcaResponse>>(items),
                    TotalCount = totalItems,
                    Success = true,
                    Message = "OK",
                    Code = "SUCCESS"
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<MarcaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener marcas: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
