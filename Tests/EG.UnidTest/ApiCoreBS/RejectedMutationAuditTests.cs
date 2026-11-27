using EG.ApiCoreBS.Middleware;
using EG.Application.Services.Security;
using EG.Domain.Interfaces;
using EG.Common.Util;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Logging.Abstractions;
using System.Security.Claims;

namespace EG.UnidTest.ApiCoreBS;

public sealed class RejectedMutationAuditTests
{
    [Theory]
    [InlineData("POST")]
    [InlineData("PUT")]
    [InlineData("PATCH")]
    [InlineData("DELETE")]
    public async Task RejectedCompanyIsAuditedWithoutExecutingMutationOrLoggingSecrets(string method)
    {
        var writes = 0;
        var log = new AuditLog();
        var user = new UserContextService(new Request(), NullLogger<UserContextService>.Instance, new Queries());
        var errors = new ApiExceptionMiddleware(http =>
        {
            var scope = new RequestScopeValidationMiddleware(_ =>
            {
                writes++;
                return Task.CompletedTask;
            });
            return scope.InvokeAsync(http, user);
        }, NullLogger<ApiExceptionMiddleware>.Instance);
        var audit = new RejectedMutationAuditMiddleware(ctx => errors.InvokeAsync(ctx, new UserIpService()), log);
        var context = new DefaultHttpContext();
        context.User = new Request().User;
        context.Request.Method = method;
        context.Request.Path = "/api/Requisicion/123";
        context.Request.QueryString = new("?token=secret-token");
        context.Response.Body = new MemoryStream();

        await audit.InvokeAsync(context);

        Assert.Equal(0, writes);
        Assert.Equal(403, context.Response.StatusCode);
        var entry = Assert.Single(log.Entries);
        Assert.Contains("403", entry);
        Assert.DoesNotContain("secret-token", entry);
    }

    [Fact]
    public async Task ExplicitlyAnonymousEndpointsRemainAvailableWithStaleContext()
    {
        var called = false;
        var context = new DefaultHttpContext { User = new Request().User };
        context.SetEndpoint(new Endpoint(_ => Task.CompletedTask, new EndpointMetadataCollection(new AllowAnonymousAttribute()), "login"));
        var scope = new RequestScopeValidationMiddleware(_ => { called = true; return Task.CompletedTask; });
        var user = new UserContextService(new Request(), NullLogger<UserContextService>.Instance, new Queries());
        await scope.InvokeAsync(context, user);
        Assert.True(called);
    }

    [Theory]
    [InlineData(401)]
    [InlineData(403)]
    public async Task AuthenticationAndAuthorizationShortCircuitsAreAudited(int status)
    {
        var log = new AuditLog();
        var audit = new RejectedMutationAuditMiddleware(ctx =>
        {
            ctx.Response.StatusCode = status;
            return Task.CompletedTask;
        }, log);
        var context = new DefaultHttpContext();
        context.Request.Method = "DELETE";
        context.Request.Path = "/api/OrdenCompra/123";
        await audit.InvokeAsync(context);
        Assert.Single(log.Entries);
    }

    private sealed class Request : IUserRequestContext
    {
        public ClaimsPrincipal User { get; } = new(new ClaimsIdentity([
            new(ClaimTypes.NameIdentifier, "42"), new("empresaId", "7")], "test"));
        public string? GetHeader(string name) => name == "X-Empresa-Id" ? "9" : null;
    }

    private sealed class Queries : IUserContextQueries
    {
        public bool CanAccessEmpresa(int userId, int companyId) => false;
        public bool IsActiveAnio(int yearId) => true;
    }

    private sealed class AuditLog : ILogger<RejectedMutationAuditMiddleware>
    {
        public List<string> Entries { get; } = [];
        public IDisposable? BeginScope<TState>(TState state) where TState : notnull => null;
        public bool IsEnabled(LogLevel level) => true;
        public void Log<TState>(LogLevel level, EventId id, TState state, Exception? exception,
            Func<TState, Exception?, string> formatter) => Entries.Add(formatter(state, exception));
    }
}
