using EG.Domain.DTOs.Responses.General;
using EG.Web.Models;

namespace EG.Web.Contracts
{
    public interface ILoginService
    {
        Task<UserResult> LoginAsync(string email, string password);
        Task<List<SucursalResponse>> GetSucursalesUsuarioAsync(int usuarioId);
        Task Logout();
    }
}
