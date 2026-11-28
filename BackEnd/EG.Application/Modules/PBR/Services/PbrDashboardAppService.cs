using EG.Domain.DTOs.Responses.PBR;
using System.Globalization;
using System.Text;
namespace EG.Application.Services.PBR;
    public interface IPbrDashboardAppService
    {
        Task<PbrDashboardResponse> GetAsync(int anio);
    }

public class PbrDashboardAppService(global::EG.Business.Services.PBR.PbrDashboardOperationsService service) : global::EG.Application.Services.PBR.IPbrDashboardAppService

{
    public global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.PBR.PbrDashboardResponse> GetAsync(global::System.Int32 anio) => service.GetAsync(anio);
}
