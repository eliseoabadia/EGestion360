using EG.Common.Helper;
using EG.Web.Contracs.ConteoCiclico;
using EG.Web.Models;
using EG.Web.Models.ConteoCiclico;
using Microsoft.JSInterop;
using MudBlazor;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services.ConteoCiclico;

public class PeriodoConteoService : BaseService, IPeriodoConteoService
{
    public PeriodoConteoService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
        : base(httpClient, jsRuntime, application)
    {
    }

    public async Task<ApiResponse<PeriodoConteoResponse>> GetByIdAsync(int id)
    {
        if (!IsClientSide())
            return new ApiResponse<PeriodoConteoResponse>();

        return await GetAsync<ApiResponse<PeriodoConteoResponse>>($"api/PeriodoConteo/{id}");
    }

    public async Task<ApiResponse<PeriodoConteoResponse>> GetAllAsync()
    {
        if (!IsClientSide())
            return new ApiResponse<PeriodoConteoResponse>();

        var response = await GetAsync<ApiResponse<PeriodoConteoResponse>>("api/PeriodoConteo", useBaseUrl: false);
        return response ?? new ApiResponse<PeriodoConteoResponse>();
    }

    public async Task<ApiResponse<PeriodoConteoResponse>> GetAllByEmpresaAsync(int empresaId)
    {
        if (!IsClientSide())
            return new ApiResponse<PeriodoConteoResponse>();

        var response = await GetAsync<ApiResponse<PeriodoConteoResponse>>($"api/PeriodoConteo/empresa/{empresaId}", useBaseUrl: false);
        return response ?? new ApiResponse<PeriodoConteoResponse>();
    }

    public async Task<ApiResponse<PeriodoConteoResponse>> GetAllBySucursalAsync(int sucursalId)
    {
        if (!IsClientSide())
            return new ApiResponse<PeriodoConteoResponse>();

        var response = await GetAsync<ApiResponse<PeriodoConteoResponse>>($"api/PeriodoConteo/sucursal/{sucursalId}", useBaseUrl: false);
        return response ?? new ApiResponse<PeriodoConteoResponse>();
    }

    public async Task<ApiResponse<PeriodoConteoResponse>> GetAllPaginadoAsync(
        int page = 1,
        int pageSize = 10,
        string filtro = "",
        string sortLabel = "",
        SortDirection sortDirection = SortDirection.Ascending,
        Dictionary<string, object>? additionalFilters = null)
    {
        if (!IsClientSide())
            return new ApiResponse<PeriodoConteoResponse>();

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

        var response = await PostAsync<ApiResponse<PeriodoConteoResponse>>(
            "api/PeriodoConteo/GetAllPaginado",
            pagedRequest,
            useBaseUrl: false);

        return response ?? new ApiResponse<PeriodoConteoResponse>();
    }

    public async Task<ApiResponse<PeriodoConteoResponse>> CreateAsync(PeriodoConteoResponse entity)
    {
        if (!IsClientSide())
            return new ApiResponse<PeriodoConteoResponse>();

        var response = await PostAsync<ApiResponse<PeriodoConteoResponse>>(
            "api/PeriodoConteo",
            entity,
            useBaseUrl: false);

        return response ?? new ApiResponse<PeriodoConteoResponse>();
    }

    public async Task<ApiResponse<PeriodoConteoResponse>> UpdateAsync(PeriodoConteoResponse entity, int id)
    {
        if (!IsClientSide())
            return new ApiResponse<PeriodoConteoResponse>();

        if (id <= 0)
        {
            return new ApiResponse<PeriodoConteoResponse>
            {
                Success = false,
                Message = "ID no válido",
                Code = "INVALID_ID"
            };
        }

        var response = await PutAsync<ApiResponse<PeriodoConteoResponse>>(
            $"api/PeriodoConteo/{id}",
            entity,
            useBaseUrl: false);

        return response ?? new ApiResponse<PeriodoConteoResponse>
        {
            Success = false,
            Message = "Error al actualizar",
            Code = "ERROR"
        };
    }

    public async Task<ApiResponse<PeriodoConteoResponse>> DeleteAsync(int id)
    {
        if (!IsClientSide())
            return new ApiResponse<PeriodoConteoResponse>();

        var response = await DeleteAsync<ApiResponse<PeriodoConteoResponse>>(
            $"api/PeriodoConteo/{id}",
            useBaseUrl: false);

        return response ?? new ApiResponse<PeriodoConteoResponse>
        {
            Success = false,
            Message = "Error al eliminar",
            Code = "ERROR"
        };
    }

    public async Task<ApiResponse<bool>> CambiarEstatusAsync(int id, int estatusId)
    {
        if (!IsClientSide())
            return new ApiResponse<bool>();

        var response = await PatchAsync<ApiResponse<bool>>(
            $"api/PeriodoConteo/{id}/cambiar-estatus",
            new { estatusId },
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

        var response = await PostAsync<ApiResponse<bool>>(
            $"api/PeriodoConteo/{id}/cerrar",
            new { },
            useBaseUrl: false);

        return response ?? new ApiResponse<bool>
        {
            Success = false,
            Message = "Error al cerrar periodo",
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

        return response ?? new ApiResponse<List<PeriodoConteoResponse>>();
    }
}
