using Mapster;
using EG.Application.Interfaces.ClavePrograma;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Services.Configuracion.Catalogo.ClavePrograma
{
    public class GfAppService : IGfAppService
    {
        private readonly IGfService _gfService;

        public GfAppService(IGfService gfService)
        {
            _gfService = gfService;
        }

        public async Task<PagedResult<GfResponse>> GetAllAsync()
        {
            var items = await _gfService.GetAllAsync();
            return new PagedResult<GfResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            };
        }

        public async Task<PagedResult<GfResponse>> GetByIdAsync(int id)
        {
            var result = await _gfService.GetByIdAsync(id);
            if (result == null)
            {
                return new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }

            return new PagedResult<GfResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<GfResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<GfResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            try
            {
                var result = await _gfService.GetAllPaginadoAsync(request);
                return new PagedResult<GfResponse>
                {
                    Success = true,
                    Message = "Registros obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Error al obtener los registros paginados",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<GfResponse>> CreateAsync(GfResponse request, int usuarioActual)
        {
            try
            {
                var dto = request.Adapt<GfDto>();

                if (!await _gfService.CanAddAsync(dto))
                {
                    return new PagedResult<GfResponse>
                    {
                        Success = false,
                        Message = "Ya existe un registro activo con la misma Clave o Descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                var created = await _gfService.AddAsync(dto, usuarioActual);

                return new PagedResult<GfResponse>
                {
                    Success = true,
                    Message = "Registro creado exitosamente",
                    Code = "SUCCESS",
                    Data = created,
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Ocurrió un error interno al crear el registro",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<GfResponse>> UpdateAsync(int id, GfResponse request, int usuarioActual)
        {
            try
            {
                var dto = request.Adapt<GfDto>();
                dto.PkidGf = id;

                if (!await _gfService.CanUpdateAsync(id, dto))
                {
                    return new PagedResult<GfResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro registro activo con la misma Clave o Descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _gfService.UpdateAsync(id, dto, usuarioActual);
                var updated = await _gfService.GetByIdAsync(id);

                return new PagedResult<GfResponse>
                {
                    Success = true,
                    Message = "Registro actualizado correctamente",
                    Code = "SUCCESS",
                    Data = updated,
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (InvalidOperationException ex)
            {
                return new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "BUSINESS_RULE",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Ocurrió un error interno al actualizar el registro",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<GfResponse>> DeleteAsync(int id)
        {
            try
            {
                await _gfService.DeleteAsync(id);
                return new PagedResult<GfResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Ocurrió un error interno al eliminar el registro",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<GfResponse>> BuscarAsync(BusquedaRequest request)
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
                var result = await _gfService.GetAllPaginadoAsync(pagedRequest);
                return new PagedResult<GfResponse>
                {
                    Success = true,
                    Message = "Búsqueda realizada correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<GfResponse>
                {
                    Success = false,
                    Message = "Error al realizar la búsqueda",
                    Code = "INTERNAL_ERROR",
                    TotalCount = 0
                };
            }
        }
    }
}
