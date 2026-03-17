using EG.Common.Helper;
using EG.Web.Contracs.ConteoCiclico;
using EG.Web.Models;
using EG.Web.Models.ConteoCiclico;
using EG.Web.Services;
using Microsoft.JSInterop;

namespace EG.Web.Services.ConteoCiclico
{
    public class PeriodoConteoService : GenericCrudService<PeriodoConteoResponse>, IPeriodoConteoService
    {
        private readonly SucursalStateService _sucursalStateService;

        public PeriodoConteoService(
            HttpClient httpClient, 
            IJSRuntime jsRuntime, 
            ApplicationInstance application,
            SucursalStateService sucursalStateService)
            : base(httpClient, jsRuntime, application, "api/PeriodoConteo")
        {
            _sucursalStateService = sucursalStateService;
        }

        public async Task<ApiResponse<bool>> CambiarEstatusAsync(int id, int estatusId)
        {
            if (!IsClientSide())
                return new ApiResponse<bool>();

            var response = await PatchAsync<ApiResponse<bool>>(
                $"api/PeriodoConteo/{id}/cambiar-estatus",
                estatusId,
                useBaseUrl: false);

            return response ?? new ApiResponse<bool>
            {
                Success = false,
                Message = "Error al cambiar estatus",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<bool>> CerrarPeriodoAsync(int id)
        {
            if (!IsClientSide())
                return new ApiResponse<bool>();

            var response = await PatchAsync<ApiResponse<bool>>(
                $"api/PeriodoConteo/{id}/cerrar",
                null,
                useBaseUrl: false);

            return response ?? new ApiResponse<bool>
            {
                Success = false,
                Message = "Error al cerrar período",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<List<PeriodoConteoResponse>>> GetMisPeriodosAsync(int usuarioId)
        {
            if (!IsClientSide())
                return new ApiResponse<List<PeriodoConteoResponse>>();

            var response = await GetAsync<ApiResponse<List<PeriodoConteoResponse>>>(
                $"api/PeriodoConteo/mis-periodos/{usuarioId}",
                useBaseUrl: false);

            return response ?? new ApiResponse<List<PeriodoConteoResponse>>
            {
                Success = false,
                Message = "Error al obtener mis períodos",
                Code = "ERROR"
            };
        }

        // Obtener periodos por la sucursal actual
        public async Task<ApiResponse<List<PeriodoConteoResponse>>> GetBySucursalActualAsync()
        {
            if (!IsClientSide())
                return new ApiResponse<List<PeriodoConteoResponse>>();

            if (!_sucursalStateService.HasSucursalSeleccionada)
            {
                return new ApiResponse<List<PeriodoConteoResponse>>
                {
                    Success = false,
                    Message = "No hay sucursal seleccionada",
                    Code = "NOSUCURSAL"
                };
            }

            var response = await GetAsync<ApiResponse<List<PeriodoConteoResponse>>>(
                $"api/PeriodoConteo/sucursal/{_sucursalStateService.SucursalId}",
                useBaseUrl: false);

            return response ?? new ApiResponse<List<PeriodoConteoResponse>>();
        }

        public bool HasSucursalSeleccionada => _sucursalStateService.HasSucursalSeleccionada;
        public int? SucursalId => _sucursalStateService.SucursalId;
        public string? SucursalNombre => _sucursalStateService.SucursalNombre;
    }
}
