
using EG.Web.Models.Configuration;

namespace EG.Web.Contracs.Configuration
{
    public interface INavigateService
    {
        Task<MenuResponse> GetMenuAsync(int _userId);
    }
}
