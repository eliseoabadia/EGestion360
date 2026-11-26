using System.Net;
using EG.Common.Helper;
using EG.Web.Models;
using EG.Web.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.JSInterop;

namespace EG.UnidTest.Presentation;

public sealed class ApiMessageTransportTests
{
    [Theory]
    [InlineData(200)]
    [InlineData(400)]
    [InlineData(409)]
    [InlineData(422)]
    public async Task BusinessRejectionPreservesMessageAndCode(int status)
    {
        var client = Client(status, """{"success":false,"message":"La cantidad supera el saldo disponible.","code":"SALDO_INSUFICIENTE"}""");
        var response = await client.Read();
        Assert.NotNull(response);
        Assert.False(response.Success);
        Assert.Equal("La cantidad supera el saldo disponible.", response.Message);
        Assert.Equal("SALDO_INSUFICIENTE", response.Code);
    }

    [Fact]
    public async Task TupleResponseDoesNotTurnBusinessRejectionIntoSuccess()
    {
        var response = await Client(200, """{"success":false,"message":"El período está cerrado.","code":"CERRADO"}""").ReadWithMessage();
        Assert.False(response.Success);
        Assert.Equal("El período está cerrado.", response.Message);
    }

    [Theory]
    [InlineData(200)]
    [InlineData(400)]
    [InlineData(500)]
    public async Task InternalExceptionTextIsNeverDisplayed(int status)
    {
        var response = await Client(status, """{"success":false,"message":"System.Exception: SQL internal failure","code":"ERROR"}""").Read();
        Assert.False(response!.Success);
        Assert.DoesNotContain("System.Exception", response.Message);
        Assert.NotEmpty(response.Message);
    }

    [Theory]
    [InlineData(401)]
    [InlineData(403)]
    [InlineData(404)]
    [InlineData(429)]
    [InlineData(502)]
    public async Task UnstructuredHttpFailureHasControlledMessage(int status)
    {
        var response = await Client(status, "<html>proxy failure</html>").Read();
        Assert.False(response!.Success);
        Assert.NotEmpty(response.Message);
        Assert.DoesNotContain("<html>", response.Message);
    }

    [Fact]
    public async Task NetworkFailureProducesErrorContract()
    {
        var client = new TestClient(new HttpClient(new Handler(_ => throw new HttpRequestException("offline"))));
        Assert.False((await client.Read())!.Success);
    }

    [Fact]
    public async Task InvalidJsonCannotBecomeSuccessfulEmptyRecord()
    {
        var response = await Client(200, "{broken json").Read();
        Assert.False(response!.Success);
    }

    [Fact]
    public async Task ValidationProblemRetainsFieldMessages()
    {
        var response = await Client(400, """{"errors":{"Cantidad":["La cantidad debe ser positiva."]}}""").Read();
        Assert.False(response!.Success);
        Assert.Equal("La cantidad debe ser positiva.", response.Message);
    }

    [Fact]
    public async Task SuccessfulResponsePreservesMessageAndTrace()
    {
        var response = await Client(200, """{"success":true,"message":"Solicitud registrada.","code":"SUCCESS","traceId":"trace-123"}""").Read();
        Assert.True(response!.Success);
        Assert.Equal("Solicitud registrada.", response.Message);
        Assert.Equal("trace-123", response.TraceId);
    }

    private static TestClient Client(int status, string body) => new(new HttpClient(new Handler(_ =>
        new HttpResponseMessage((HttpStatusCode)status) { Content = new StringContent(body) })));

    private sealed class Handler(Func<HttpRequestMessage, HttpResponseMessage> action) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
            => Task.FromResult(action(request));
    }

    private sealed class Storage : IJSRuntime
    {
        public ValueTask<TValue> InvokeAsync<TValue>(string identifier, object?[]? args)
            => InvokeAsync<TValue>(identifier, CancellationToken.None, args);
        public ValueTask<TValue> InvokeAsync<TValue>(string identifier, CancellationToken cancellationToken, object?[]? args)
            => ValueTask.FromResult(args?.FirstOrDefault()?.ToString() == "authToken" ? (TValue)(object)"test-token" : default!);
    }

    private sealed class TestClient(HttpClient http) : BaseService(http, new Storage(), new ApplicationInstance(), new ConfigurationBuilder().Build())
    {
        public Task<ApiResponse<object>?> Read() => GetAsync<ApiResponse<object>>("https://test.local/api/records");
        public Task<(ApiResponse<object>? Result, bool Success, string Message)> ReadWithMessage()
            => SendRequestWithMessageAsync<ApiResponse<object>>(HttpMethod.Get, "https://test.local/api/records");
    }
}
