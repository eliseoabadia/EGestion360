using EG.Common.GenericModel;
using EG.Common.Helper;
using EG.Web.Contracs;
using EG.Web.Models;
using Microsoft.JSInterop;
using MudBlazor;

namespace EG.Web.Services
{
    public class GenericCrudService<TResponse> : BaseService, IGenericCrudService<TResponse> where TResponse : class
    {
        private readonly string _endpoint;
        private readonly string? _paginatedAction;

        public GenericCrudService(
            HttpClient httpClient,
            IJSRuntime jsRuntime,
            ApplicationInstance application,
            string endpoint,
            string? paginatedAction = null)
            : base(httpClient, jsRuntime, application)
        {
            _endpoint = endpoint;
            _paginatedAction = paginatedAction;
        }

        public async Task<ApiResponse<TResponse>> GetByIdAsync(int id)
        {
            if (!IsClientSide())
                return new ApiResponse<TResponse>();

            return await GetAsync<ApiResponse<TResponse>>($"{_endpoint}/{id}");
        }

        public async Task<ApiResponse<TResponse>> GetAllByEmpresaAsync(int empresaId)
        {
            if (!IsClientSide())
                return new ApiResponse<TResponse>();

            return await GetAsync<ApiResponse<TResponse>>($"{_endpoint}/empresaId/{empresaId}");
        }

        public async Task<ApiResponse<TResponse>> GetAllBySucursalAsync(int sucursalId)
        {
            if (!IsClientSide())
                return new ApiResponse<TResponse>();

            return await GetAsync<ApiResponse<TResponse>>($"{_endpoint}/sucursalId/{sucursalId}");
        }

        public async Task<ApiResponse<TResponse>> GetAllAsync()
        {
            if (!IsClientSide())
                return new ApiResponse<TResponse>();

            var response = await GetAsync<ApiResponse<TResponse>>(_endpoint, useBaseUrl: false);
            return response ?? new ApiResponse<TResponse>();
        }

        public async Task<ApiResponse<TResponse>> GetAllPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            Dictionary<string, object>? additionalFilters = null)
        {
            if (!IsClientSide())
                return new ApiResponse<TResponse>();

            string sortDir = sortDirection == SortDirection.Descending ? "Descending" : "Ascending";

            var pagedRequest = new
            {
                page = page,
                pageSize = pageSize,
                filtro = filtro ?? "",
                sortLabel = sortLabel ?? string.Empty,
                sortDirection = sortDir,
                searchString = filtro ?? "",
                additionalFilters = additionalFilters ?? new Dictionary<string, object>()
            };

            // Determinar la acción para paginado
            string action = string.IsNullOrEmpty(_paginatedAction)
                ? "GetAllPaginado"
                : _paginatedAction;

            var response = await PostAsync<ApiResponse<TResponse>>(
                $"{_endpoint}/{action}/",
                pagedRequest,  // Enviar objeto anónimo
                useBaseUrl: false);

            return response ?? new ApiResponse<TResponse>();
        }

        public async Task<ApiResponse<TResponse>> CreateAsync(TResponse entity)
        {
            if (!IsClientSide())
                return new ApiResponse<TResponse>();

            var response = await PostAsync<ApiResponse<TResponse>>(
                _endpoint,
                entity,
                useBaseUrl: false);

            return response ?? new ApiResponse<TResponse>();
        }

        public async Task<ApiResponse<TResponse>> UpdateAsync(TResponse entity, int id)
        {
            if (!IsClientSide())
                return new ApiResponse<TResponse>();

            if (id <= 0)
            {
                return new ApiResponse<TResponse>
                {
                    Success = false,
                    Message = "ID no válido",
                    Code = "INVALID_ID"
                };
            }

            var response = await PutAsync<ApiResponse<TResponse>>(
                $"{_endpoint}/{id}/",
                entity,
                useBaseUrl: false);

            return response ?? new ApiResponse<TResponse>
            {
                Success = false,
                Message = "Error al actualizar",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<TResponse>> DeleteAsync(int id)
        {
            if (!IsClientSide())
                return new ApiResponse<TResponse>();

            var response = await DeleteAsync<ApiResponse<TResponse>>(
                $"{_endpoint}/{id}/",
                useBaseUrl: false);

            return response ?? new ApiResponse<TResponse>
            {
                Success = false,
                Message = "Error al eliminar",
                Code = "ERROR"
            };
        }
    }
}