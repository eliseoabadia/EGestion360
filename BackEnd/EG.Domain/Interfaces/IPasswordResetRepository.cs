namespace EG.Domain.Interfaces;

public sealed record PasswordResetAccount(string Id, string Email, string? SecurityStamp, string PasswordVersion);

public interface IPasswordResetRepository
{
    Task<PasswordResetAccount?> FindActiveByEmailAsync(string email, CancellationToken cancellationToken);
    Task<bool> ResetAsync(PasswordResetAccount account, string encryptedPassword, CancellationToken cancellationToken);
}

public interface IPasswordResetTokenService
{
    string Create(PasswordResetAccount account);
    PasswordResetAccount? Read(string token);
}
