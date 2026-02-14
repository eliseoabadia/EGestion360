using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
using EG.Web.Models;
using EG.Web.Models.Configuration;
using Microsoft.JSInterop;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services.Configuration
{
    public class SucursalService : BaseService, ISucursalService
    {
        public SucursalService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
            : base(httpClient, jsRuntime, application)
        {
        }

        public async Task<ApiResponse<SucursalResponse>> GetAllSucursales()
        {
            if (!IsClientSide())
                return new ApiResponse<SucursalResponse>();

            return await GetAsync<ApiResponse<SucursalResponse>>("api/Sucursal/");
        }

        public async Task<ApiResponse<SucursalResponse>> GetAllSucursalesPaginadoAsync(
    int page = 1,
    int pageSize = 10,
    string filtro = "",
    string sortLabel = "",
    SortDirection _sortDirection = SortDirection.Ascending)
        {
            if (!IsClientSide())
                return new ApiResponse<SucursalResponse>();

            string sortDirection = _sortDirection == SortDirection.Descending ? "Descending" : "Ascending";

            var jsonParams = new
            {
                page,
                pageSize,
                filtro = filtro ?? string.Empty,
                sortLabel = sortLabel ?? string.Empty,
                sortDirection
            };

            var result = await PostAsync<ApiResponse<SucursalResponse>>(
                "api/Sucursal/GetAllSucursalesPaginado/",
                jsonParams,
                useBaseUrl: false);

            return result ?? new ApiResponse<SucursalResponse>
            {
                Success = false,
                Message = "Error al obtener sucursales",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<SucursalResponse>> GetSucursalByIdAsync(int sucursalId)
        {
            if (!IsClientSide())
                return new ApiResponse<SucursalResponse>();

            var result = await GetAsync<ApiResponse<SucursalResponse>>($"api/Sucursal/{sucursalId}");
            return result ?? new ApiResponse<SucursalResponse>
            {
                Success = false,
                Message = "Error al obtener sucursal",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<SucursalResponse>> CreateSucursalAsync(SucursalResponse sucursal)
        {
            if (!IsClientSide())
                return new ApiResponse<SucursalResponse>();

            var response = await PostAsync<ApiResponse<SucursalResponse>>(
                "api/Sucursal/",
                sucursal,
                useBaseUrl: false);

            return response ?? new ApiResponse<SucursalResponse>
            {
                Success = false,
                Message = "Error al crear sucursal",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<SucursalResponse>> UpdateSucursalAsync(SucursalResponse sucursal)
        {
            if (!IsClientSide())
                return new ApiResponse<SucursalResponse>();

            if (sucursal.PkidSucursal <= 0)
                return new ApiResponse<SucursalResponse>
                {
                    Success = false,
                    Message = "ID de sucursal no válido",
                    Code = "INVALID_ID"
                };

            var response = await PutAsync<ApiResponse<SucursalResponse>>(
                $"api/Sucursal/{sucursal.PkidSucursal}/",
                sucursal,
                useBaseUrl: false);

            return response ?? new ApiResponse<SucursalResponse>
            {
                Success = false,
                Message = "Error al actualizar sucursal",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<SucursalResponse>> DeleteSucursalAsync(int sucursalId)
        {
            if (!IsClientSide())
                return new ApiResponse<SucursalResponse>();

            var response = await DeleteAsync<ApiResponse<SucursalResponse>>(
                $"api/Sucursal/{sucursalId}/",
                useBaseUrl: false);

            return response ?? new ApiResponse<SucursalResponse>
            {
                Success = false,
                Message = "Error al eliminar sucursal",
                Code = "ERROR"
            };
        }
    }
}