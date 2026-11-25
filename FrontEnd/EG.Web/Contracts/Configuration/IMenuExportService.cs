using PagedRequest = EG.Common.GenericModel.PagedRequest;
using EG.Dommain.DTOs.Responses;
using EG.Web.Models;

namespace EG.Web.Contracts.Configuration;

public interface IMenuExportService
{
    Task<ApiResponse<MenuItemsResponse>?> ExportAsync(PagedRequest request);
}
