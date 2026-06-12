using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IDashboardAppService
    {
        Task<PagedResult<DashboardResumenResponse>> GetResumenAsync();
    }
}
