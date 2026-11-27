using System.Text.Json;
using EG.ApiCoreBS.Middleware;
using EG.Common.Util;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.ApiCoreBS;

public sealed class ApiExceptionMiddlewareTests
{
    [Fact]
    public async Task ClientCancellationDoesNotBecomeAnInternalServerError()
    {
        using var cancellation = new CancellationTokenSource();
        cancellation.Cancel();
        var context = new DefaultHttpContext { RequestAborted = cancellation.Token };
        context.Response.Body = new MemoryStream();
        var middleware = new ApiExceptionMiddleware(_ => Task.FromCanceled(cancellation.Token),
            NullLogger<ApiExceptionMiddleware>.Instance);
        await middleware.InvokeAsync(context, new UserIpService());
        Assert.Equal(499, context.Response.StatusCode);
        Assert.Equal(0, context.Response.Body.Length);
    }

    [Theory]
    [InlineData("not-found", 404, "NOT_FOUND")]
    [InlineData("forbidden", 403, "FORBIDDEN")]
    [InlineData("unexpected", 500, "Error")]
    public async Task ErrorResponseUsesCorrectStatusWithoutDisclosingInternalDetails(string scenario, int status, string code)
    {
        Exception exception = scenario switch
        {
            "not-found" => new KeyNotFoundException("internal-company-record-123"),
            "forbidden" => new UnauthorizedAccessException("internal-company-record-123"),
            _ => new Exception("internal-company-record-123")
        };
        var middleware = new ApiExceptionMiddleware(_ => Task.FromException(exception),
            NullLogger<ApiExceptionMiddleware>.Instance);
        var context = new DefaultHttpContext();
        using var output = new MemoryStream();
        context.Response.Body = output;

        await middleware.InvokeAsync(context, new UserIpService());

        Assert.Equal(status, context.Response.StatusCode);
        output.Position = 0;
        using var document = await JsonDocument.ParseAsync(output);
        Assert.False(document.RootElement.GetProperty("success").GetBoolean());
        Assert.Equal(code, document.RootElement.GetProperty("code").GetString());
        Assert.DoesNotContain("internal-company-record-123", document.RootElement.GetProperty("message").GetString());
    }
}
