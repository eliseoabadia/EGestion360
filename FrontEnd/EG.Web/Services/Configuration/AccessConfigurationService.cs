using EG.Common.Helper;
using EG.Domain.Platform.DTOs.Requests.AccessConfiguration;
using EG.Domain.Platform.DTOs.Responses.AccessConfiguration;
using EG.Web.Contracts.Configuration;
using EG.Web.Models;
using Microsoft.JSInterop;

namespace EG.Web.Services.Configuration;

public sealed class AccessConfigurationService(
    IConfiguration configuration,
    HttpClient httpClient,
    IJSRuntime jsRuntime,
    ApplicationInstance application) : BaseService(httpClient, jsRuntime, application, configuration), IAccessConfigurationService
{
    private const string Endpoint = "api/AccessConfiguration";

    public async Task<ApiResponse<AccessConfigurationSnapshotResponse>> GetSnapshotAsync()
    {
        if (!IsClientSide())
        {
            return new ApiResponse<AccessConfigurationSnapshotResponse>();
        }

        return await GetAsync<ApiResponse<AccessConfigurationSnapshotResponse>>($"{Endpoint}/snapshot", useBaseUrl: false)
            ?? new ApiResponse<AccessConfigurationSnapshotResponse>();
    }

    public async Task<ApiResponse<AccessRoleDetailResponse>> GetRoleDetailAsync(string roleId)
    {
        if (!IsClientSide())
        {
            return new ApiResponse<AccessRoleDetailResponse>();
        }

        return await GetAsync<ApiResponse<AccessRoleDetailResponse>>($"{Endpoint}/roles/{Uri.EscapeDataString(roleId)}", useBaseUrl: false)
            ?? new ApiResponse<AccessRoleDetailResponse>();
    }

    public async Task<ApiResponse<AccessRoleDetailResponse>> GetNewRoleTemplateAsync()
    {
        if (!IsClientSide())
        {
            return new ApiResponse<AccessRoleDetailResponse>();
        }

        return await GetAsync<ApiResponse<AccessRoleDetailResponse>>($"{Endpoint}/roles/template", useBaseUrl: false)
            ?? new ApiResponse<AccessRoleDetailResponse>();
    }

    public async Task<ApiResponse<AccessRoleDetailResponse>> SaveRoleAsync(SaveAccessRoleRequest request)
    {
        if (!IsClientSide())
        {
            return new ApiResponse<AccessRoleDetailResponse>();
        }

        return await PostAsync<ApiResponse<AccessRoleDetailResponse>>($"{Endpoint}/roles/save", request, useBaseUrl: false)
            ?? new ApiResponse<AccessRoleDetailResponse>();
    }

    public async Task<ApiResponse<int>> SynchronizeMenuRolesAsync()
    {
        if (!IsClientSide())
        {
            return new ApiResponse<int>();
        }

        return await PostAsync<ApiResponse<int>>($"{Endpoint}/synchronize-menu-roles", new { }, useBaseUrl: false)
            ?? new ApiResponse<int>();
    }
}
