using EG.Application.Interfaces.General;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Services.General;

public sealed class DashboardAppService(IDashboardService service) : IDashboardAppService
{
    public Task<PagedResult<DashboardResumenResponse>> GetResumenAsync() => service.GetResumenAsync();
}
