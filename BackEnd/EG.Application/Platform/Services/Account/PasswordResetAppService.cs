using System.ComponentModel.DataAnnotations;
using EG.Application.Interfaces.Account;
using EG.Application.Interfaces.General;
using EG.Application.Services.General;
using EG.Common;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;
using EG.Domain.Settings;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EG.Application.Services.Account;

public sealed class PasswordResetAppService(
    IPasswordResetRepository repository,
    IPasswordResetTokenService tokens,
    IEmailService email,
    IOptions<EmailSettings> emailSettings,
    IConfiguration configuration,
    ILogger<PasswordResetAppService> logger) : IPasswordResetAppService
{
    public async Task<PagedResult<bool>> RequestAsync(ForgotPasswordRequest request, CancellationToken cancellationToken)
    {
        if (!Validator.TryValidateObject(request, new ValidationContext(request), [], true))
        {
            return Result(false, "Captura un correo electrónico válido.");
        }

        var frontend = GetFrontendUri();
        var smtp = emailSettings.Value;
        if (frontend == null || !EmailConfigurationValidator.IsValid(smtp))
        {
            logger.LogError("La recuperación de acceso requiere una URL de frontend válida y configuración SMTP completa.");
            var unavailable = Result(false, "La recuperación por correo no está disponible. Contacta al administrador.");
            unavailable.Code = "RECOVERY_UNAVAILABLE";
            return unavailable;
        }

        var account = await repository.FindActiveByEmailAsync(request.Email.Trim(), cancellationToken);
        if (account != null)
        {
            var link = new Uri(frontend.AbsoluteUri.TrimEnd('/') + "/resetPassword");
            var resetUrl = link.AbsoluteUri + "#token=" + Uri.EscapeDataString(tokens.Create(account));
            var sent = await email.SendAsync(new EmailMessageRequest
            {
                To = [account.Email],
                Subject = "Restablecer contraseña de EGestion360",
                IsHtml = false,
                Body = "Recibimos una solicitud para restablecer tu contraseña. Abre el siguiente enlace:\n\n" +
                    resetUrl + "\n\nEl enlace vence en 30 minutos y deja de funcionar al cambiar la contraseña. " +
                    "Si no hiciste esta solicitud, ignora este correo."
            }, cancellationToken);
            if (!sent.Success)
            {
                // Never log the mail body, reset token or SMTP error containing sensitive information.
                logger.LogError("No se pudo enviar el correo de recuperación de acceso.");
            }
        }

        return Result(true, "Si el correo corresponde a una cuenta activa, recibirás un enlace para restablecer tu contraseña.");
    }

    private Uri? GetFrontendUri()
    {
        var frontendUrl = configuration["PasswordReset:FrontendUrl"];
        if (string.IsNullOrWhiteSpace(frontendUrl))
        {
            // A single HTTPS frontend already allowed by the server is a trusted fallback.
            var origins = configuration.GetSection("CorsSettings:AllowOrigins").GetChildren()
                .Select(origin => origin.Value)
                .Where(origin => Uri.TryCreate(origin, UriKind.Absolute, out var uri) && uri.Scheme == Uri.UriSchemeHttps)
                .Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
            frontendUrl = origins.Length == 1 ? origins[0] : null;
        }

        if (!Uri.TryCreate(frontendUrl, UriKind.Absolute, out var frontend) ||
            !string.IsNullOrEmpty(frontend.UserInfo) || !string.IsNullOrEmpty(frontend.Query) || !string.IsNullOrEmpty(frontend.Fragment) ||
            (frontend.Scheme != Uri.UriSchemeHttps && !(frontend.IsLoopback && frontend.Scheme == Uri.UriSchemeHttp)))
        {
            return null;
        }

        return frontend;
    }

    public async Task<PagedResult<bool>> ResetAsync(ResetPasswordRequest request, CancellationToken cancellationToken)
    {
        if (!Validator.TryValidateObject(request, new ValidationContext(request), [], true) ||
            string.IsNullOrWhiteSpace(request.NewPassword))
        {
            return Result(false, "Revisa la nueva contraseña y su confirmación.");
        }

        var account = tokens.Read(request.Token);
        if (account == null || !await repository.ResetAsync(account, CriptoSecurity.Encrypt(request.NewPassword), cancellationToken))
        {
            return Result(false, "El enlace no es válido, ya fue utilizado o la contraseña no es diferente a la actual. Solicita otro enlace.");
        }

        return Result(true, "Contraseña actualizada. Ya puedes iniciar sesión.");
    }

    private static PagedResult<bool> Result(bool success, string message) => new()
    {
        Success = success,
        Code = success ? "SUCCESS" : "INVALID_RESET",
        Message = message,
        Data = success
    };
}
