using EG.Application.Interfaces.General;
using EG.Application.Services.General;
using EG.Common;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.UnidTest.Application;

public sealed class WorkflowEmailDeliveryTests
{
    [Fact]
    public async Task ConfirmedDeliveryCompletesTheClaimOnce()
    {
        var workflow = new Workflow();
        var result = await Send(new Email(new() { Success = true }), workflow);
        Assert.True(result.Success);
        Assert.Equal(1, workflow.Completions);
        Assert.Equal(0, workflow.Cancellations);
    }

    [Fact]
    public async Task ValidationBeforeDeliveryReleasesClaimForCorrection()
    {
        var workflow = new Workflow();
        var result = await Send(new Email(new() { Success = false, Code = "VALIDATION" }), workflow);
        Assert.False(result.Success);
        Assert.Equal(0, workflow.Completions);
        Assert.Equal(1, workflow.Cancellations);
    }

    [Fact]
    public async Task UncertainSmtpResultCannotReleaseClaimAndPermitDuplicateSend()
    {
        var workflow = new Workflow();
        var result = await Send(new Email(new() { Success = false, Code = "ERROR" }), workflow);
        Assert.False(result.Success);
        Assert.Equal(ApplicationText.Workflow.DeliveryUnconfirmedCode, result.Code);
        Assert.Equal(0, workflow.Completions);
        Assert.Equal(0, workflow.Cancellations);
    }

    [Fact]
    public async Task DatabaseFailureAfterAcceptedEmailCannotReleaseClaim()
    {
        var workflow = new Workflow(failCompletion: true);
        var email = new Email(new() { Success = true });
        await Assert.ThrowsAsync<InvalidOperationException>(() => Send(email, workflow));
        Assert.Equal(1, email.Calls);
        Assert.Equal(0, workflow.Cancellations);
    }

    [Fact]
    public async Task ExceptionDuringDeliveryCannotReleaseClaim()
    {
        var workflow = new Workflow();
        await Assert.ThrowsAsync<TimeoutException>(() => Send(new Email(null), workflow));
        Assert.Equal(0, workflow.Cancellations);
        Assert.Equal(0, workflow.Completions);
    }

    [Fact]
    public async Task EmptyOperationTokenNeverCallsProvider()
    {
        var email = new Email(new() { Success = true });
        await Assert.ThrowsAsync<ArgumentException>(() => WorkflowEmailDelivery.SendClaimedAsync(
            email, new Workflow(), "TEST", 1, Guid.Empty, new()));
        Assert.Equal(0, email.Calls);
    }

    private static Task<PagedResult<EmailSendResponse>> Send(Email email, Workflow workflow) =>
        WorkflowEmailDelivery.SendClaimedAsync(email, workflow, "TEST", 1, Guid.NewGuid(), new());

    private sealed class Email(PagedResult<EmailSendResponse>? response) : IEmailService
    {
        public int Calls { get; private set; }
        public Task<PagedResult<EmailSendResponse>> SendAsync(EmailMessageRequest request, CancellationToken cancellationToken = default)
        {
            Calls++;
            return response is null ? Task.FromException<PagedResult<EmailSendResponse>>(new TimeoutException()) : Task.FromResult(response);
        }
    }

    private sealed class Workflow(bool failCompletion = false) : IEnvioWorkflowService
    {
        public int Completions { get; private set; }
        public int Cancellations { get; private set; }
        public Task CompleteAsync(string process, long id, Guid token, CancellationToken cancellationToken = default)
        {
            Completions++;
            return failCompletion ? Task.FromException(new InvalidOperationException("Test database failure")) : Task.CompletedTask;
        }
        public Task CancelAsync(string process, long id, Guid token, CancellationToken cancellationToken = default)
        {
            Cancellations++;
            return Task.CompletedTask;
        }
        public Task<EnvioWorkflowEstadoResponse> GetAsync(string process, long id, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<IReadOnlyDictionary<long, EnvioWorkflowEstadoResponse>> GetManyAsync(string process, IEnumerable<long> ids, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<EnvioWorkflowClaimResult> TryBeginAsync(string process, long id, int userId, CancellationToken cancellationToken = default) => throw new NotSupportedException();
        public Task<EnvioWorkflowEstadoResponse> RejectAsync(string process, long id, int userId, string? reason, CancellationToken cancellationToken = default) => throw new NotSupportedException();
    }
}
