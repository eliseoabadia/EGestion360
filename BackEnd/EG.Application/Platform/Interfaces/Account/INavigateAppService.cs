using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Application.Interfaces.Account
{
    public interface INavigateAppService
    {
        Task<IEnumerable<spNodeMenuResponse>> GetMenuAsync(int userId);

        /// <summary>
        /// Obtiene todos los claims del usuario
        /// </summary>
        Task<List<spGetClaimsByUserResult>> GetAllClaimsByUser(int userId);
    }
}