using EG.Dommain.DTOs.Responses;

namespace EG.Application.Interfaces.Account
{
    public interface INavigateAppService
    {
        Task<IEnumerable<spNodeMenuResponse>> GetMenuAsync(int userId);
    }
}