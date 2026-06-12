using Mapster;
using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Configuracion.Catalogo.Patrimonio
{
    public class FamiliaService : IFamiliaService
    {
        private readonly GenericService<Familium, FamiliaDto, FamiliaResponse> _service;
        private readonly IUserContextService _userContext;

        public FamiliaService(
            GenericService<Familium, FamiliaDto, FamiliaResponse> service,
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
                var fDto = dto as FamiliaDto;
                if (fDto == null) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(f => f.Clave == fDto.Clave && f.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                var fDto = dto as FamiliaDto;
                if (fDto == null || !id.HasValue) return true;
                return !_service.GetQueryWithIncludes()
                    .Any(f => f.Clave == fDto.Clave && f.PkidFamilia != id.Value && f.Activo);
            });
        }

        public async Task<PagedResult<FamiliaResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return new PagedResult<FamiliaResponse>
                {
                    Success = true,
                    Message = "Familias obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener familias: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<FamiliaResponse>> GetByIdAsync(int id)
        {
            try
            {
                var result = await _service.GetByIdAsync(id, idPropertyName: "PkidFamilia");
                if (result == null)
                    return new PagedResult<FamiliaResponse>
                    {
                        Success = false,
                        Message = "Familia no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    };

                return new PagedResult<FamiliaResponse>
                {
                    Success = true,
                    Message = "Familia encontrada",
                    Code = "SUCCESS",
                    Data = result,
                    Items = new List<FamiliaResponse> { result },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener familia: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<FamiliaResponse>> CreateAsync(FamiliaResponse request)
        {
            try
            {
                var dto = request.Adapt<FamiliaDto>();
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                    return new PagedResult<FamiliaResponse>
                    {
                        Success = false,
                        Message = "Ya existe una Familia activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };

                await _service.AddAsync(dto);

                var created = dto.Adapt<FamiliaResponse>();
                return new PagedResult<FamiliaResponse>
                {
                    Success = true,
                    Message = "Familia creada correctamente",
                    Code = "SUCCESS",
                    Data = created,
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = $"Error al crear: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<FamiliaResponse>> UpdateAsync(int id, FamiliaResponse request)
        {
            try
            {
                var dto = request.Adapt<FamiliaDto>();
                dto.PkidFamilia = id;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                    return new PagedResult<FamiliaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra Familia activa con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };

                await _service.UpdateAsync(id, dto);

                var updated = await _service.GetByIdAsync(id, idPropertyName: "PkidFamilia");
                return new PagedResult<FamiliaResponse>
                {
                    Success = true,
                    Message = "Familia actualizada correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = $"Familia con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FamiliaResponse>
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
                    Message = "Familia eliminada correctamente",
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
                    Message = $"Familia con ID {id} no encontrada",
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

        public async Task<PagedResult<FamiliaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _service.GetAllPaginadoAsync(request);
                return new PagedResult<FamiliaResponse>
                {
                    Success = result.Success,
                    Message = "Familias obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = $"Error al obtener familias: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<FamiliaResponse>> BuscarAsync(BusquedaRequest request)
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

                var result = await _service.GetAllPaginadoAsync(pagedRequest);
                return new PagedResult<FamiliaResponse>
                {
                    Success = true,
                    Message = "Familias filtradas correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<FamiliaResponse>
                {
                    Success = false,
                    Message = $"Error al buscar familias: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
