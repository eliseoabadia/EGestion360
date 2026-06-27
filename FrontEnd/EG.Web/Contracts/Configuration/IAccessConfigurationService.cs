using EG.Domain.Platform.DTOs.Requests.AccessConfiguration;
using EG.Domain.Platform.DTOs.Responses.AccessConfiguration;
using EG.Web.Models;

namespace EG.Web.Contracts.Configuration;

public interface IAccessConfigurationService
{
    Task<ApiResponse<AccessConfigurationSnapshotResponse>> GetSnapshotAsync();
    Task<ApiResponse<AccessRoleDetailResponse>> GetNewRoleTemplateAsync();
    Task<ApiResponse<AccessRoleDetailResponse>> GetRoleDetailAsync(string roleId);
    Task<ApiResponse<AccessRoleDetailResponse>> SaveRoleAsync(SaveAccessRoleRequest request);
    Task<ApiResponse<int>> SynchronizeMenuRolesAsync();
}
