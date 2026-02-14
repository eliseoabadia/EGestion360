using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
using EG.Web.Models;
using EG.Web.Models.Configuration;
using Microsoft.JSInterop;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services.Configuration
{
    public class EmpresaService : BaseService, IEmpresaService
    {
        public EmpresaService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
            : base(httpClient, jsRuntime, application)
        {
        }

        public async Task<ApiResponse<EmpresaResponse>> GetAllEmpresasAsync()
        {
            if (!IsClientSide())
                return new ApiResponse<EmpresaResponse>();

            var result = await GetAsync<ApiResponse<EmpresaResponse>>("api/Empresa/");
            return result ?? new ApiResponse<EmpresaResponse>
            {
                Success = false,
                Message = "Error al obtener empresas",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<EmpresaResponse>> GetAllEmpresasPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending,
            string estado = null)
        {
            if (!IsClientSide())
                return new ApiResponse<EmpresaResponse>();

            string sortDirection = _sortDirection == SortDirection.Descending ? "Descending" : "Ascending";

            var jsonParams = new
            {
                page,
                pageSize,
                filtro = filtro ?? string.Empty,
                sortLabel = sortLabel ?? string.Empty,
                sortDirection,
                estado
            };

            var result = await PostAsync<ApiResponse<EmpresaResponse>>(
                "api/Empresa/GetAllEmpresasPaginado/",
                jsonParams,
                useBaseUrl: false);

            return result ?? new ApiResponse<EmpresaResponse>
            {
                Success = false,
                Message = "Error al obtener empresas paginadas",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<EmpresaResponse>> GetEmpresaByIdAsync(int empresaId)
        {
            if (!IsClientSide())
                return new ApiResponse<EmpresaResponse>();

            var result = await GetAsync<ApiResponse<EmpresaResponse>>($"api/Empresa/{empresaId}");
            return result ?? new ApiResponse<EmpresaResponse>
            {
                Success = false,
                Message = "Error al obtener empresa",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<EmpresaResponse>> CreateEmpresaAsync(EmpresaResponse empresa)
        {
            if (!IsClientSide())
                return new ApiResponse<EmpresaResponse>();

            var response = await PostAsync<ApiResponse<EmpresaResponse>>(
                "api/Empresa/",
                empresa,
                useBaseUrl: false);

            return response ?? new ApiResponse<EmpresaResponse>
            {
                Success = false,
                Message = "Error al crear empresa",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<EmpresaResponse>> UpdateEmpresaAsync(EmpresaResponse empresa)
        {
            if (!IsClientSide())
                return new ApiResponse<EmpresaResponse>();

            if (!empresa.PkidEmpresa.HasValue || empresa.PkidEmpresa <= 0)
                return new ApiResponse<EmpresaResponse>
                {
                    Success = false,
                    Message = "ID de empresa no válido",
                    Code = "INVALID_ID"
                };

            var response = await PutAsync<ApiResponse<EmpresaResponse>>(
                $"api/Empresa/{empresa.PkidEmpresa}/",
                empresa,
                useBaseUrl: false);

            return response ?? new ApiResponse<EmpresaResponse>
            {
                Success = false,
                Message = "Error al actualizar empresa",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<EmpresaResponse>> DeleteEmpresaAsync(int empresaId)
        {
            if (!IsClientSide())
                return new ApiResponse<EmpresaResponse>();

            var response = await DeleteAsync<ApiResponse<EmpresaResponse>>(
                $"api/Empresa/{empresaId}/",
                useBaseUrl: false);

            return response ?? new ApiResponse<EmpresaResponse>
            {
                Success = false,
                Message = "Error al eliminar empresa",
                Code = "ERROR"
            };
        }
    }
}
