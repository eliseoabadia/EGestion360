using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
using EG.Web.Models;
using EG.Web.Models.ConteoCiclico;
using EG.Web.Services;
using Microsoft.JSInterop;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services.ConteoCiclico
{
    public class BienService : BaseService, IBienService
    {
        private readonly SucursalStateService _sucursalStateService;

        public BienService(
            HttpClient httpClient, 
            IJSRuntime jsRuntime, 
            ApplicationInstance application,
            SucursalStateService sucursalStateService)
            : base(httpClient, jsRuntime, application)
        {
            _sucursalStateService = sucursalStateService;
        }

        public async Task<ApiResponse<List<BienResponse>>> GetAllAsync()
        {
            if (!IsClientSide())
                return new ApiResponse<List<BienResponse>>();

            var response = await GetAsync<ApiResponse<List<BienResponse>>>("api/Bien/", useBaseUrl: false);
            return response ?? new ApiResponse<List<BienResponse>>();
        }

        public async Task<ApiResponse<BienResponse>> GetByIdAsync(int id)
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            var response = await GetAsync<ApiResponse<BienResponse>>($"api/Bien/{id}", useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>
            {
                Success = false,
                Message = "Error al obtener el bien",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<BienResponse>> GetAllPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            int? areaId = null)
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            string sortDir = sortDirection == SortDirection.Descending ? "desc" : "asc";

            var filters = new Dictionary<string, object>();
            if (!string.IsNullOrEmpty(filtro))
                filters["Filter"] = filtro;
            if (areaId.HasValue)
                filters["AreaId"] = areaId.Value;
            
            // Agregar filtro de sucursal
            if (_sucursalStateService.HasSucursalSeleccionada)
            {
                filters["SucursalId"] = _sucursalStateService.SucursalId.Value;
            }

            var pagedRequest = new
            {
                Page = page,
                PageSize = pageSize,
                SortLabel = sortLabel,
                SortDirection = sortDir,
                Filters = filters.Select(kv => new { Field = kv.Key, Value = kv.Value.ToString() }).ToList()
            };

            var response = await PostAsync<ApiResponse<BienResponse>>("api/Bien/paginated", pagedRequest, useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>();
        }

        public async Task<ApiResponse<BienResponse>> GetByPeriodoIdAsync(int periodoId)
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            var response = await GetAsync<ApiResponse<BienResponse>>($"api/Bien/periodo/{periodoId}", useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>();
        }

        public async Task<ApiResponse<BienResponse>> GetBySucursalActualAsync()
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            if (!_sucursalStateService.HasSucursalSeleccionada)
            {
                return new ApiResponse<BienResponse>
                {
                    Success = false,
                    Message = "No hay sucursal seleccionada",
                    Code = "NOSUCURSAL"
                };
            }

            var response = await GetAsync<ApiResponse<BienResponse>>($"api/Bien/sucursal/{_sucursalStateService.SucursalId}", useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>();
        }

        public async Task<ApiResponse<BienResponse>> GetBySucursalIdAsync(int sucursalId)
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            var response = await GetAsync<ApiResponse<BienResponse>>($"api/Bien/sucursal/{sucursalId}", useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>();
        }

        public async Task<ApiResponse<BienResponse>> GetByAreaIdAsync(int areaId)
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            var response = await GetAsync<ApiResponse<BienResponse>>($"api/Bien/area/{areaId}", useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>();
        }

        public async Task<ApiResponse<BienResponse>> GetActivosAsync()
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            var response = await GetAsync<ApiResponse<BienResponse>>("api/Bien/activos", useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>();
        }

        public async Task<ApiResponse<BienResponse>> CreateAsync(BienResponse bien)
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            // Agregar sucursal al bien si hay una seleccionada
            if (_sucursalStateService.HasSucursalSeleccionada)
            {
                // La sucursal se maneja a nivel de API según el contexto
            }

            var response = await PostAsync<ApiResponse<BienResponse>>("api/Bien", bien, useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>
            {
                Success = false,
                Message = "Error al crear el bien",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<BienResponse>> UpdateAsync(int id, BienResponse bien)
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            var response = await PutAsync<ApiResponse<BienResponse>>($"api/Bien/{id}", bien, useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>
            {
                Success = false,
                Message = "Error al actualizar el bien",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<BienResponse>> DeleteAsync(int id)
        {
            if (!IsClientSide())
                return new ApiResponse<BienResponse>();

            var response = await DeleteAsync<ApiResponse<BienResponse>>($"api/Bien/{id}", useBaseUrl: false);
            return response ?? new ApiResponse<BienResponse>
            {
                Success = false,
                Message = "Error al eliminar el bien",
                Code = "ERROR"
            };
        }

        public bool HasSucursalSeleccionada => _sucursalStateService.HasSucursalSeleccionada;
        public int? SucursalId => _sucursalStateService.SucursalId;
        public string? SucursalNombre => _sucursalStateService.SucursalNombre;
    }

    public interface IBienService
    {
        Task<ApiResponse<List<BienResponse>>> GetAllAsync();
        Task<ApiResponse<BienResponse>> GetByIdAsync(int id);
        Task<ApiResponse<BienResponse>> GetAllPaginadoAsync(int page = 1, int pageSize = 10, string filtro = "", string sortLabel = "", SortDirection sortDirection = SortDirection.Ascending, int? areaId = null);
        Task<ApiResponse<BienResponse>> GetByPeriodoIdAsync(int periodoId);
        Task<ApiResponse<BienResponse>> GetBySucursalActualAsync();
        Task<ApiResponse<BienResponse>> GetBySucursalIdAsync(int sucursalId);
        Task<ApiResponse<BienResponse>> GetByAreaIdAsync(int areaId);
        Task<ApiResponse<BienResponse>> GetActivosAsync();
        Task<ApiResponse<BienResponse>> CreateAsync(BienResponse bien);
        Task<ApiResponse<BienResponse>> UpdateAsync(int id, BienResponse bien);
        Task<ApiResponse<BienResponse>> DeleteAsync(int id);
        
        bool HasSucursalSeleccionada { get; }
        int? SucursalId { get; }
        string? SucursalNombre { get; }
    }
}
