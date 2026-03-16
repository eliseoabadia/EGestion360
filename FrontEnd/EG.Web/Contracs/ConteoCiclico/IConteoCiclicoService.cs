using EG.Web.Models;
using EG.Web.Models.ConteoCiclico;

namespace EG.Web.Contracs.ConteoCiclico
{
    public interface IConteoCiclicoService
    {
        Task<ApiResponse<ConteoResult>> GenerarConteoAsync(GenerarConteoRequest request);
        Task<ApiResponse<ConteoResult>> IniciarConteoAsync(int articuloConteoId);
        Task<ApiResponse<ConteoResult>> RegistrarConteoAsync(RegistrarConteoRequest request);
        Task<ApiResponse<ConteoResult>> CerrarConteoAsync(CerrarConteoRequest request);
        Task<DashboardResponse> GetDashboardAsync(int? sucursalId = null);
    }
}