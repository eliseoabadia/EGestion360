namespace EG.Business.Interfaces.Operations;
public interface IPbrDashboardOperations

{
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.PBR.PbrDashboardResponse> GetAsync(global::System.Int32 anio);
}
