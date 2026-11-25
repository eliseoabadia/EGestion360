using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;

namespace EG.Application.Interfaces.General;

public interface IMenuAppService
{
    Task<PagedResult<MenuItemsResponse>> GetAllAsync();
    Task<PagedResult<MenuItemsResponse>> GetByIdAsync(int id);
    Task<PagedResult<MenuItemsResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<MenuItemsResponse>> GetTreePageAsync(PagedRequest request);
    Task<PagedResult<MenuItemsResponse>> ExportAsync(PagedRequest request);
    Task<PagedResult<MenuItemsResponse>> SaveAsync(MenuItemsDto dto, int? id = null);
    Task<PagedResult<MenuItemsResponse>> DeleteAsync(int id);
    Task<PagedResult<MenuItemsResponse>> ValidateAsync(MenuItemsDto dto);
    Task<PagedResult<MenuItemsResponse>> ReorderAsync(IReadOnlyCollection<MenuOrderDto> menus);
}
