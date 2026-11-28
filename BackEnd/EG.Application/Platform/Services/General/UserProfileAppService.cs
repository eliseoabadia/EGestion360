using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Application.Interfaces.General;
using EG.Business.Interfaces;

namespace EG.Application.Services.General;

public sealed class UserProfileAppService(IUserProfileOperations service) : IUserProfileAppService
{
    public Task<PerfilUsuarioResponse> GetProfileImageAsync(int id) => service.GetProfileImageAsync(id);
    public Task<bool> CreateProfileAsync(UsuarioDto user) => service.CreateProfileAsync(user);
    public Task<bool> SetProfileAsync(int id, UsuarioDto user) => service.SetProfileAsync(id, user);
    public Task<bool> DeleteProfileAsync(int id) => service.DeleteProfileAsync(id);
    public Task<UsuarioResponse> GetProfileUserAsync(int id) => service.GetProfileUserAsync(id);
    public Task<IList<UsuarioResponse>> GetAllUsersAsync() => service.GetAllUsersAsync();
    public Task<PagedResult<UsuarioResponse>> GetAllUsersPaginadoAsync(PagedRequest _params) => service.GetAllUsersPaginadoAsync(_params);
    public Task UploadImageAsync(PerfilUsuarioResponse fotografia) => service.UploadImageAsync(fotografia);
    public Task<PagedResult<bool>> ChangePasswordAsync(int id, ChangePasswordDto request, int currentUserId) => service.ChangePasswordAsync(id, request, currentUserId);
}
