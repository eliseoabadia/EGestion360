using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
using EG.Web.Models.Configuration;
using Microsoft.JSInterop;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services.Configuration
{
    public class EstadoService : BaseService, IEstadoService
    {
        public EstadoService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
            : base(httpClient, jsRuntime, application)
        {
        }

        // ============ CONSULTAS ============

        public async Task<IList<EstadoResponse>> GetAllEstadosAsync()
        {
            if (!IsClientSide())
                return new List<EstadoResponse>();

            var result = await GetAsync<List<EstadoResponse>>("api/Estado/");
            return result ?? new List<EstadoResponse>();
        }

        public async Task<EstadoResponse> GetEstadoByIdAsync(int estadoId)
        {
            if (!IsClientSide())
                return new EstadoResponse();

            var result = await GetAsync<EstadoResponse>($"api/Estado/{estadoId}");
            return result ?? new EstadoResponse();
        }

        // ============ PAGINACIÓN ============

        public async Task<(List<EstadoResponse> Estados, int TotalCount)> GetAllEstadosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending,
            string? estado = null)
        {
            if (!IsClientSide())
                return (new List<EstadoResponse>(), 0);

            string sortDirection = _sortDirection.ToString().Contains("Descending") ? "Descending" : "Ascending";

            var jsonParams = new
            {
                page = page,
                pageSize = pageSize,
                filtro = filtro ?? string.Empty,
                sortLabel = sortLabel ?? string.Empty,
                sortDirection = sortDirection,
                estado = estado
            };

            var result = await PostAsync<PagedResult<EstadoResponse>>(
                "api/Estado/GetAllEstadosPaginado/",
                jsonParams,
                useBaseUrl: false);

            if (result != null && result.Items != null)
            {
                return (result.Items, result.TotalCount);
            }

            return (new List<EstadoResponse>(), 0);
        }

        // ============ CRUD ============

        public async Task<(bool resultado, string mensaje)> CreateEstadoAsync(EstadoResponse estado)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Post,
                    "api/Estado/",
                    estado,
                    useBaseUrl: false);

                return (success, success ? "Estado creado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> UpdateEstadoAsync(EstadoResponse estado)
        {
            if (estado.PkidEstado <= 0)
                return (false, "ID de estado no válido");

            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Put,
                    $"api/Estado/{estado.PkidEstado}/",
                    estado,
                    useBaseUrl: false);

                return (success, success ? "Estado actualizado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> DeleteEstadoAsync(int estadoId)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Delete,
                    $"api/Estado/{estadoId}/",
                    estadoId,
                    useBaseUrl: false);

                return (success, success ? "Estado eliminado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }
    }
}