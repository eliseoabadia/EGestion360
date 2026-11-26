using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;

namespace EG.Application.Interfaces.Account;

public interface IPasswordResetAppService
{
    Task<PagedResult<bool>> RequestAsync(ForgotPasswordRequest? request, CancellationToken cancellationToken);
    Task<PagedResult<bool>> ResetAsync(ResetPasswordRequest? request, CancellationToken cancellationToken);
}
