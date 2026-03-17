using EG.Common.Helper;
using EG.Web.Contracs.ConteoCiclico;
using EG.Web.Models;
using EG.Web.Models.ConteoCiclico;
using EG.Web.Services;
using Microsoft.JSInterop;

namespace EG.Web.Services.ConteoCiclico
{
    public class ConteoCiclicoService : BaseService, IConteoCiclicoService
    {
        private readonly SucursalStateService _sucursalStateService;

        public ConteoCiclicoService(
            HttpClient httpClient, 
            IJSRuntime jsRuntime, 
            ApplicationInstance application,
            SucursalStateService sucursalStateService)
            : base(httpClient, jsRuntime, application)
        {
            _sucursalStateService = sucursalStateService;
        }

        public async Task<ApiResponse<ConteoResult>> GenerarConteoAsync(GenerarConteoRequest request)
        {
            if (!IsClientSide())
                return new ApiResponse<ConteoResult>();

            // Agregar sucursal del usuario logueado si no está especificada
            if (request.SucursalId <= 0 && _sucursalStateService.HasSucursalSeleccionada)
            {
                request.SucursalId = _sucursalStateService.SucursalId ?? 0;
            }

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

            // Usar la sucursal actual si no se especifica
            int? sucursalIdToUse = sucursalId;
            if (!sucursalIdToUse.HasValue && _sucursalStateService.HasSucursalSeleccionada)
            {
                sucursalIdToUse = _sucursalStateService.SucursalId;
            }

            var url = "api/ConteoCiclico/dashboard";
            if (sucursalIdToUse.HasValue)
                url += $"?sucursalId={sucursalIdToUse}";

            return await GetAsync<DashboardResponse>(url, useBaseUrl: false) ?? new DashboardResponse();
        }

        public bool HasSucursalSeleccionada => _sucursalStateService.HasSucursalSeleccionada;
        public int? SucursalId => _sucursalStateService.SucursalId;
        public string? SucursalNombre => _sucursalStateService.SucursalNombre;
    }
}
