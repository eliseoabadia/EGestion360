using Mapster;
using EG.Business.Interfaces;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;


namespace EG.Business.Services
{
    public class NavigateService(IRepositorySP<spNodeMenuResult> repositorySP) : INavigateService
    {
        private readonly IRepositorySP<spNodeMenuResult> _repositorySP = repositorySP;

        public async Task<IEnumerable<spNodeMenuResponse>> GetMenuAsync(int empId)
        {
            var param1 = new SqlParameter("@NoEmploye", empId);
            var param2 = new SqlParameter("@Lenguaje", "ESP");
            var menu = await _repositorySP.ExecuteStoredProcedureAsync<spNodeMenuResult>("[SIS].[spNodeMenu]", param1, param2);
            return menu.Adapt<IEnumerable<spNodeMenuResponse>>();
        }

        /// <summary>
        /// Obtiene los claims del usuario desde la base de datos.
        /// EsParaLogin NO se envía (default en SP) — este método es para cargar permisos post-login.
        /// </summary>
        public async Task<List<spGetClaimsByUserResult>> ObtenerClaimsUsuarioAsync(int usuarioId)
        {
            if (usuarioId <= 0)
                throw new ArgumentException("Usuario ID debe ser mayor a 0", nameof(usuarioId));

            try
            {
                // Solo se pasa @PkIdUser; @EsParaLogin NO se envía (queda NULL/0 en el SP)
                var paramUserId = new SqlParameter("@PkIdUser", usuarioId);
                var resultClaims = await _repositorySP.ExecuteStoredProcedureAsync<spGetClaimsByUserResult>(
                    "[SIS].[spGetClaimsByUser]",
                    paramUserId);

                return resultClaims?.ToList() ?? new List<spGetClaimsByUserResult>();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error obteniendo claims para usuario {usuarioId}: {ex.Message}");
                throw;
            }
        }
    }
}