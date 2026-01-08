using EG.Web.Models;

namespace EG.Web.Contracs
{
    public interface ILoginService
    {
        Task<UserResult> LoginAsync(string email, string password);
        Task Logout();
    }
}
