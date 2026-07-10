using EG.Common.Helper;
using EG.Domain.DTOs.Responses.PBR;
using EG.Web.Contracts;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;

namespace EG.Web.Services
{
    public class PbrDashboardService : BaseService, IPbrDashboardService
    {
        public PbrDashboardService(
            HttpClient httpClient,
            IJSRuntime jsRuntime,
            ApplicationInstance application,
            IConfiguration configuration,
            ILogger<PbrDashboardService> logger)
            : base(httpClient, jsRuntime, application, configuration, logger)
        {
        }

        public async Task<PbrDashboardResponse?> GetAsync(int anio)
            => await GetAsync<PbrDashboardResponse>($"api/PbrDashboard?anio={anio}", useBaseUrl: false);
    }
}
