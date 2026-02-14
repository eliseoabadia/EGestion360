using EG.Web.Models;
using EG.Web.Models.Configuration;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Contracs.Configuration
{
    public interface IUsuarioService
    {
        Task<ApiResponse<UsuarioResponse>> GetUsuarioByIdAsync(int usuarioId);

        Task<ApiResponse<UsuarioResponse>> GetAllUsuariosAsync();

        Task<ApiResponse<UsuarioResponse>> GetAllUsuariosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            int? empresaId = null,
            int? sucursalId = null,
            int? departamentoId = null,
            string estado = null,
            bool? puedeAcceder = null);

        Task<ApiResponse<UsuarioResponse>> CreateUsuarioAsync(UsuarioResponse usuario);

        Task<ApiResponse<UsuarioResponse>> UpdateUsuarioAsync(UsuarioResponse usuario);

        Task<ApiResponse<UsuarioResponse>> DeleteUsuarioAsync(int usuarioId);

        Task<ApiResponse<UsuarioResponse>> GetUsuariosPorEmpresaAsync(int empresaId);

        Task<ApiResponse<UsuarioResponse>> GetUsuariosPorSucursalAsync(int sucursalId);

        Task<ApiResponse<UsuarioResponse>> GetUsuariosPorDepartamentoAsync(int departamentoId);

        Task<ApiResponse<UsuarioResponse>> AsignarSucursalesAsync(int usuarioId, List<int> sucursalesIds);

        Task<ApiResponse<UsuarioResponse>> AsignarDepartamentoAsync(int usuarioId, int? departamentoId);

        Task<ApiResponse<UsuarioResponse>> CambiarEstadoRelacionAsync(int usuarioId, bool activa);
    }
}