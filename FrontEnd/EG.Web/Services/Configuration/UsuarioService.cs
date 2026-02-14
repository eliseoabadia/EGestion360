using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
using EG.Web.Models;
using EG.Web.Models.Configuration;
using Microsoft.JSInterop;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services.Configuration
{
    public class UsuarioService : BaseService, IUsuarioService
    {
        public UsuarioService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
            : base(httpClient, jsRuntime, application)
        {
        }

        public async Task<ApiResponse<UsuarioResponse>> GetUsuarioByIdAsync(int usuarioId)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            return await GetAsync<ApiResponse<UsuarioResponse>>($"api/Usuario/{usuarioId}");
        }

        public async Task<ApiResponse<UsuarioResponse>> GetAllUsuariosAsync()
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            var response = await GetAsync<ApiResponse<UsuarioResponse>>("api/Usuario/", useBaseUrl: false);
            return response ?? new ApiResponse<UsuarioResponse>();
        }

        public async Task<ApiResponse<UsuarioResponse>> GetAllUsuariosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection sortDirection = SortDirection.Ascending,
            int? empresaId = null,
            int? sucursalId = null,
            int? departamentoId = null,
            string estado = null,
            bool? puedeAcceder = null)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            string sortDir = sortDirection == SortDirection.Descending ? "Descending" : "Ascending";

            var jsonParams = new
            {
                page,
                pageSize,
                filtro = filtro ?? "",
                sortLabel = sortLabel ?? string.Empty,
                sortDirection = sortDir,
                empresaId,
                sucursalId,
                departamentoId,
                estado,
                puedeAcceder
            };

            var response = await PostAsync<ApiResponse<UsuarioResponse>>(
                "api/Usuario/GetAllUsuariosPaginado/",
                jsonParams,
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>();
        }

        public async Task<ApiResponse<UsuarioResponse>> CreateUsuarioAsync(UsuarioResponse usuario)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            var response = await PostAsync<ApiResponse<UsuarioResponse>>(
                "api/Usuario/",
                usuario,
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>();
        }

        public async Task<ApiResponse<UsuarioResponse>> UpdateUsuarioAsync(UsuarioResponse usuario)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            if (usuario.PkIdUsuario <= 0)
                return new ApiResponse<UsuarioResponse>
                {
                    Success = false,
                    Message = "ID de usuario no válido",
                    Code = "INVALID_ID"
                };

            var response = await PutAsync<ApiResponse<UsuarioResponse>>(
                $"api/Usuario/{usuario.PkIdUsuario}/",
                usuario,
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>
            {
                Success = false,
                Message = "Error al actualizar usuario",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<UsuarioResponse>> DeleteUsuarioAsync(int usuarioId)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            var response = await DeleteAsync<ApiResponse<UsuarioResponse>>(
                $"api/Usuario/{usuarioId}/",
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>
            {
                Success = false,
                Message = "Error al eliminar usuario",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<UsuarioResponse>> GetUsuariosPorEmpresaAsync(int empresaId)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            var response = await GetAsync<ApiResponse<UsuarioResponse>>(
                $"api/Usuario/empresa/{empresaId}",
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>();
        }

        public async Task<ApiResponse<UsuarioResponse>> GetUsuariosPorSucursalAsync(int sucursalId)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            var response = await GetAsync<ApiResponse<UsuarioResponse>>(
                $"api/Usuario/sucursal/{sucursalId}",
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>
            {
                Success = false,
                Message = "Error al obtener usuarios por sucursal",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<UsuarioResponse>> GetUsuariosPorDepartamentoAsync(int departamentoId)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            var response = await GetAsync<ApiResponse<UsuarioResponse>>(
                $"api/Usuario/departamento/{departamentoId}",
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>
            {
                Success = false,
                Message = "Error al obtener usuarios por departamento",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<UsuarioResponse>> AsignarSucursalesAsync(int usuarioId, List<int> sucursalesIds)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            var jsonParams = new
            {
                usuarioId,
                sucursalesIds
            };

            var response = await PostAsync<ApiResponse<UsuarioResponse>>(
                $"api/Usuario/{usuarioId}/asignar-sucursales/",
                jsonParams,
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>
            {
                Success = false,
                Message = "Error al asignar sucursales",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<UsuarioResponse>> AsignarDepartamentoAsync(int usuarioId, int? departamentoId)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            var jsonParams = new
            {
                usuarioId,
                departamentoId
            };

            var response = await PostAsync<ApiResponse<UsuarioResponse>>(
                $"api/Usuario/{usuarioId}/asignar-departamento/",
                jsonParams,
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>
            {
                Success = false,
                Message = "Error al asignar departamento",
                Code = "ERROR"
            };
        }

        public async Task<ApiResponse<UsuarioResponse>> CambiarEstadoRelacionAsync(int usuarioId, bool activa)
        {
            if (!IsClientSide())
                return new ApiResponse<UsuarioResponse>();

            var jsonParams = new
            {
                usuarioId,
                activa
            };

            var response = await PostAsync<ApiResponse<UsuarioResponse>>(
                $"api/Usuario/{usuarioId}/cambiar-estado-relacion/",
                jsonParams,
                useBaseUrl: false);

            return response ?? new ApiResponse<UsuarioResponse>
            {
                Success = false,
                Message = "Error al cambiar estado de relación",
                Code = "ERROR"
            };
        }

    }
}