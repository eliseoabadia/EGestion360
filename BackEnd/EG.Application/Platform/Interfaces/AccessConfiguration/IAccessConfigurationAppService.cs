using EG.Domain.Platform.DTOs.Requests.AccessConfiguration;
using EG.Domain.Platform.DTOs.Responses.AccessConfiguration;

namespace EG.Application.Interfaces.AccessConfiguration;

public interface IAccessConfigurationAppService
{
    Task<AccessConfigurationSnapshotResponse> GetSnapshotAsync();
    Task<AccessRoleDetailResponse> GetNewRoleTemplateAsync();
    Task<AccessRoleDetailResponse> GetRoleDetailAsync(string roleId);
    Task<AccessUserRoleDetailResponse> GetUserRoleDetailAsync(int pkIdUsuario);
    Task<AccessRoleDetailResponse> SaveRoleAsync(SaveAccessRoleRequest request, int operatorId);
    Task<AccessUserRoleDetailResponse> SaveUserRolesAsync(SaveAccessUserRolesRequest request, int operatorId);
    Task<int> SynchronizeMenuRolesAsync(int operatorId);
}
