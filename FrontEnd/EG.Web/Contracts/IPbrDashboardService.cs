using EG.Domain.DTOs.Responses.PBR;

namespace EG.Web.Contracts
{
    public interface IPbrDashboardService
    {
        Task<PbrDashboardResponse?> GetAsync(int anio);
    }
}
