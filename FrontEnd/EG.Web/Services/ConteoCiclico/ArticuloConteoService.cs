using EG.Common.Helper;
using EG.Web.Contracs.ConteoCiclico;
using EG.Web.Models;
using EG.Web.Models.ConteoCiclico;
using Microsoft.JSInterop;
using MudBlazor;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services.ConteoCiclico;

public class ArticuloConteoService : BaseService, IArticuloConteoService
{
    public ArticuloConteoService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
        : base(httpClient, jsRuntime, application)
    {
    }

    public async Task<ApiResponse<List<ArticuloConteoResponse>>> GetAllAsync()
    {
        if (!IsClientSide())
            return new ApiResponse<List<ArticuloConteoResponse>>();

        var response = await GetAsync<ApiResponse<List<ArticuloConteoResponse>>>("api/ArticuloConteo", useBaseUrl: false);
        return response ?? new ApiResponse<List<ArticuloConteoResponse>>();
    }

    public async Task<ApiResponse<ArticuloConteoResponse>> GetByIdAsync(int id)
    {
        if (!IsClientSide())
            return new ApiResponse<ArticuloConteoResponse>();

        return await GetAsync<ApiResponse<ArticuloConteoResponse>>($"api/ArticuloConteo/{id}");
    }

    public async Task<ApiResponse<ArticuloConteoResponse>> GetAllPaginadoAsync(
        int page = 1,
        int pageSize = 10,
        string filtro = "",
        string sortLabel = "",
        SortDirection sortDirection = SortDirection.Ascending,
        int? periodoId = null,
        int? usuarioId = null,
        int? estatusId = null)
    {
        if (!IsClientSide())
            return new ApiResponse<ArticuloConteoResponse>();

        string sortDir = sortDirection == SortDirection.Descending ? "Descending" : "Ascending";

        var pagedRequest = new
        {
            page = page,
            pageSize = pageSize,
            filtro = filtro ?? "",
            sortLabel = sortLabel ?? string.Empty,
            sortDirection = sortDir,
            searchString = filtro ?? "",
            periodoId,
            usuarioId,
            estatusId
        };

        var response = await PostAsync<ApiResponse<ArticuloConteoResponse>>(
            "api/ArticuloConteo/GetAllPaginado",
            pagedRequest,
            useBaseUrl: false);

        return response ?? new ApiResponse<ArticuloConteoResponse>();
    }

    public async Task<ApiResponse<ArticuloConteoResponse>> CreateAsync(ArticuloConteoResponse entity)
    {
        if (!IsClientSide())
            return new ApiResponse<ArticuloConteoResponse>();

        var response = await PostAsync<ApiResponse<ArticuloConteoResponse>>(
            "api/ArticuloConteo",
            entity,
            useBaseUrl: false);

        return response ?? new ApiResponse<ArticuloConteoResponse>();
    }

    public async Task<ApiResponse<ArticuloConteoResponse>> UpdateAsync(ArticuloConteoResponse entity)
    {
        if (!IsClientSide())
            return new ApiResponse<ArticuloConteoResponse>();

        var id = entity.Id;
        if (id <= 0)
        {
            return new ApiResponse<ArticuloConteoResponse>
            {
                Success = false,
                Message = "ID no válido",
                Code = "INVALID_ID"
            };
        }

        var response = await PutAsync<ApiResponse<ArticuloConteoResponse>>(
            $"api/ArticuloConteo/{id}",
            entity,
            useBaseUrl: false);

        return response ?? new ApiResponse<ArticuloConteoResponse>
        {
            Success = false,
            Message = "Error al actualizar",
            Code = "ERROR"
        };
    }

    public async Task<ApiResponse<bool>> DeleteAsync(int id)
    {
        if (!IsClientSide())
            return new ApiResponse<bool>();

        var response = await DeleteAsync<ApiResponse<bool>>(
            $"api/ArticuloConteo/{id}",
            useBaseUrl: false);

        return response ?? new ApiResponse<bool>
        {
            Success = false,
            Message = "Error al eliminar",
            Code = "ERROR"
        };
    }

    public async Task<ApiResponse<List<ArticuloConteoResponse>>> GetByPeriodoAsync(int periodoId)
    {
        if (!IsClientSide())
            return new ApiResponse<List<ArticuloConteoResponse>>();

        var response = await GetAsync<ApiResponse<List<ArticuloConteoResponse>>>(
            $"api/ArticuloConteo/periodo/{periodoId}",
            useBaseUrl: false);

        return response ?? new ApiResponse<List<ArticuloConteoResponse>>();
    }

    public async Task<ApiResponse<List<ArticuloConteoResponse>>> GetByUsuarioAsync(int usuarioId)
    {
        if (!IsClientSide())
            return new ApiResponse<List<ArticuloConteoResponse>>();

        var response = await GetAsync<ApiResponse<List<ArticuloConteoResponse>>>(
            $"api/ArticuloConteo/usuario/{usuarioId}",
            useBaseUrl: false);

        return response ?? new ApiResponse<List<ArticuloConteoResponse>>();
    }

    public async Task<ApiResponse<ArticuloConteoResponse>> GetPaginadoByPeriodoAsync(
        int periodoId,
        int page = 1,
        int pageSize = 10,
        string filtro = "",
        string sortLabel = "",
        SortDirection sortDirection = SortDirection.Ascending)
    {
        if (!IsClientSide())
            return new ApiResponse<ArticuloConteoResponse>();

        string sortDir = sortDirection == SortDirection.Descending ? "Descending" : "Ascending";

        var pagedRequest = new
        {
            page = page,
            pageSize = pageSize,
            filtro = filtro ?? "",
            sortLabel = sortLabel ?? string.Empty,
            sortDirection = sortDir,
            searchString = filtro ?? ""
        };

        var response = await PostAsync<ApiResponse<ArticuloConteoResponse>>(
            $"api/ArticuloConteo/GetAllPaginado",
            pagedRequest,
            useBaseUrl: false);

        return response ?? new ApiResponse<ArticuloConteoResponse>();
    }

    public async Task<ApiResponse<bool>> CambiarEstatusAsync(int id, int estatusId)
    {
        if (!IsClientSide())
            return new ApiResponse<bool>();

        var jsonParams = new { estatusId };
        var response = await PostAsync<ApiResponse<bool>>(
            $"api/ArticuloConteo/{id}/cambiar-estatus",
            jsonParams,
            useBaseUrl: false);

        return response ?? new ApiResponse<bool>
        {
            Success = false,
            Message = "Error al cambiar estatus",
            Code = "ERROR"
        };
    }

    public async Task<ApiResponse<bool>> AsignarUsuarioAsync(int id, int usuarioId)
    {
        if (!IsClientSide())
            return new ApiResponse<bool>();

        var jsonParams = new { usuarioId };
        var response = await PostAsync<ApiResponse<bool>>(
            $"api/ArticuloConteo/{id}/asignar-usuario",
            jsonParams,
            useBaseUrl: false);

        return response ?? new ApiResponse<bool>
        {
            Success = false,
            Message = "Error al asignar usuario",
            Code = "ERROR"
        };
    }

    public async Task<ApiResponse<List<ArticuloConteoResponse>>> AddBatchAsync(List<ArticuloConteoResponse> articulos)
    {
        if (!IsClientSide())
            return new ApiResponse<List<ArticuloConteoResponse>>();

        var response = await PostAsync<ApiResponse<List<ArticuloConteoResponse>>>(
            "api/ArticuloConteo/add-batch",
            articulos,
            useBaseUrl: false);

        return response ?? new ApiResponse<List<ArticuloConteoResponse>>
        {
            Success = false,
            Message = "Error al agregar artículos",
            Code = "ERROR"
        };
    }
}
