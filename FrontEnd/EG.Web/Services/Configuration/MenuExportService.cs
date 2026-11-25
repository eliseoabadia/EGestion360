using PagedRequest = EG.Common.GenericModel.PagedRequest;
using EG.Common.Helper;
using EG.Common.Modules;
using EG.Dommain.DTOs.Responses;
using EG.Web.Contracts.Configuration;
using EG.Web.Models;
using Microsoft.JSInterop;

namespace EG.Web.Services.Configuration;

public sealed class MenuExportService(HttpClient httpClient, IJSRuntime jsRuntime,
    ApplicationInstance application, IConfiguration configuration, ILogger<MenuExportService> logger)
    : BaseService(httpClient, jsRuntime, application, configuration, logger), IMenuExportService
{
    public Task<ApiResponse<MenuItemsResponse>?> ExportAsync(PagedRequest request) =>
        PostAsync<ApiResponse<MenuItemsResponse>>($"{MenuModule.ApiRoute}/{MenuModule.ExportAction}", request, useBaseUrl: false);
}
