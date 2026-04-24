using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Interfaces
{
    public interface INavigateService
    {
        Task<IEnumerable<spNodeMenuResponse>> GetMenuAsync(int empId);

        /// <summary>
        /// Obtiene los claims del usuario desde la base de datos
        /// </summary>
        Task<List<spGetClaimsByUserResult>> ObtenerClaimsUsuarioAsync(int usuarioId);
    }
}
