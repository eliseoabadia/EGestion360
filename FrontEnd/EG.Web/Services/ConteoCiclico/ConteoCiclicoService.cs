using EG.Common.Helper;
using EG.Web.Contracs.ConteoCiclico;
using EG.Web.Models;
using EG.Web.Models.ConteoCiclico;
using Microsoft.JSInterop;

namespace EG.Web.Services.ConteoCiclico
{
    public class ConteoCiclicoService : BaseService, IConteoCiclicoService
    {
        public ConteoCiclicoService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
            : base(httpClient, jsRuntime, application)
        {
        }

        public async Task<ApiResponse<ConteoResult>> GenerarConteoAsync(GenerarConteoRequest request)
        {
            if (!IsClientSide())
                return new ApiResponse<ConteoResult>();

            return await PostAsync<ApiResponse<ConteoResult>>("api/ConteoCiclico/generar", request, useBaseUrl: false)
                   ?? new ApiResponse<ConteoResult> { Success = false, Message = "Error al generar conteo", Code = "ERROR" };
        }

        public async Task<ApiResponse<ConteoResult>> IniciarConteoAsync(int articuloConteoId)
        {
            if (!IsClientSide())
                return new ApiResponse<ConteoResult>();

            return await PostAsync<ApiResponse<ConteoResult>>($"api/ConteoCiclico/iniciar/{articuloConteoId}", null, useBaseUrl: false)
                   ?? new ApiResponse<ConteoResult> { Success = false, Message = "Error al iniciar conteo", Code = "ERROR" };
        }

        public async Task<ApiResponse<ConteoResult>> RegistrarConteoAsync(RegistrarConteoRequest request)
        {
            if (!IsClientSide())
                return new ApiResponse<ConteoResult>();

            return await PostAsync<ApiResponse<ConteoResult>>("api/ConteoCiclico/registrar", request, useBaseUrl: false)
                   ?? new ApiResponse<ConteoResult> { Success = false, Message = "Error al registrar conteo", Code = "ERROR" };
        }

        public async Task<ApiResponse<ConteoResult>> CerrarConteoAsync(CerrarConteoRequest request)
        {
            if (!IsClientSide())
                return new ApiResponse<ConteoResult>();

            return await PostAsync<ApiResponse<ConteoResult>>("api/ConteoCiclico/cerrar", request, useBaseUrl: false)
                   ?? new ApiResponse<ConteoResult> { Success = false, Message = "Error al cerrar conteo", Code = "ERROR" };
        }

        public async Task<DashboardResponse> GetDashboardAsync(int? sucursalId = null)
        {
            if (!IsClientSide())
                return new DashboardResponse();

            var url = "api/ConteoCiclico/dashboard";
            if (sucursalId.HasValue)
                url += $"?sucursalId={sucursalId}";

            return await GetAsync<DashboardResponse>(url, useBaseUrl: false) ?? new DashboardResponse();
        }
    }
}