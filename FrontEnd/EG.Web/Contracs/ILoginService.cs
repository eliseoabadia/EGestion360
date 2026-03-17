using EG.Web.Models;
using EG.Web.Models.Configuration;

namespace EG.Web.Contracs
{
    public interface ILoginService
    {
        Task<UserResult> LoginAsync(string email, string password);
        Task<List<SucursalResponse>> GetSucursalesUsuarioAsync(int usuarioId);
        Task Logout();
    }
}
