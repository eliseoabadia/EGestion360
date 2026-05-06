

using EG.Domain.DTOs.Responses.General;
using EG.Web.Models;
using MudBlazor;

namespace EG.Web.Contracts.Configuration
{
    public interface ISucursalService
    {
        Task<ApiResponse<SucursalResponse>> GetAllSucursales();

        Task<ApiResponse<SucursalResponse>> GetAllSucursalesPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending);

        Task<ApiResponse<SucursalResponse>> GetSucursalByIdAsync(int sucursalId);

        Task<ApiResponse<SucursalResponse>> CreateSucursalAsync(SucursalResponse sucursal);

        Task<ApiResponse<SucursalResponse>> UpdateSucursalAsync(SucursalResponse sucursal);

        Task<ApiResponse<SucursalResponse>> DeleteSucursalAsync(int sucursalId);

    }
}