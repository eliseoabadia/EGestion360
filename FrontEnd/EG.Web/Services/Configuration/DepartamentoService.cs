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

        public async Task<IList<DepartamentoResponse>> GetAllDepartamentos()
        {
            if (!IsClientSide())
                return new List<DepartamentoResponse>();

            var response = await GetAsync<ApiResponse<DepartamentoResponse>>("api/Departamento/", useBaseUrl: false);

            if (response != null && response.Success && response.Items != null)
            {
                return response.Items;
            }

            return new List<DepartamentoResponse>();
        }

        public async Task<(List<DepartamentoResponse> Departamentos, int TotalCount)> GetAllDepartamentosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending,
            int? empresaId = null,
            string estado = null)
        {
            if (!IsClientSide())
                return (new List<DepartamentoResponse>(), 0);

            string sortDirection = _sortDirection.ToString().Contains("Descending") ? "Descending" : "Ascending";

            var jsonParams = new
            {
                page = page,
                pageSize = pageSize,
                filtro = filtro ?? "",
                sortLabel = sortLabel ?? string.Empty,
                sortDirection = sortDirection,
                empresaId = empresaId,
                estado = estado
            };

            // ✅ CORREGIDO: ApiResponse que contiene PagedResponse<DepartamentoResponse>
            var response = await PostAsync<ApiResponse<DepartamentoResponse>>(
                "api/Departamento/GetAllDepartamentosPaginado/",
                jsonParams,
                useBaseUrl: false);

            if (response != null && response.Success && response.Items != null)
            {
                return (response.Items.ToList(), response.TotalCount);
            }

            return (new List<DepartamentoResponse>(), 0);
        }

        public async Task<DepartamentoResponse> GetDepartamentoByIdAsync(int departamentoId)
        {
            if (!IsClientSide())
                return new DepartamentoResponse();

            var response = await GetAsync<ApiResponse<DepartamentoResponse>>($"api/Departamento/{departamentoId}", useBaseUrl: false);

            if (response != null && response.Success && response.Data != null)
            {
                return response.Data;
            }

            return new DepartamentoResponse();
        }

        public async Task<(bool resultado, string mensaje)> CreateDepartamentoAsync(DepartamentoResponse departamento)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var response = await PostAsync<ApiResponse<DepartamentoResponse>>(
                    "api/Departamento/",
                    departamento,
                    useBaseUrl: false);

                if (response != null && response.Success)
                {
                    return (true, response.Message ?? "Departamento creado correctamente");
                }

                return (false, response?.Message ?? "Error al crear departamento");
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> UpdateDepartamentoAsync(DepartamentoResponse departamento)
        {
            if (!departamento.PkidDepartamento.HasValue || departamento.PkidDepartamento <= 0)
                return (false, "ID de departamento no válido");

            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var response = await PutAsync<ApiResponse<DepartamentoResponse>>(
                    $"api/Departamento/{departamento.PkidDepartamento}/",
                    departamento,
                    useBaseUrl: false);

                if (response != null && response.Success)
                {
                    return (true, response.Message ?? "Departamento actualizado correctamente");
                }

                return (false, response?.Message ?? "Error al actualizar departamento");
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> DeleteDepartamentoAsync(int departamentoId)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var response = await DeleteAsync<ApiResponse<object>>(
                    $"api/Departamento/{departamentoId}/",
                    useBaseUrl: false);

                if (response != null && response.Success)
                {
                    return (true, response.Message ?? "Departamento eliminado correctamente");
                }

                return (false, response?.Message ?? "Error al eliminar departamento");
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<IList<DepartamentoResponse>> GetDepartamentosPorEmpresaAsync(int empresaId)
        {
            if (!IsClientSide())
                return new List<DepartamentoResponse>();

            var response = await GetAsync<ApiResponse<DepartamentoResponse>>($"api/Departamento/empresa/{empresaId}", useBaseUrl: false);

            if (response != null && response.Success && response.Items != null)
            {
                return response.Items;
            }

            return new List<DepartamentoResponse>();
        }
    }
}