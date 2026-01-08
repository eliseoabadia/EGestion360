using EG.Dommain.DTOs.Responses;

namespace EG.Business.Interfaces
{
    public interface INavigateService
    {
        Task<IEnumerable<spNodeMenuResponse>> GetMenuAsync(int empId);
    }
}
