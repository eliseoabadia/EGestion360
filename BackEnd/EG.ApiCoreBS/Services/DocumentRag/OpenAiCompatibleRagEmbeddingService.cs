using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Text.Json;
using EG.Application.Interfaces.DocumentRag;
using EG.Domain.Platform.Settings;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;

namespace EG.ApiCoreBS.Services.DocumentRag
{
    public sealed class OpenAiCompatibleRagEmbeddingService(
        IHttpClientFactory httpClientFactory,
        IOptions<DocumentRagSettings> settings,
        ILogger<OpenAiCompatibleRagEmbeddingService> logger) : IRagEmbeddingService
    {
        private readonly DocumentRagEmbeddingsSettings _settings = settings.Value.Embeddings;

        public bool IsEnabled => _settings.Enabled
            && Uri.TryCreate(_settings.Endpoint, UriKind.Absolute, out _)
            && !string.IsNullOrWhiteSpace(_settings.ApiKey)
            && !string.IsNullOrWhiteSpace(_settings.Model);

        public async Task<IReadOnlyList<float[]>> EmbedAsync(IReadOnlyList<string> inputs, CancellationToken cancellationToken = default)
        {
            if (!IsEnabled || inputs.Count == 0)
                return [];

            try
            {
                using var request = new HttpRequestMessage(HttpMethod.Post, _settings.Endpoint);
                request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", _settings.ApiKey);
                request.Content = JsonContent.Create(new { input = inputs, model = _settings.Model });

                using var response = await httpClientFactory.CreateClient().SendAsync(request, cancellationToken);
                response.EnsureSuccessStatusCode();

                await using var content = await response.Content.ReadAsStreamAsync(cancellationToken);
                using var json = await JsonDocument.ParseAsync(content, cancellationToken: cancellationToken);
                if (!json.RootElement.TryGetProperty("data", out var data) || data.ValueKind != JsonValueKind.Array)
                    return [];

                return data.EnumerateArray()
                    .Select(item => new
                    {
                        Index = item.TryGetProperty("index", out var index) ? index.GetInt32() : 0,
                        Vector = item.TryGetProperty("embedding", out var embedding) && embedding.ValueKind == JsonValueKind.Array
                            ? embedding.EnumerateArray().Select(value => value.GetSingle()).ToArray()
                            : []
                    })
                    .OrderBy(item => item.Index)
                    .Where(item => item.Vector.Length > 0)
                    .Select(item => item.Vector)
                    .ToList();
            }
            catch (Exception ex) when (ex is HttpRequestException or JsonException or TaskCanceledException)
            {
                logger.LogWarning(ex, "No fue posible obtener embeddings para RAG; se usara recuperacion lexica.");
                return [];
            }
        }
    }
}
