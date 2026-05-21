using System.Net;
using System.Net.Mail;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Settings;
using Microsoft.Extensions.Options;

namespace EG.Application.Services.General
{
    public class EmailService : IEmailService
    {
        private readonly EmailSettings _settings;

        public EmailService(IOptions<EmailSettings> options)
        {
            _settings = options.Value;
        }

        public async Task<PagedResult<EmailSendResponse>> SendAsync(EmailMessageRequest request, CancellationToken cancellationToken = default)
        {
            try
            {
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

                await smtp.SendMailAsync(message, cancellationToken);

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
            catch (Exception ex)
            {
                return new PagedResult<EmailSendResponse>
                {
                    Success = false,
                    Code = "ERROR",
                    Message = $"Error al enviar correo: {ex.Message}",
                    TotalCount = 0
                };
            }
        }

        private PagedResult<EmailSendResponse>? Validate(EmailMessageRequest request)
        {
            if (string.IsNullOrWhiteSpace(_settings.Host) ||
                string.IsNullOrWhiteSpace(_settings.UserName) ||
                string.IsNullOrWhiteSpace(_settings.Password) ||
                string.IsNullOrWhiteSpace(_settings.FromEmail))
            {
                return Failure("La configuracion de correo esta incompleta.");
            }

            if (request == null || !request.To.Any(x => !string.IsNullOrWhiteSpace(x)))
            {
                return Failure("Debe indicar al menos un destinatario.");
            }

            if (string.IsNullOrWhiteSpace(request.Subject))
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
