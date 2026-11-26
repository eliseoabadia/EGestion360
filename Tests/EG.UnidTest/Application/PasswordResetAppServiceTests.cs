using EG.Application.Interfaces.General;
using EG.Application.Services.Account;
using EG.Common;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using EG.Domain.Settings;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;

namespace EG.UnidTest.Application;

public sealed class PasswordResetAppServiceTests
{
    private static readonly PasswordResetAccount Account = new("id", "account@example.com", "stamp", "version");

    [Fact]
    public async Task NullForgotPasswordRequestReturnsValidationWithoutLookingUpAccounts()
    {
        var repository = new Repository { Account = Account };
        var result = await Create(repository, new Mail()).RequestAsync(null, default);

        Assert.False(result.Success);
        Assert.Equal("INVALID_RESET", result.Code);
        Assert.Equal(0, repository.Lookups);
    }

    [Fact]
    public async Task NullResetPasswordRequestReturnsValidationWithoutUpdatingAccount()
    {
        var repository = new Repository { Account = Account };
        var result = await Create(repository, new Mail()).ResetAsync(null, default);

        Assert.False(result.Success);
        Assert.Equal("INVALID_RESET", result.Code);
        Assert.Equal(0, repository.Updates);
    }

    [Fact]
    public async Task KnownAndUnknownAccountsReceiveTheSamePublicResponse()
    {
        var repository = new Repository { Account = Account };
        var mail = new Mail();
        var service = Create(repository, mail);
        var known = await service.RequestAsync(new() { Email = "account@example.com" }, default);
        repository.Account = null;
        var unknown = await service.RequestAsync(new() { Email = "unknown@example.com" }, default);

        Assert.True(known.Success);
        Assert.Equal(known.Message, unknown.Message);
        Assert.Equal(known.Code, unknown.Code);
        Assert.Single(mail.Messages);
        Assert.Equal(Account.Email, Assert.Single(mail.Messages[0].To));
        Assert.Contains("https://portal.example.com/app/resetPassword#token=protected-token", mail.Messages[0].Body);
    }

    [Fact]
    public async Task MissingSmtpConfigurationFailsBeforeLookingUpAccounts()
    {
        var repository = new Repository { Account = Account };
        var mail = new Mail();
        var service = Create(repository, mail, smtpConfigured: false);

        var result = await service.RequestAsync(new() { Email = Account.Email }, default);

        Assert.False(result.Success);
        Assert.Equal("RECOVERY_UNAVAILABLE", result.Code);
        Assert.Equal(0, repository.Lookups);
        Assert.Empty(mail.Messages);
    }

    [Fact]
    public async Task SingleTrustedHttpsOriginCanSupplyFrontendUrl()
    {
        var mail = new Mail();
        var service = Create(new Repository { Account = Account }, mail, frontend: null,
            origins: ["https://portal.example.com"]);

        Assert.True((await service.RequestAsync(new() { Email = Account.Email }, default)).Success);
        Assert.Contains("https://portal.example.com/resetPassword#token=", Assert.Single(mail.Messages).Body);
    }

    [Theory]
    [InlineData("https://portal.example.com/?redirect=elsewhere")]
    [InlineData("https://portal.example.com/#fragment")]
    [InlineData("http://public.example.com")]
    public async Task InvalidFrontendConfigurationNeverSendsMail(string frontend)
    {
        var mail = new Mail();
        var service = Create(new Repository { Account = Account }, mail, frontend: frontend);
        var result = await service.RequestAsync(new() { Email = Account.Email }, default);

        Assert.False(result.Success);
        Assert.Empty(mail.Messages);
    }

    [Fact]
    public async Task InvalidTokenNeverChangesPassword()
    {
        var repository = new Repository();
        var result = await Create(repository, new Mail()).ResetAsync(new()
        {
            Token = "invalid", NewPassword = "new-password", ConfirmPassword = "new-password"
        }, default);

        Assert.False(result.Success);
        Assert.Equal(0, repository.Updates);
    }

    [Fact]
    public async Task ValidResetUsesExistingEncryptionAndRejectsReuse()
    {
        var repository = new Repository { Account = Account };
        var service = Create(repository, new Mail());
        var request = new ResetPasswordRequest
        {
            Token = "protected-token", NewPassword = "new-password", ConfirmPassword = "new-password"
        };

        Assert.True((await service.ResetAsync(request, default)).Success);
        Assert.Equal(CriptoSecurity.Encrypt("new-password"), repository.Password);
        Assert.False((await service.ResetAsync(request, default)).Success);
        Assert.Equal(1, repository.Updates);
    }

    [Fact]
    public async Task InvalidConfirmationNeverCallsPersistence()
    {
        var repository = new Repository { Account = Account };
        var result = await Create(repository, new Mail()).ResetAsync(new()
        {
            Token = "protected-token", NewPassword = "new-password", ConfirmPassword = "different"
        }, default);

        Assert.False(result.Success);
        Assert.Equal(0, repository.Updates);
    }

    [Theory]
    [InlineData(465, true, 30)]
    [InlineData(587, false, 30)]
    [InlineData(587, true, 0)]
    public async Task InvalidSmtpSettingsNeverLookUpAccountsOrSendTokens(int port, bool ssl, int timeout)
    {
        var repository = new Repository { Account = Account };
        var mail = new Mail();
        var service = Create(repository, mail, smtpSettings: new EmailSettings
        {
            Host = "smtp.gmail.com", Port = port, EnableSsl = ssl, TimeoutSeconds = timeout,
            UserName = "test@example.com", FromEmail = "test@example.com", Password = "test-placeholder"
        });

        var result = await service.RequestAsync(new() { Email = Account.Email }, default);

        Assert.Equal("RECOVERY_UNAVAILABLE", result.Code);
        Assert.Equal(0, repository.Lookups);
        Assert.Empty(mail.Messages);
    }

    private static PasswordResetAppService Create(Repository repository, Mail mail, bool smtpConfigured = true,
        string? frontend = "https://portal.example.com/app/", string[]? origins = null,
        EmailSettings? smtpSettings = null)
    {
        var values = new Dictionary<string, string?> { ["PasswordReset:FrontendUrl"] = frontend };
        for (var i = 0; i < origins?.Length; i++)
        {
            values[$"CorsSettings:AllowOrigins:{i}"] = origins[i];
        }
        return new PasswordResetAppService(repository, new Tokens(), mail,
            Options.Create(smtpSettings ?? new EmailSettings
            {
                Host = "smtp.example.com", UserName = "test", FromEmail = "test@example.com",
                Password = smtpConfigured ? "test-only-placeholder" : ""
            }), new ConfigurationBuilder().AddInMemoryCollection(values).Build(),
            NullLogger<PasswordResetAppService>.Instance);
    }

    private sealed class Repository : IPasswordResetRepository
    {
        public PasswordResetAccount? Account { get; set; }
        public string? Password { get; private set; }
        public int Lookups { get; private set; }
        public int Updates { get; private set; }

        public Task<PasswordResetAccount?> FindActiveByEmailAsync(string email, CancellationToken cancellationToken)
        {
            Lookups++;
            return Task.FromResult(Account);
        }

        public Task<bool> ResetAsync(PasswordResetAccount account, string encryptedPassword, CancellationToken cancellationToken)
        {
            if (Account != account)
            {
                return Task.FromResult(false);
            }
            Updates++;
            Password = encryptedPassword;
            Account = null;
            return Task.FromResult(true);
        }
    }

    private sealed class Tokens : IPasswordResetTokenService
    {
        public string Create(PasswordResetAccount account) => "protected-token";
        public PasswordResetAccount? Read(string token) => token == "protected-token" ? Account : null;
    }

    private sealed class Mail : IEmailService
    {
        public List<EmailMessageRequest> Messages { get; } = [];
        public Task<PagedResult<EmailSendResponse>> SendAsync(EmailMessageRequest request, CancellationToken cancellationToken)
        {
            Messages.Add(request);
            return Task.FromResult(new PagedResult<EmailSendResponse> { Success = true });
        }
    }
}
