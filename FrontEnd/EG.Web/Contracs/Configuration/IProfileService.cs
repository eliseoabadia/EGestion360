using EG.Web.Models.Configuration;
using Microsoft.AspNetCore.Components.Forms;
using MudBlazor;

namespace EG.Web.Contracs.Configuration
{
    public interface IProfileService
    {
        Task<IList<UsuarioResponse>> GetAllUsers();
        Task<(List<UsuarioResponse> Usuarios, int Res)> GetAllUsuariosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending);
        Task<UsuarioResponse> GetProfileUser(int _userId);
        Task<(bool resultado, string mensaje)> SetProfileUser(UsuarioResponse usuario, int _userId);
        Task<(bool resultado, string mensaje)> CreateProfileUser(UsuarioResponse usuario);
        Task<(bool resultado, string mensaje)> SetProfileUserById(int userId, UsuarioResponse usuario);
        Task<(bool resultado, string mensaje)> DeleteProfileUserById(int userId);
        Task<FotografiaUsuarioResponse> GetProfileImageUser();
        Task<bool> SetProfileImageUser(IBrowserFile file);

    }
}
