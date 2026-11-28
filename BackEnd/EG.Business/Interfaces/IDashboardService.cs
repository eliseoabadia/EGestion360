using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Business.Interfaces;

public interface IDashboardService
{
    Task<PagedResult<DashboardResumenResponse>> GetResumenAsync();
}
