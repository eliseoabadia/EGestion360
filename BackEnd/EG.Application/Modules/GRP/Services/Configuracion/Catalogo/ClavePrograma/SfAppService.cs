using Mapster;
using EG.Application.Interfaces.ClavePrograma;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Services.Configuracion.Catalogo.ClavePrograma
{
    public class SfAppService : ISfAppService
    {
        private readonly ISfService _sfService;

        public SfAppService(ISfService sfService)
        {
            _sfService = sfService;
        }

        public async Task<PagedResult<SubFuncionResponse>> GetAllAsync()
        {
            var items = await _sfService.GetAllAsync();
            return new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            };
        }

        public async Task<PagedResult<SubFuncionResponse>> GetByIdAsync(int id)
        {
            var result = await _sfService.GetByIdAsync(id);
            if (result == null)
            {
                return new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }

            return new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<SubFuncionResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<SubFuncionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _sfService.GetAllPaginadoAsync(request);
            return new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<PagedResult<SubFuncionResponse>> CreateAsync(SubFuncionResponse request, int usuarioActual)
        {
            var dto = request.Adapt<SubFuncionDto>();
            if (!await _sfService.CanAddAsync(dto))
            {
                return new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = "Ya existe un registro activo con la misma Clave o Descripción",
                    Code = "DUPLICATE",
                    TotalCount = 0
                };
            }

            var created = await _sfService.AddAsync(dto, usuarioActual);

            return new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Registro creado exitosamente",
                Code = "SUCCESS",
                Data = created,
                TotalCount = 1
            };
        }

        public async Task<PagedResult<SubFuncionResponse>> UpdateAsync(int id, SubFuncionResponse request, int usuarioActual)
        {
            var dto = request.Adapt<SubFuncionDto>();
            dto.PkidSf = id;

            if (!await _sfService.CanUpdateAsync(id, dto))
            {
                return new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = "Ya existe otro registro activo con la misma Clave o Descripción",
                    Code = "DUPLICATE",
                    TotalCount = 0
                };
            }

            await _sfService.UpdateAsync(id, dto, usuarioActual);
            var updated = await _sfService.GetByIdAsync(id);

            return new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Registro actualizado correctamente",
                Code = "SUCCESS",
                Data = updated,
                TotalCount = 1
            };
        }

        public async Task<PagedResult<SubFuncionResponse>> DeleteAsync(int id)
        {
            try
            {
                await _sfService.DeleteAsync(id);
                return new PagedResult<SubFuncionResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<SubFuncionResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<SubFuncionResponse>> BuscarAsync(BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };
            var result = await _sfService.GetAllPaginadoAsync(pagedRequest);
            return new PagedResult<SubFuncionResponse>
            {
                Success = true,
                Message = "Búsqueda realizada correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
