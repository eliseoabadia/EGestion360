using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
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

            var result = await GetAsync<List<DepartamentoResponse>>("api/Departamento/");
            return result ?? new List<DepartamentoResponse>();
        }

        public async Task<(List<DepartamentoResponse> Departamentos, int TotalCount)> GetAllDepartamentosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending)
        {
            if (!IsClientSide())
                return (new List<DepartamentoResponse>(), 0);

            string sortDirection = _sortDirection.ToString().Contains("Descending") ? "Descending" : "Ascending";

            var jsonParams = new
            {
                page = page,
                pageSize = pageSize,
                filtro = filtro ?? string.Empty,
                sortLabel = sortLabel ?? string.Empty,
                sortDirection = sortDirection
            };

            var result = await PostAsync<PagedResult<DepartamentoResponse>>(
                "api/Departamento/GetAllDepartamentosPaginado/",
                jsonParams,
                useBaseUrl: false);

            if (result != null && result.Items != null)
            {
                return (result.Items, result.TotalCount);
            }

            return (new List<DepartamentoResponse>(), 0);
        }

        public async Task<DepartamentoResponse> GetDepartamentoByIdAsync(int departamentoId)
        {
            if (!IsClientSide())
                return new DepartamentoResponse();

            var result = await GetAsync<DepartamentoResponse>($"api/Departamento/{departamentoId}");
            return result ?? new DepartamentoResponse();
        }

        public async Task<(bool resultado, string mensaje)> CreateDepartamentoAsync(DepartamentoResponse departamento)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Post,
                    "api/Departamento/",
                    departamento,
                    useBaseUrl: false);

                return (success, success ? "Departamento creado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> UpdateDepartamentoAsync(DepartamentoResponse departamento)
        {
            if (!departamento.PkidDepartamento.HasValue || departamento.PkidDepartamento <= 0)
                return (false, "ID de departamento no válido");

            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Put,
                    $"api/Departamento/{departamento.PkidDepartamento}/",
                    departamento,
                    useBaseUrl: false);

                return (success, success ? "Departamento actualizado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> DeleteDepartamentoAsync(int departamentoId)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Delete,
                    $"api/Departamento/{departamentoId}/",
                    departamentoId,
                    useBaseUrl: false);

                return (success, success ? "Departamento eliminado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<IList<DepartamentoResponse>> GetDepartamentosActivos()
        {
            if (!IsClientSide())
                return new List<DepartamentoResponse>();

            var result = await GetAsync<List<DepartamentoResponse>>("api/Departamento/GetDepartamentosActivos/");
            return result ?? new List<DepartamentoResponse>();
        }

        public async Task<IList<DepartamentoResponse>> GetDepartamentosPorEmpresaAsync(int empresaId)
        {
            if (!IsClientSide())
                return new List<DepartamentoResponse>();

            var result = await GetAsync<List<DepartamentoResponse>>($"api/Departamento/GetByEmpresa/{empresaId}");
            return result ?? new List<DepartamentoResponse>();
        }

        public async Task<bool> ToggleEstadoDepartamentoAsync(int departamentoId)
        {
            if (!IsClientSide())
                return false;

            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Post,
                    $"api/Departamento/ToggleEstado/{departamentoId}/",
                    departamentoId,
                    useBaseUrl: false);

                // Debes devolver exactamente (bool Result, string Message)
                return (result, message);
            });

            return operationResult.Result;
        }
    }
}