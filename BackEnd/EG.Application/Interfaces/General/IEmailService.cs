using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IEmailService
    {
        Task<PagedResult<EmailSendResponse>> SendAsync(EmailMessageRequest request, CancellationToken cancellationToken = default);
    }
}
