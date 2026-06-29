using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;

namespace EG.Application.Interfaces.General
{
    public interface IUserProfileAppService
    {
        Task<PerfilUsuarioResponse> GetProfileImageAsync(int id);
        Task<bool> CreateProfileAsync(UsuarioDto user);
        Task<bool> SetProfileAsync(int id, UsuarioDto user);
        Task<bool> DeleteProfileAsync(int id);
        Task<UsuarioResponse> GetProfileUserAsync(int id);
        Task<IList<UsuarioResponse>> GetAllUsersAsync();
        Task<PagedResult<UsuarioResponse>> GetAllUsersPaginadoAsync(PagedRequest _params);
        Task UploadImageAsync(PerfilUsuarioResponse fotografia);
        Task<PagedResult<bool>> ChangePasswordAsync(int id, ChangePasswordDto request, int currentUserId);
    }
}
