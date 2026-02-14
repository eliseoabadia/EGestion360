using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
using EG.Web.Models;
using EG.Web.Models.Configuration;
using Microsoft.JSInterop;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services.Configuration
{
    public class DepartamentoService : BaseService, IDepartamentoService
    {
        public DepartamentoService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
            : base(httpClient, jsRuntime, application)
        {
        }

        public async Task<ApiResponse<DepartamentoResponse>> GetAllDepartamentosAsync()
        {
            if (!IsClientSide())
                return new ApiResponse<DepartamentoResponse>();

            var response = await GetAsync<ApiResponse<DepartamentoResponse>>("api/Departamento/", useBaseUrl: false);
            return response ?? new ApiResponse<DepartamentoResponse>
            {
                Success = false,
                Message = "Error al obtener departamentos",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<DepartamentoResponse>> GetAllDepartamentosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending,
            int? empresaId = null,
            string estado = null)
        {
            if (!IsClientSide())
                return new ApiResponse<DepartamentoResponse>();

            string sortDirection = _sortDirection == SortDirection.Descending ? "Descending" : "Ascending";

            var jsonParams = new
            {
                page,
                pageSize,
                filtro = filtro ?? "",
                sortLabel = sortLabel ?? string.Empty,
                sortDirection,
                empresaId,
                estado
            };

            var response = await PostAsync<ApiResponse<DepartamentoResponse>>(
                "api/Departamento/GetAllDepartamentosPaginado/",
                jsonParams,
                useBaseUrl: false);

            return response ?? new ApiResponse<DepartamentoResponse>
            {
                Success = false,
                Message = "Error al obtener departamentos paginados",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<DepartamentoResponse>> GetDepartamentoByIdAsync(int departamentoId)
        {
            if (!IsClientSide())
                return new ApiResponse<DepartamentoResponse>();

            var response = await GetAsync<ApiResponse<DepartamentoResponse>>(
                $"api/Departamento/{departamentoId}",
                useBaseUrl: false);

            return response ?? new ApiResponse<DepartamentoResponse>
            {
                Success = false,
                Message = "Error al obtener departamento",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<DepartamentoResponse>> CreateDepartamentoAsync(DepartamentoResponse departamento)
        {
            if (!IsClientSide())
                return new ApiResponse<DepartamentoResponse>();

            var response = await PostAsync<ApiResponse<DepartamentoResponse>>(
                "api/Departamento/",
                departamento,
                useBaseUrl: false);

            return response ?? new ApiResponse<DepartamentoResponse>
            {
                Success = false,
                Message = "Error al crear departamento",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<DepartamentoResponse>> UpdateDepartamentoAsync(DepartamentoResponse departamento)
        {
            if (!IsClientSide())
                return new ApiResponse<DepartamentoResponse>();

            if (!departamento.PkidDepartamento.HasValue || departamento.PkidDepartamento <= 0)
                return new ApiResponse<DepartamentoResponse>
                {
                    Success = false,
                    Message = "ID de departamento no válido",
                    Code = "INVALID_ID"
                };

            var response = await PutAsync<ApiResponse<DepartamentoResponse>>(
                $"api/Departamento/{departamento.PkidDepartamento}/",
                departamento,
                useBaseUrl: false);

            return response ?? new ApiResponse<DepartamentoResponse>
            {
                Success = false,
                Message = "Error al actualizar departamento",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<DepartamentoResponse>> DeleteDepartamentoAsync(int departamentoId)
        {
            if (!IsClientSide())
                return new ApiResponse<DepartamentoResponse>();

            var response = await DeleteAsync<ApiResponse<DepartamentoResponse>>(
                $"api/Departamento/{departamentoId}/",
                useBaseUrl: false);

            return response ?? new ApiResponse<DepartamentoResponse>
            {
                Success = false,
                Message = "Error al eliminar departamento",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<DepartamentoResponse>> GetDepartamentosPorEmpresaAsync(int empresaId)
        {
            if (!IsClientSide())
                return new ApiResponse<DepartamentoResponse>();

            var response = await GetAsync<ApiResponse<DepartamentoResponse>>(
                $"api/Departamento/empresa/{empresaId}",
                useBaseUrl: false);

            return response ?? new ApiResponse<DepartamentoResponse>
            {
                Success = false,
                Message = "Error al obtener departamentos por empresa",
                Code = "ERROR"
            };
        }
    }
}