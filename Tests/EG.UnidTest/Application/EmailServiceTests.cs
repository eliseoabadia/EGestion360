using EmailService = EG.Business.Services.General.EmailOperationsService;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Settings;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;

namespace EG.UnidTest.Application;

public sealed class EmailServiceTests
{
    [Theory]
    [InlineData(0, true, 30)]
    [InlineData(65536, true, 30)]
    [InlineData(587, false, 30)]
    [InlineData(465, true, 30)]
    [InlineData(587, true, 0)]
    [InlineData(587, true, int.MaxValue)]
    public void InvalidGmailConfigurationIsRejectedBeforeConnecting(int port, bool ssl, int timeout)
    {
        var settings = Settings();
        settings.Port = port;
        settings.EnableSsl = ssl;
        settings.TimeoutSeconds = timeout;
        Assert.False(EmailConfigurationValidator.IsValid(settings));
    }

    [Fact]
    public void GmailStartTlsConfigurationIsAccepted() =>
        Assert.True(EmailConfigurationValidator.IsValid(Settings()));

    [Fact]
    public async Task InvalidRecipientReturnsValidationWithoutDisclosingItsValue()
    {
        var result = await Service().SendAsync(new() { To = ["invalid-private-address"], Subject = "Test" });
        Assert.False(result.Success);
        Assert.Equal("VALIDATION", result.Code);
        Assert.DoesNotContain("invalid-private-address", result.Message);
    }

    [Fact]
    public async Task MalformedAttachmentDoesNotExposeInternalException()
    {
        var result = await Service().SendAsync(new()
        {
            To = ["test@example.com"], Subject = "Test",
            Attachments = [new() { FileName = "test.txt", ContentBase64 = "invalid!" }]
        });
        Assert.False(result.Success);
        Assert.Equal("ERROR", result.Code);
        Assert.DoesNotContain("Base-64", result.Message);
        Assert.DoesNotContain("invalid!", result.Message);
    }

    [Fact]
    public async Task CallerCancellationIsPreserved()
    {
        using var cancellation = new CancellationTokenSource();
        cancellation.Cancel();
        await Assert.ThrowsAnyAsync<OperationCanceledException>(() => Service().SendAsync(
            new() { To = ["test@example.com"], Subject = "Test" }, cancellation.Token));
    }

    private static EmailSettings Settings() => new()
    {
        Host = "smtp.gmail.com", Port = 587, EnableSsl = true, TimeoutSeconds = 30,
        UserName = "test@example.com", FromEmail = "test@example.com", Password = "test-only-placeholder"
    };

    private static EmailService Service() => new(Options.Create(Settings()), NullLogger<EmailService>.Instance);
}
