using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
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

        public async Task<IList<EmpresaResponse>> GetAllEmpresas()
        {
            if (!IsClientSide())
                return new List<EmpresaResponse>();

            var result = await GetAsync<List<EmpresaResponse>>("api/Empresa/");
            return result ?? new List<EmpresaResponse>();
        }

        public async Task<(List<EmpresaResponse> Empresas, int TotalCount)> GetAllEmpresasPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending)
        {
            if (!IsClientSide())
                return (new List<EmpresaResponse>(), 0);

            string sortDirection = _sortDirection.ToString().Contains("Descending") ? "Descending" : "Ascending";

            var jsonParams = new
            {
                page = page,
                pageSize = pageSize,
                filtro = filtro ?? string.Empty,
                sortLabel = sortLabel ?? string.Empty,
                sortDirection = sortDirection
            };

            var result = await PostAsync<PagedResult<EmpresaResponse>>(
                "api/Empresa/GetAllEmpresasPaginado/",
                jsonParams,
                useBaseUrl: false);

            if (result != null && result.Items != null)
            {
                return (result.Items, result.TotalCount);
            }

            return (new List<EmpresaResponse>(), 0);
        }

        public async Task<EmpresaResponse> GetEmpresaByIdAsync(int EmpresaId)
        {
            if (!IsClientSide())
                return new EmpresaResponse();

            var result = await GetAsync<EmpresaResponse>($"api/Empresa/{EmpresaId}");
            return result ?? new EmpresaResponse();
        }

        public async Task<(bool resultado, string mensaje)> CreateEmpresaAsync(EmpresaResponse Empresa)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Post,
                    "api/Empresa/",
                    Empresa,
                    useBaseUrl: false);

                return (success, success ? "Empresa creado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> UpdateEmpresaAsync(EmpresaResponse Empresa)
        {
            if (Empresa.PkidEmpresa != null || Empresa.PkidEmpresa <= 0)
                return (false, "ID de Empresa no válido");

            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Put,
                    $"api/Empresa/{Empresa.PkidEmpresa}/",
                    Empresa,
                    useBaseUrl: false);

                return (success, success ? "Empresa actualizado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> DeleteEmpresaAsync(int EmpresaId)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Delete,
                    $"api/Empresa/{EmpresaId}/",
                    EmpresaId,
                    useBaseUrl: false);

                return (success, success ? "Empresa eliminado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

    }
}
