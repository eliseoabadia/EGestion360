using EG.Common.Helper;
using EG.Web.Contracs.Configuration;
using EG.Web.Models.Configuration;
using Microsoft.AspNetCore.Components.Forms;
using Microsoft.JSInterop;
using SortDirection = MudBlazor.SortDirection;

namespace EG.Web.Services
{
    public class ProfileService : BaseService, IProfileService
    {
        public ProfileService(HttpClient httpClient, IJSRuntime jsRuntime, ApplicationInstance application)
            : base(httpClient, jsRuntime, application)
        {
        }

        public async Task<IList<UsuarioResponse>> GetAllUsers()
        {
            if (!IsClientSide())
                return new List<UsuarioResponse>();

            var result = await GetAsync<List<UsuarioResponse>>("api/UserProfile/");
            return result ?? new List<UsuarioResponse>();
        }

        public async Task<(List<UsuarioResponse> Usuarios, int Res)> GetAllUsuariosPaginadoAsync(
            int page = 1,
            int pageSize = 10,
            string filtro = "",
            string sortLabel = "",
            SortDirection _sortDirection = SortDirection.Ascending)
        {
            if (!IsClientSide())
                return (new List<UsuarioResponse>(), 0);

            string sortDirection = _sortDirection.ToString().Contains("Descending") ? "Descending" : "Ascending";

            var jsonParams = new
            {
                page = page,
                pageSize = pageSize,
                filtro = filtro ?? string.Empty,
                sortLabel = sortLabel ?? string.Empty,
                sortDirection = sortDirection
            };

            var result = await PostAsync<PagedResult<UsuarioResponse>>(
                "api/Usuario/GetAllUsuariosPaginado/",
                jsonParams,
                useBaseUrl: false);

            if (result != null && result.Items != null)
            {
                return (result.Items, result.TotalCount);
            }

            return (new List<UsuarioResponse>(), 0);
        }

        public async Task<UsuarioResponse> GetProfileUser(int _userId)
        {
            if (!IsClientSide())
                return new UsuarioResponse();

            var result = await GetAsync<UsuarioResponse>($"api/Usuario/{_userId}");
            return result ?? new UsuarioResponse();
        }

        public async Task<(bool resultado, string mensaje)> SetProfileUser(UsuarioResponse usuario, int _userId)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Post,
                    $"api/UserProfile/SetProfile/{_userId}/",
                    usuario,
                    useBaseUrl: false);

                return (result, success ? "Perfil actualizado correctamente" : message);
            });

            // Usamos el valor del resultado directamente (sin ??)
            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> CreateProfileUser(UsuarioResponse usuario)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Post,
                    "api/UserProfile/CreateProfile/",
                    usuario,
                    useBaseUrl: false);

                return (result, success ? "Perfil Creado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> SetProfileUserById(int userId, UsuarioResponse usuario)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Post,
                    $"api/UserProfile/SetProfile/{userId}/",
                    usuario,
                    useBaseUrl: false);

                return (result, success ? "Perfil actualizado correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<(bool resultado, string mensaje)> DeleteProfileUserById(int userId)
        {
            var operationResult = await ExecuteOperationAsync(async () =>
            {
                var (result, success, message) = await SendRequestWithMessageAsync<bool>(
                    HttpMethod.Post,
                    $"api/UserProfile/DeleteProfile/{userId}/",
                    userId,
                    useBaseUrl: false);

                return (result, success ? "Perfil dado de baja correctamente" : message);
            });

            return (operationResult.Result, operationResult.Message);
        }

        public async Task<FotografiaUsuarioResponse> GetProfileImageUser()
        {
            if (!IsClientSide())
                return new FotografiaUsuarioResponse();

            var payRollId = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", "userId");
            if (string.IsNullOrEmpty(payRollId))
            {
                await ClearAuthDataAsync();
                return new FotografiaUsuarioResponse();
            }

            int userId = int.Parse(payRollId);
            var result = await GetAsync<FotografiaUsuarioResponse>($"api/UserProfile/GetProfileImage/{userId}");
            return result ?? new FotografiaUsuarioResponse();
        }

        public async Task<bool> SetProfileImageUser(IBrowserFile file)
        {
            if (!IsClientSide() || file == null)
                return false;

            try
            {
                var payRollId = await _jsRuntime.InvokeAsync<string>("localStorage.getItem", "userId");
                if (string.IsNullOrEmpty(payRollId))
                {
                    await ClearAuthDataAsync();
                    return false;
                }

                int userId = int.Parse(payRollId);

                using var memoryStream = new MemoryStream();
                await file.OpenReadStream(maxAllowedSize: 2 * 1024 * 1024).CopyToAsync(memoryStream);
                var imageBytes = memoryStream.ToArray();

                var payload = new FotografiaUsuarioResponse
                {
                    FkidUsuarioSis = userId,
                    Fotografia = imageBytes,
                    ContentType = file.ContentType,
                    FileName = userId.ToString(),
                    FileExtension = Path.GetExtension(file.Name),
                    Activo = true,
                };

                var result = await PostAsync<bool>("api/UserProfile", payload, useBaseUrl: false);

                // Para bool, usamos el valor directamente
                return result is true;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error al establecer imagen de perfil: {ex.Message}");
                return false;
            }
        }
    }

    // Modelo auxiliar para paginación
    public class PagedResult<T>
    {
        public List<T>? Items { get; set; }
        public int TotalCount { get; set; }
    }
}