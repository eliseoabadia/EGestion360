using EG.Web.Auth;
using EG.Web.Contracts;
using EG.Web.Contracts.Configuration;
using EG.Web.Models;
using EG.Web.Models.DTO;
using EG.Domain.DTOs.Responses.General;
using EG.Web.Services;
using MudBlazor;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.JSInterop;

namespace EG.Web.Pages.Platform.Account;

public partial class Login
{
    private LoginDTO login = new();
    private MudForm? loginForm;
    private const string UserInputId = "login-usuario";
    private const string PasswordInputId = "login-password";

    private bool isShow;
    private bool isLoading;
    private bool disposed;
    private string loginStatus = "Validando credenciales";
    private InputType passwordInputType = InputType.Password;
    private string passwordIcon = Icons.Material.Filled.VisibilityOff;
    private string LoginStatusText => string.IsNullOrWhiteSpace(loginStatus) ? "Validando credenciales" : loginStatus;
    private string LoginButtonText => LoginStatusText.EndsWith("...", StringComparison.Ordinal) ? LoginStatusText : $"{LoginStatusText}...";

    [Inject] private HttpClient HttpClient { get; set; } = null!;

    protected override async Task OnInitializedAsync()
    {
        await ThemeStateService.InitializeAsync();
        if (disposed) return;
        ThemeStateService.OnThemeChanged += OnThemeChanged;
    }

    private void OnThemeChanged(AppThemeOption option)
    {
        if (disposed) return;
        _ = InvokeAsync(StateHasChanged);
    }

    private async Task SelectThemeAsync(AppThemeOption option)
    {
        await ThemeStateService.SetThemeAsync(option);
    }

    private static string GetThemeIcon(AppThemeOption option) => option switch
    {
        AppThemeOption.Claro => Icons.Material.Outlined.LightMode,
        AppThemeOption.Oscuro => Icons.Material.Outlined.DarkMode,
        AppThemeOption.Morena => Icons.Material.Filled.LocalFireDepartment,
        _ => Icons.Material.Outlined.DarkMode
    };

    private static string GetThemeLabel(AppThemeOption option) =>
        EG.Web.Services.ThemeStateService.GetThemeName(option);

    private string GetLoginThemeButtonClass(AppThemeOption option) =>
        ThemeStateService.SelectedOption == option
            ? "login-theme-button active"
            : "login-theme-button";

    private void TogglePasswordVisibility()
    {
        isShow = !isShow;
        passwordIcon = isShow ? Icons.Material.Filled.Visibility : Icons.Material.Filled.VisibilityOff;
        passwordInputType = isShow ? InputType.Text : InputType.Password;
    }

    private async Task HandleLogin()
    {
        if (isLoading || disposed)
            return;

        isLoading = true;
        try
        {
            await SyncBrowserCredentialValuesAsync();
            if (disposed) return;

            if (loginForm != null)
            {
                await loginForm.Validate();
                if (!loginForm.IsValid)
                {
                    Snackbar.Add("Completa usuario y contrasena.", Severity.Warning);
                    return;
                }
            }

            SetLoginStatus("Validando credenciales");
            await InvokeAsync(StateHasChanged);

            UserResult result = await LoginService.LoginAsync(login.Usuario.Trim(), login.Password);
            if (disposed) return;

            if (result != null && !string.Equals(result.PayrollId, "0", StringComparison.Ordinal))
            {
                SetLoginStatus("Activando sesion");
                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", "authToken", result.AccessToken);
                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", "userId", result.PkIdUsuario);
                await _jsRuntime.InvokeVoidAsync("localStorage.setItem", "userName", result.NombreUsuario);
                if (AuthenticationStateProvider is not AuthenticationProviderJWT authProvider)
                {
                    Snackbar.Add("No se pudo inicializar la sesion local.", Severity.Error);
                    return;
                }

                await authProvider.LoginAsync(result.AccessToken);
                if (!await WaitForAuthenticatedSessionAsync())
                {
                    Snackbar.Add("La sesion se valido en el servidor, pero no pudo activarse en el navegador.", Severity.Error);
                    return;
                }

                // Los permisos se cargan fuera del JWT para mantener pequena la
                // cabecera Authorization aunque el usuario tenga muchos accesos.
                SetLoginStatus("Cargando permisos y sucursales");
                var permissionClaimsTask = _navigateService.GetAllClaimsByUserAsync(result.PkIdUsuario);
                var sucursalesTask = LoadSucursalesUsuarioAsync(result.PkIdUsuario, result.AccessToken);
                await Task.WhenAll(permissionClaimsTask, sucursalesTask);
                if (disposed) return;

                var permissionClaims = await permissionClaimsTask;
                SetLoginStatus("Aplicando permisos");
                if (!await authProvider.LoadClaimsFromDbAsync(permissionClaims, result.AccessToken))
                {
                    Snackbar.Add("La sesión cambió durante el acceso. Inicia sesión nuevamente.", Severity.Warning);
                    return;
                }
                if (!await WaitForAuthenticatedSessionAsync())
                {
                    Snackbar.Add("No se pudo confirmar la sesion despues de cargar permisos.", Severity.Error);
                    return;
                }

                var sucursalesUsuario = await sucursalesTask;

                if (sucursalesUsuario.Success != true)
                {
                    Snackbar.Add(sucursalesUsuario.Message ?? "No se pudieron cargar las sucursales del usuario.", Severity.Error);
                }
                else if (sucursalesUsuario.Items.Count > 1)
                {
                    var parameters = new DialogParameters { { "Sucursales", sucursalesUsuario.Items.ToList() } };
                    var options = new DialogOptions
                    {
                        CloseOnEscapeKey = false,
                        FullWidth = true,
                        MaxWidth = MaxWidth.Small,
                        BackdropClick = false
                    };
                    var dialog = await DialogService.ShowAsync<SelectSucursalDialog>("Seleccionar Sucursal", parameters, options);
                    var dialogResult = await dialog.Result;
                    if (disposed) return;

                    if (dialogResult == null || dialogResult.Canceled)
                        return;

                    var selectedSucursal = dialogResult.Data as UsuarioSucursalResponse;
                    if (selectedSucursal != null)
                    {
                        SetLoginStatus("Abriendo inicio");
                        Snackbar.Add($"Sucursal seleccionada: {selectedSucursal.NombreSucursal}", Severity.Info);
                        NavigateToAuthenticatedHome();
                    }
                }
                else if (sucursalesUsuario.Items.Count == 1)
                {
                    SetLoginStatus("Abriendo inicio");
                    await SucursalStateService.SetSucursalAsync(
                        sucursalesUsuario.Items[0].IdSucursal,
                        sucursalesUsuario.Items[0].NombreSucursal,
                        GetEmpresaId(sucursalesUsuario.Items[0]),
                        sucursalesUsuario.Items[0].NombreEmpresa);
                    Snackbar.Add("Bienvenido.", Severity.Success);
                    NavigateToAuthenticatedHome();
                }
                else
                {
                    Snackbar.Add(sucursalesUsuario.Message ?? "No tienes sucursales asignadas. Contacta al administrador.", Severity.Warning);
                }
            }
            else
            {
                Snackbar.Add(result?.Message ?? "El usuario o la contrasena no son correctos.", Severity.Error);
            }
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "Fallo el flujo de inicio de sesion en la interfaz.");
            Snackbar.Add(EG.Common.UserFacingMessages.OperationFailed("iniciar sesion"), Severity.Error);
        }
        finally
        {
            isLoading = false;
            loginStatus = "Validando credenciales";
        }
    }

    private void SetLoginStatus(string status)
    {
        if (disposed) return;
        loginStatus = status;
        _ = InvokeAsync(StateHasChanged);
    }

    private async Task SyncBrowserCredentialValuesAsync()
    {
        try
        {
            var credentials = await _jsRuntime.InvokeAsync<LoginBrowserCredentials>(
                "egestionLogin.getCredentials",
                UserInputId,
                PasswordInputId);

            if (credentials == null)
            {
                return;
            }

            login.Usuario = credentials.Usuario?.Trim() ?? string.Empty;
            login.Password = credentials.Password ?? string.Empty;
        }
        catch (Exception ex)
        {
            Logger.LogDebug(ex, "No fue posible sincronizar las credenciales administradas por el navegador.");
            login.Usuario ??= string.Empty;
            login.Password ??= string.Empty;
        }
    }

    private sealed class LoginBrowserCredentials
    {
        public string? Usuario { get; set; }
        public string? Password { get; set; }
    }

    private async Task<bool> WaitForAuthenticatedSessionAsync()
    {
        for (var attempt = 0; attempt < 6; attempt++)
        {
            if (disposed) return false;
            var authState = await AuthenticationStateProvider.GetAuthenticationStateAsync();
            if (authState.User.Identity?.IsAuthenticated == true)
            {
                return true;
            }

            await Task.Delay(100);
        }

        return false;
    }

    private void NavigateToAuthenticatedHome()
    {
        if (disposed) return;
        NavigationManager.NavigateTo(
            $"/?login=1&t={DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()}",
            forceLoad: true,
            replace: true);
    }

    private static int? GetEmpresaId(UsuarioSucursalResponse sucursal)
    {
        if (sucursal.PkidEmpresa > 0)
            return sucursal.PkidEmpresa;

        if (sucursal.IdEmpresa.GetValueOrDefault() > 0)
            return sucursal.IdEmpresa;

        return null;
    }

    private async Task<ApiResponse<UsuarioSucursalResponse>> LoadSucursalesUsuarioAsync(int usuarioId, string? accessToken)
    {
        try
        {
            using var request = new HttpRequestMessage(HttpMethod.Get, $"api/UsuarioSucursal/usuario/{usuarioId}");
            request.Headers.Authorization =
                new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", accessToken?.Trim('"', '\''));

            using var response = await HttpClient.SendAsync(request);
            var responseBody = await response.Content.ReadAsStringAsync();
            var result = string.IsNullOrWhiteSpace(responseBody)
                ? null
                : System.Text.Json.JsonSerializer.Deserialize<ApiResponse<UsuarioSucursalResponse>>(
                    responseBody,
                    new System.Text.Json.JsonSerializerOptions { PropertyNameCaseInsensitive = true });

            if (response.IsSuccessStatusCode)
            {
                return result ?? new ApiResponse<UsuarioSucursalResponse>
                {
                    Success = false,
                    Message = "No se pudieron leer las sucursales del usuario."
                };
            }

            return result ?? new ApiResponse<UsuarioSucursalResponse>
            {
                Success = false,
                Message = $"Error al cargar sucursales: {(int)response.StatusCode} {response.ReasonPhrase}"
            };
        }
        catch (Exception ex)
        {
            Logger.LogError(ex, "No fue posible cargar las sucursales del usuario {UsuarioId} durante el acceso.", usuarioId);
            return new ApiResponse<UsuarioSucursalResponse>
            {
                Success = false,
                Message = EG.Common.UserFacingMessages.OperationFailed("cargar las sucursales disponibles")
            };
        }
    }

    public void Dispose()
    {
        disposed = true;
        ThemeStateService.OnThemeChanged -= OnThemeChanged;
    }
}
