using System.Net;
using System.Net.Mail;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Settings;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.General
{
    public class EmailService : IEmailService
    {
        private readonly EmailSettings _settings;
        private readonly ILogger<EmailService> _logger;

        public EmailService(IOptions<EmailSettings> options, ILogger<EmailService> logger)
        {
            _settings = options.Value;
            _logger = logger;
        }

        public async Task<PagedResult<EmailSendResponse>> SendAsync(EmailMessageRequest request, CancellationToken cancellationToken = default)
        {
            try
            {
                cancellationToken.ThrowIfCancellationRequested();
                var validation = Validate(request);
                if (validation != null)
                {
                    return validation;
                }

                using var message = new MailMessage
                {
                    From = new MailAddress(_settings.FromEmail, _settings.FromName),
                    Subject = request.Subject.Trim(),
                    Body = request.Body,
                    IsBodyHtml = request.IsHtml
                };

                AddRecipients(message.To, request.To);
                AddRecipients(message.CC, request.Cc);
                AddRecipients(message.Bcc, request.Bcc);
                AddAttachments(message, request.Attachments);

                using var smtp = new SmtpClient(_settings.Host, _settings.Port)
                {
                    EnableSsl = _settings.EnableSsl,
                    Credentials = new NetworkCredential(_settings.UserName, _settings.Password),
                    Timeout = Math.Max(1, _settings.TimeoutSeconds) * 1000
                };

                using var deadline = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
                deadline.CancelAfter(TimeSpan.FromSeconds(_settings.TimeoutSeconds));
                await smtp.SendMailAsync(message, deadline.Token);

                var response = new EmailSendResponse
                {
                    Sent = true,
                    Recipients = request.To
                        .Concat(request.Cc)
                        .Concat(request.Bcc)
                        .Where(x => !string.IsNullOrWhiteSpace(x))
                        .Distinct(StringComparer.OrdinalIgnoreCase)
                        .ToList(),
                    SentAt = DateTime.Now
                };

                return new PagedResult<EmailSendResponse>
                {
                    Success = true,
                    Code = "SUCCESS",
                    Message = "Correo enviado correctamente.",
                    Data = response,
                    Items = new List<EmailSendResponse> { response },
                    TotalCount = 1
                };
            }
            catch (OperationCanceledException) when (cancellationToken.IsCancellationRequested)
            {
                throw;
            }
            catch (Exception ex)
            {
                // SMTP exceptions can contain addresses or server responses. Log only the type.
                _logger.LogWarning("Falló el envío de correo. Tipo de error: {ErrorType}", ex.GetType().Name);
                return new PagedResult<EmailSendResponse>
                {
                    Success = false,
                    Code = "ERROR",
                    Message = "No fue posible confirmar el envío del correo. Revisa la configuración o contacta al administrador.",
                    TotalCount = 0
                };
            }
        }

        private PagedResult<EmailSendResponse>? Validate(EmailMessageRequest request)
        {
            if (!EmailConfigurationValidator.IsValid(_settings))
            {
                return Failure("La configuracion de correo esta incompleta.");
            }

            if (request == null || request.To == null || !request.To.Any(x => !string.IsNullOrWhiteSpace(x)))
            {
                return Failure("Debe indicar al menos un destinatario.");
            }

            if (request.Cc == null || request.Bcc == null || request.Attachments == null ||
                request.To.Concat(request.Cc).Concat(request.Bcc)
                    .Where(address => !string.IsNullOrWhiteSpace(address))
                    .Any(address => !MailAddress.TryCreate(address.Trim(), out _)))
            {
                return Failure("Revisa las direcciones de los destinatarios del correo.");
            }

            if (string.IsNullOrWhiteSpace(request.Subject) || request.Subject.Contains('\r') || request.Subject.Contains('\n'))
            {
                return Failure("Debe indicar el asunto del correo.");
            }

            return null;
        }

        private static PagedResult<EmailSendResponse> Failure(string message) => new()
        {
            Success = false,
            Code = "VALIDATION",
            Message = message,
            TotalCount = 0
        };

        private static void AddRecipients(MailAddressCollection collection, IEnumerable<string> recipients)
        {
            foreach (var recipient in recipients.Where(x => !string.IsNullOrWhiteSpace(x)).Distinct(StringComparer.OrdinalIgnoreCase))
            {
                collection.Add(recipient.Trim());
            }
        }

        private static void AddAttachments(MailMessage message, IEnumerable<EmailAttachmentRequest> attachments)
        {
            foreach (var attachment in attachments.Where(x =>
                         !string.IsNullOrWhiteSpace(x.FileName) &&
                         !string.IsNullOrWhiteSpace(x.ContentBase64)))
            {
                var bytes = Convert.FromBase64String(attachment.ContentBase64);
                var stream = new MemoryStream(bytes);
                message.Attachments.Add(new Attachment(stream, attachment.FileName, attachment.ContentType));
            }
        }
    }
}
