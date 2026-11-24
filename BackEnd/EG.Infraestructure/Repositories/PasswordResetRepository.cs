using System.Security.Cryptography;
using System.Text;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Infrastructure;

public sealed class PasswordResetRepository(EGestionContext context) : IPasswordResetRepository
{
    private IQueryable<AspNetUser> ActiveAccounts => context.AspNetUsers.Where(account =>
        context.Usuarios.Any(user => user.Activo &&
            (user.PkIdUsuario == account.PkIdUsuario || user.AspNetUserId == account.Id)));

    public async Task<PasswordResetAccount?> FindActiveByEmailAsync(string email, CancellationToken cancellationToken)
    {
        // A shared email must never select an arbitrary account for recovery.
        var matches = await ActiveAccounts.AsNoTracking()
            .Where(account => account.Email == email)
            .Take(2).ToListAsync(cancellationToken);
        if (matches.Count != 1)
        {
            return null;
        }

        var account = matches[0];
        return new PasswordResetAccount(account.Id, account.Email, account.SecurityStamp, Version(account.PasswordHash));
    }

    public async Task<bool> ResetAsync(PasswordResetAccount account, string encryptedPassword, CancellationToken cancellationToken)
    {
        var current = await ActiveAccounts.AsNoTracking()
            .SingleOrDefaultAsync(user => user.Id == account.Id, cancellationToken);
        if (current == null || current.Email != account.Email || current.SecurityStamp != account.SecurityStamp ||
            Version(current.PasswordHash) != account.PasswordVersion || current.PasswordHash == encryptedPassword)
        {
            return false;
        }

        var stamp = Guid.NewGuid().ToString("N");
        // Conditional SQL update consumes all outstanding links atomically, including concurrent requests.
        var affected = await ActiveAccounts.Where(user => user.Id == current.Id &&
                user.Email == current.Email && user.SecurityStamp == current.SecurityStamp &&
                user.PasswordHash == current.PasswordHash)
            .ExecuteUpdateAsync(update => update
                .SetProperty(user => user.PasswordHash, encryptedPassword)
                .SetProperty(user => user.SecurityStamp, stamp)
                .SetProperty(user => user.AccessFailedCount, 0)
                .SetProperty(user => user.LockoutEndDateUtc, (DateTime?)null), cancellationToken);
        return affected == 1;
    }

    private static string Version(string? passwordHash) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(passwordHash ?? string.Empty)));
}
