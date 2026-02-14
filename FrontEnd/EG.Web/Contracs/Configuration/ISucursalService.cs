

using EG.Web.Models;
using EG.Web.Models.Configuration;
using MudBlazor;

namespace EG.Web.Contracs.Configuration
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