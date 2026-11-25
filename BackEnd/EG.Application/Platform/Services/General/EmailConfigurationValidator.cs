using System.Net.Mail;
using EG.Domain.Settings;

namespace EG.Application.Services.General;

public static class EmailConfigurationValidator
{
    public static bool IsValid(EmailSettings settings) =>
        !string.IsNullOrWhiteSpace(settings.Host) &&
        !string.IsNullOrWhiteSpace(settings.UserName) &&
        !string.IsNullOrWhiteSpace(settings.Password) &&
        MailAddress.TryCreate(settings.FromEmail, out _) &&
        settings.Port is > 0 and <= 65535 &&
        settings.TimeoutSeconds is > 0 and <= int.MaxValue / 1000 &&
        (!string.Equals(settings.Host.Trim(), "smtp.gmail.com", StringComparison.OrdinalIgnoreCase) ||
            (settings.EnableSsl && settings.Port == 587));
}
