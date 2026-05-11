using AutoMapper;
using EG.Application.Interfaces.ClavePrograma;
using EG.Application.Interfaces.Configuracion.Catalogo.ClavePrograma;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Services.Configuracion.Catalogo.ClavePrograma
{
    public class FnAppService : IFnAppService
    {
        private readonly IFnService _fnService;
        private readonly IMapper _mapper;

        public FnAppService(IFnService fnService, IMapper mapper)
        {
            _fnService = fnService;
            _mapper = mapper;
        }

        public async Task<PagedResult<FnResponse>> GetAllAsync()
        {
            var items = await _fnService.GetAllAsync();
            return new PagedResult<FnResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = items.ToList(),
                TotalCount = items.Count()
            };
        }

        public async Task<PagedResult<FnResponse>> GetByIdAsync(int id)
        {
            var result = await _fnService.GetByIdAsync(id);
            if (result == null)
            {
                return new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }

            return new PagedResult<FnResponse>
            {
                Success = true,
                Message = "Registro encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<FnResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<FnResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _fnService.GetAllPaginadoAsync(request);
            return new PagedResult<FnResponse>
            {
                Success = true,
                Message = "Registros obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<PagedResult<FnResponse>> CreateAsync(FnResponse request, int usuarioActual)
        {
            var dto = _mapper.Map<FnDto>(request);
            if (!await _fnService.CanAddAsync(dto))
            {
                return new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = "Ya existe un registro activo con la misma Clave o Descripción",
                    Code = "DUPLICATE",
                    TotalCount = 0
                };
            }

            var created = await _fnService.AddAsync(dto, usuarioActual);

            return new PagedResult<FnResponse>
            {
                Success = true,
                Message = "Registro creado exitosamente",
                Code = "SUCCESS",
                Data = created,
                TotalCount = 1
            };
        }

        public async Task<PagedResult<FnResponse>> UpdateAsync(int id, FnResponse request, int usuarioActual)
        {
            var dto = _mapper.Map<FnDto>(request);
            dto.PkidFn = id;

            if (!await _fnService.CanUpdateAsync(id, dto))
            {
                return new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = "Ya existe otro registro activo con la misma Clave o Descripción",
                    Code = "DUPLICATE",
                    TotalCount = 0
                };
            }

            await _fnService.UpdateAsync(id, dto, usuarioActual);
            var updated = await _fnService.GetByIdAsync(id);

            return new PagedResult<FnResponse>
            {
                Success = true,
                Message = "Registro actualizado correctamente",
                Code = "SUCCESS",
                Data = updated,
                TotalCount = 1
            };
        }

        public async Task<PagedResult<FnResponse>> DeleteAsync(int id)
        {
            try
            {
                await _fnService.DeleteAsync(id);
                return new PagedResult<FnResponse>
                {
                    Success = true,
                    Message = "Registro eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<FnResponse>
                {
                    Success = false,
                    Message = $"No se encontró el registro con ID {id}",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<FnResponse>> BuscarAsync(BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };
            var result = await _fnService.GetAllPaginadoAsync(pagedRequest);
            return new PagedResult<FnResponse>
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
