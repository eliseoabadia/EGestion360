
using EG.Common.GenericModel;
using EG.Web.Models.Configuration;

namespace EG.Web.Contracts.Configuration
{
    public interface INavigateService
    {
        Task<MenuResponse> GetMenuAsync(int _userId);

        /// <summary>
        /// Obtiene los claims del usuario desde el backend y los carga en el AuthProvider
        /// </summary>
        Task<List<ClaimItemModel>> GetAllClaimsByUserAsync(int userId);
    }
}
