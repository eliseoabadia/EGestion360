using System.Net;
using System.Net.Http.Json;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using Microsoft.AspNetCore.Components;

namespace EG.Web.Pages.Platform.Account;

public partial class ResetPassword
{
    [Inject] private IHttpClientFactory ClientFactory { get; set; } = default!;
    [Inject] private NavigationManager Navigation { get; set; } = default!;

    private readonly ForgotPasswordRequest _forgot = new();
    private readonly ResetPasswordRequest _reset = new();
    private bool _busy;
    private bool _hasToken;
    private bool _ready;
    private bool _success;
    private bool _completed;
    private string? _message;

    protected override void OnInitialized()
    {
        // Fragment keeps the token out of server access logs and referrer headers.
        var fragment = new Uri(Navigation.Uri).Fragment;
        if (fragment.StartsWith("#token=", StringComparison.Ordinal))
        {
            _reset.Token = Uri.UnescapeDataString(fragment[7..]);
            _hasToken = true;

            // Keep the bearer token only in component memory, not in the address bar or history.
            var sanitizedUri = new UriBuilder(new Uri(Navigation.Uri))
            {
                Fragment = string.Empty
            };
            Navigation.NavigateTo(sanitizedUri.Uri.AbsoluteUri, replace: true);
        }
        _ready = true;
    }

    private Task RequestAsync() => SendAsync("api/Auth/forgot-password", _forgot);

    private Task ResetAsync() => SendAsync("api/Auth/reset-password", _reset);

    private void RequestAnotherLink()
    {
        _hasToken = false;
        _reset.Token = string.Empty;
        _reset.NewPassword = string.Empty;
        _reset.ConfirmPassword = string.Empty;
        _message = null;
        Navigation.NavigateTo("resetPassword", replace: true);
    }

    private async Task SendAsync<TRequest>(string endpoint, TRequest request)
    {
        if (_busy)
        {
            return;
        }

        _busy = true;
        _message = null;
        try
        {
            using var response = await ClientFactory.CreateClient("ApiClient").PostAsJsonAsync(endpoint, request);
            if (response.StatusCode == HttpStatusCode.TooManyRequests)
            {
                _success = false;
                _message = "Se alcanzó el límite de intentos. Espera unos minutos antes de volver a intentar.";
                return;
            }

            var result = response.Content.Headers.ContentType?.MediaType == "application/json"
                ? await response.Content.ReadFromJsonAsync<PagedResult<bool>>()
                : null;
            _success = response.IsSuccessStatusCode && result?.Success == true;
            _message = result?.Message ?? "No fue posible completar la solicitud. Revisa los datos e intenta nuevamente.";
            _completed = _success;
            if (_success)
            {
                _reset.Token = string.Empty;
                _reset.NewPassword = string.Empty;
                _reset.ConfirmPassword = string.Empty;
            }
        }
        catch (Exception exception) when (exception is HttpRequestException or TaskCanceledException or System.Text.Json.JsonException)
        {
            _success = false;
            _message = "No pudimos confirmar el resultado. Revisa tu correo o intenta iniciar sesión antes de repetir la solicitud.";
        }
        finally
        {
            _busy = false;
        }
    }
}
