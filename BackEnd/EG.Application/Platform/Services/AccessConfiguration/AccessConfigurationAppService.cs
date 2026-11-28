using EG.Common.GenericModel;
using EG.Domain.Platform.DTOs.Requests.AccessConfiguration;
using EG.Domain.Platform.DTOs.Responses.AccessConfiguration;
using EG.Application.Interfaces.AccessConfiguration;
using EG.Business.Interfaces;

namespace EG.Application.Services.AccessConfiguration;

public sealed class AccessConfigurationAppService(IAccessConfigurationOperations service) : IAccessConfigurationAppService
{
    public Task<AccessConfigurationSnapshotResponse> GetSnapshotAsync() => service.GetSnapshotAsync();
    public Task<AccessRoleDetailResponse> GetNewRoleTemplateAsync() => service.GetNewRoleTemplateAsync();
    public Task<AccessRoleDetailResponse> GetRoleDetailAsync(string roleId) => service.GetRoleDetailAsync(roleId);
    public Task<AccessUserRoleDetailResponse> GetUserRoleDetailAsync(int pkIdUsuario) => service.GetUserRoleDetailAsync(pkIdUsuario);
    public Task<AccessRoleDetailResponse> SaveRoleAsync(SaveAccessRoleRequest request, int operatorId) => service.SaveRoleAsync(request, operatorId);
    public Task<AccessUserRoleDetailResponse> SaveUserRolesAsync(SaveAccessUserRolesRequest request, int operatorId) => service.SaveUserRolesAsync(request, operatorId);
    public Task<int> SynchronizeMenuRolesAsync(int operatorId) => service.SynchronizeMenuRolesAsync(operatorId);
}
